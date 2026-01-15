# Testing Best Practices

## Table of Contents
1. [Test Setup](#test-setup)
2. [Compose UI Testing](#compose-ui-testing)
3. [State and ViewModel Testing](#state-and-viewmodel-testing)
4. [Screenshot Testing](#screenshot-testing)
5. [Do's and Don'ts](#dos-and-donts)

---

## Test Setup

### Dependencies (Android)
```kotlin
// build.gradle.kts
dependencies {
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.8.0")

    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
    androidTestImplementation("androidx.compose.ui:ui-test-manifest")
    debugImplementation("androidx.compose.ui:ui-tooling")
}
```

### Dependencies (Multiplatform)
```kotlin
// shared/build.gradle.kts
kotlin {
    sourceSets {
        commonTest.dependencies {
            implementation(kotlin("test"))
            @OptIn(ExperimentalComposeLibrary::class)
            implementation(compose.uiTest)
        }
    }
}
```

---

## Compose UI Testing

### Basic Test Structure
```kotlin
class LoginScreenTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun loginButton_displaysCorrectText() {
        composeTestRule.setContent {
            LoginScreen(
                onLogin = {},
                onForgotPassword = {},
            )
        }

        composeTestRule
            .onNodeWithText("Sign In")
            .assertIsDisplayed()
    }
}
```

### Finding Nodes
```kotlin
// By text
composeTestRule.onNodeWithText("Submit")
composeTestRule.onNodeWithText("Hello", substring = true)
composeTestRule.onNodeWithText("hello", ignoreCase = true)

// By content description (accessibility)
composeTestRule.onNodeWithContentDescription("Close button")

// By test tag (preferred for complex UIs)
composeTestRule.onNodeWithTag("login_button")

// By semantic properties
composeTestRule.onNode(hasClickAction())
composeTestRule.onNode(isToggleable())
composeTestRule.onNode(hasText("Error") and hasAnyAncestor(hasTestTag("form")))

// Multiple nodes
composeTestRule.onAllNodesWithTag("list_item")
composeTestRule.onAllNodesWithText("Delete")[0]
```

### Setting Test Tags
```kotlin
@Composable
fun LoginButton(onClick: () -> Unit) {
    Button(
        onClick = onClick,
        modifier = Modifier.testTag("login_button"),
    ) {
        Text("Login")
    }
}
```

### Actions
```kotlin
// Click
composeTestRule.onNodeWithTag("button").performClick()

// Text input
composeTestRule.onNodeWithTag("email_field").performTextInput("user@example.com")
composeTestRule.onNodeWithTag("email_field").performTextClearance()
composeTestRule.onNodeWithTag("email_field").performTextReplacement("new@example.com")

// Scroll
composeTestRule.onNodeWithTag("list").performScrollToIndex(10)
composeTestRule.onNodeWithTag("list").performScrollToNode(hasText("Item 50"))

// Gestures
composeTestRule.onNodeWithTag("card").performTouchInput {
    swipeLeft()
    swipeRight()
    longClick()
}
```

### Assertions
```kotlin
// Visibility
composeTestRule.onNodeWithTag("dialog").assertIsDisplayed()
composeTestRule.onNodeWithTag("dialog").assertIsNotDisplayed()
composeTestRule.onNodeWithTag("error").assertDoesNotExist()

// State
composeTestRule.onNodeWithTag("checkbox").assertIsOn()
composeTestRule.onNodeWithTag("checkbox").assertIsOff()
composeTestRule.onNodeWithTag("button").assertIsEnabled()
composeTestRule.onNodeWithTag("button").assertIsNotEnabled()

// Content
composeTestRule.onNodeWithTag("title").assertTextEquals("Welcome")
composeTestRule.onNodeWithTag("title").assertTextContains("Welcome")

// Count
composeTestRule.onAllNodesWithTag("item").assertCountEquals(5)
```

### Waiting and Synchronization
```kotlin
// Wait for condition
composeTestRule.waitUntil(timeoutMillis = 5000) {
    composeTestRule
        .onAllNodesWithTag("loaded_content")
        .fetchSemanticsNodes().isNotEmpty()
}

// Wait for idle (animations, etc.)
composeTestRule.waitForIdle()

// Advance clock for animations
composeTestRule.mainClock.advanceTimeBy(500)
composeTestRule.mainClock.advanceTimeUntilIdle()
```

---

## State and ViewModel Testing

### Testing State Changes
```kotlin
class CounterTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun counter_incrementsOnClick() {
        composeTestRule.setContent {
            var count by remember { mutableStateOf(0) }
            Counter(
                count = count,
                onIncrement = { count++ },
            )
        }

        composeTestRule.onNodeWithText("Count: 0").assertIsDisplayed()

        composeTestRule.onNodeWithText("Increment").performClick()

        composeTestRule.onNodeWithText("Count: 1").assertIsDisplayed()
    }
}
```

### Testing ViewModel Integration
```kotlin
class ProfileScreenTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    private val fakeRepository = FakeUserRepository()

    @Test
    fun profileScreen_displaysUserData() = runTest {
        val viewModel = ProfileViewModel(fakeRepository)
        fakeRepository.setUser(User(name = "John Doe"))

        composeTestRule.setContent {
            ProfileScreen(viewModel = viewModel)
        }

        composeTestRule.waitUntil {
            composeTestRule.onAllNodesWithText("John Doe")
                .fetchSemanticsNodes().isNotEmpty()
        }

        composeTestRule.onNodeWithText("John Doe").assertIsDisplayed()
    }
}
```

### Testing Coroutines
```kotlin
@OptIn(ExperimentalCoroutinesApi::class)
class ViewModelTest {

    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    @Test
    fun loadData_updatesState() = runTest {
        val viewModel = MyViewModel(FakeRepository())

        viewModel.loadData()
        advanceUntilIdle()

        assertEquals(UiState.Success(data), viewModel.uiState.value)
    }
}

// MainDispatcherRule for Dispatchers.Main replacement
class MainDispatcherRule(
    private val dispatcher: TestDispatcher = UnconfinedTestDispatcher()
) : TestWatcher() {
    override fun starting(description: Description) {
        Dispatchers.setMain(dispatcher)
    }
    override fun finished(description: Description) {
        Dispatchers.resetMain()
    }
}
```

---

## Screenshot Testing

### Paparazzi (JVM-based, fast)
```kotlin
class ComponentScreenshotTest {

    @get:Rule
    val paparazzi = Paparazzi(
        deviceConfig = DeviceConfig.PIXEL_5,
        theme = "android:Theme.Material.Light.NoActionBar",
    )

    @Test
    fun button_lightMode() {
        paparazzi.snapshot {
            MyButton(text = "Click me", onClick = {})
        }
    }

    @Test
    fun button_darkMode() {
        paparazzi.snapshot {
            MaterialTheme(colorScheme = darkColorScheme()) {
                MyButton(text = "Click me", onClick = {})
            }
        }
    }
}
```

### Roborazzi (Alternative)
```kotlin
@RunWith(AndroidJUnit4::class)
class ScreenshotTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun homeScreen_snapshot() {
        composeTestRule.setContent {
            HomeScreen()
        }

        composeTestRule.onRoot().captureRoboImage()
    }
}
```

---

## Do's and Don'ts

### DO: Use Test Tags for Complex Queries
```kotlin
// DO: Stable test tags
@Composable
fun UserCard(user: User) {
    Card(modifier = Modifier.testTag("user_card_${user.id}")) {
        Text(user.name, modifier = Modifier.testTag("user_name"))
        Text(user.email, modifier = Modifier.testTag("user_email"))
    }
}

// In test
composeTestRule.onNodeWithTag("user_card_123").assertIsDisplayed()
```

### DO: Test Accessibility
```kotlin
@Test
fun button_hasContentDescription() {
    composeTestRule.setContent {
        IconButton(
            onClick = {},
            modifier = Modifier.semantics {
                contentDescription = "Delete item"
            }
        ) {
            Icon(Icons.Default.Delete, contentDescription = null)
        }
    }

    composeTestRule
        .onNodeWithContentDescription("Delete item")
        .assertIsDisplayed()
}
```

### DO: Create Test Fixtures
```kotlin
// Reusable test fixtures
object TestFixtures {
    val sampleUser = User(
        id = "1",
        name = "Test User",
        email = "test@example.com",
    )

    val sampleUserList = listOf(
        sampleUser,
        sampleUser.copy(id = "2", name = "Another User"),
    )
}

// Use in tests
composeTestRule.setContent {
    UserList(users = TestFixtures.sampleUserList)
}
```

### DON'T: Test Implementation Details
```kotlin
// DON'T: Test internal state
@Test
fun badTest() {
    // Don't access internal remember state
    // Don't assert on recomposition counts
}

// DO: Test observable behavior
@Test
fun goodTest() {
    composeTestRule.setContent { Counter() }

    // Test what user sees and can do
    composeTestRule.onNodeWithText("0").assertIsDisplayed()
    composeTestRule.onNodeWithText("+").performClick()
    composeTestRule.onNodeWithText("1").assertIsDisplayed()
}
```

### DON'T: Use Thread.sleep()
```kotlin
// DON'T
Thread.sleep(1000)  // Flaky and slow

// DO: Use waitUntil or advance clock
composeTestRule.waitUntil(timeoutMillis = 5000) {
    composeTestRule.onAllNodesWithTag("loaded")
        .fetchSemanticsNodes().isNotEmpty()
}

// Or for animations
composeTestRule.mainClock.advanceTimeBy(500)
```

### DON'T: Couple Tests to Exact Text
```kotlin
// DON'T: Brittle - breaks if text changes
composeTestRule.onNodeWithText("Click here to submit your form").performClick()

// DO: Use test tags or semantic matchers
composeTestRule.onNodeWithTag("submit_button").performClick()
composeTestRule.onNode(hasClickAction() and hasText("submit", ignoreCase = true))
```
