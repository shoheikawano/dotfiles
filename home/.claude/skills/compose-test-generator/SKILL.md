---
name: compose-test-generator
description: |
  Generate Compose UI tests for Android and Kotlin Multiplatform projects.
  Use when: (1) Writing tests for @Composable functions, (2) Creating screenshot/snapshot tests,
  (3) Testing state changes and user interactions in Compose UI, (4) Adding test coverage to screens.
  Triggers: "compose test", "ui test", "write tests for", "test this composable", "screenshot test",
  "paparazzi", "roborazzi", "compose testing".
context: fork
agent: general-purpose
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
---

# Compose Test Generator

Generate idiomatic Compose UI tests following best practices.

## Quick Start

```kotlin
class MyComponentTest {
    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun component_displaysCorrectly() {
        composeTestRule.setContent {
            MyComponent(text = "Hello")
        }

        composeTestRule.onNodeWithText("Hello").assertIsDisplayed()
    }
}
```

## Workflow

1. **Read the composable** to understand structure and state
2. **Identify test scenarios**: happy path, edge cases, interactions
3. **Choose test type**: behavior test, screenshot test, or both
4. **Generate test file** in appropriate location
5. **Add test tags** to composable if needed for reliable selection

## References

| File | When to Read |
|------|--------------|
| [selectors.md](references/selectors.md) | Finding nodes, test tags, semantic matchers |
| [actions.md](references/actions.md) | Click, type, scroll, gesture actions |
| [assertions.md](references/assertions.md) | Visibility, state, content assertions |
| [screenshot-tests.md](references/screenshot-tests.md) | Paparazzi, Roborazzi setup and usage |

## Test Patterns

### Stateless Component Test
```kotlin
@Test
fun button_showsLabel() {
    composeTestRule.setContent {
        PrimaryButton(label = "Submit", onClick = {})
    }
    composeTestRule.onNodeWithText("Submit").assertIsDisplayed()
}
```

### Stateful Interaction Test
```kotlin
@Test
fun counter_incrementsOnClick() {
    composeTestRule.setContent {
        CounterScreen()
    }
    composeTestRule.onNodeWithText("0").assertIsDisplayed()
    composeTestRule.onNodeWithTag("increment_button").performClick()
    composeTestRule.onNodeWithText("1").assertIsDisplayed()
}
```

### ViewModel Integration Test
```kotlin
@Test
fun screen_showsLoadedData() = runTest {
    val viewModel = MyViewModel(FakeRepository())

    composeTestRule.setContent {
        MyScreen(viewModel = viewModel)
    }

    composeTestRule.waitUntil {
        composeTestRule.onAllNodesWithTag("item")
            .fetchSemanticsNodes().isNotEmpty()
    }

    composeTestRule.onAllNodesWithTag("item").assertCountEquals(3)
}
```

## Output Location

Place test files following project convention:
- Android: `app/src/androidTest/java/.../` or `app/src/test/java/.../`
- KMP: `shared/src/commonTest/kotlin/.../`
- Screenshot tests: Usually in `src/test/` (JVM-based)
