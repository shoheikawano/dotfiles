# Screenshot Testing

## Overview

Screenshot tests capture visual snapshots of composables and compare against golden images. Two main libraries:

| Library | Execution | Speed | Setup |
|---------|-----------|-------|-------|
| **Paparazzi** | JVM (no emulator) | Fast | Easy |
| **Roborazzi** | Robolectric | Medium | Moderate |

---

## Paparazzi

### Setup

```kotlin
// build.gradle.kts (module level)
plugins {
    id("app.cash.paparazzi") version "1.3.4"
}

// For Compose
dependencies {
    testImplementation("app.cash.paparazzi:paparazzi:1.3.4")
}
```

### Basic Test

```kotlin
class ButtonScreenshotTest {

    @get:Rule
    val paparazzi = Paparazzi(
        deviceConfig = DeviceConfig.PIXEL_5,
        theme = "android:Theme.Material.Light.NoActionBar",
    )

    @Test
    fun primaryButton_default() {
        paparazzi.snapshot {
            PrimaryButton(
                text = "Submit",
                onClick = {},
            )
        }
    }

    @Test
    fun primaryButton_disabled() {
        paparazzi.snapshot {
            PrimaryButton(
                text = "Submit",
                onClick = {},
                enabled = false,
            )
        }
    }
}
```

### Theme Variants

```kotlin
@Test
fun card_lightTheme() {
    paparazzi.snapshot {
        MaterialTheme(colorScheme = lightColorScheme()) {
            ProfileCard(user = sampleUser)
        }
    }
}

@Test
fun card_darkTheme() {
    paparazzi.snapshot {
        MaterialTheme(colorScheme = darkColorScheme()) {
            ProfileCard(user = sampleUser)
        }
    }
}
```

### Device Configurations

```kotlin
@get:Rule
val paparazzi = Paparazzi(
    deviceConfig = DeviceConfig.PIXEL_5.copy(
        screenWidth = 1080,
        screenHeight = 2400,
        density = Density.XXHDPI,
        locale = "ja",  // Japanese locale
    ),
)

// Or use preset devices
val paparazzi = Paparazzi(deviceConfig = DeviceConfig.NEXUS_5)
val paparazzi = Paparazzi(deviceConfig = DeviceConfig.PIXEL_C)  // Tablet
```

### Font Scale / Accessibility

```kotlin
@Test
fun button_largeFont() {
    paparazzi.snapshot {
        CompositionLocalProvider(
            LocalDensity provides Density(
                density = LocalDensity.current.density,
                fontScale = 1.5f  // 150% font size
            )
        ) {
            PrimaryButton(text = "Submit", onClick = {})
        }
    }
}
```

### Running Tests

```bash
# Record golden images
./gradlew :app:recordPaparazziDebug

# Verify against golden images
./gradlew :app:verifyPaparazziDebug
```

---

## Roborazzi

### Setup

```kotlin
// build.gradle.kts
plugins {
    id("io.github.takahirom.roborazzi") version "1.20.0"
}

dependencies {
    testImplementation("io.github.takahirom.roborazzi:roborazzi:1.20.0")
    testImplementation("io.github.takahirom.roborazzi:roborazzi-compose:1.20.0")
    testImplementation("androidx.compose.ui:ui-test-junit4")
    testImplementation("org.robolectric:robolectric:4.12")
}

android {
    testOptions {
        unitTests {
            isIncludeAndroidResources = true
        }
    }
}
```

### Basic Test

```kotlin
@RunWith(AndroidJUnit4::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [33])
class ScreenshotTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun profileCard_snapshot() {
        composeTestRule.setContent {
            ProfileCard(user = sampleUser)
        }

        composeTestRule.onRoot().captureRoboImage()
    }
}
```

### Capture Specific Node

```kotlin
@Test
fun button_snapshot() {
    composeTestRule.setContent {
        Column {
            Text("Header")
            PrimaryButton(text = "Click", onClick = {})
            Text("Footer")
        }
    }

    // Capture only the button
    composeTestRule.onNodeWithText("Click").captureRoboImage()
}
```

### Compare Options

```kotlin
@Test
fun card_withCompareOptions() {
    composeTestRule.setContent {
        ProfileCard(user = sampleUser)
    }

    composeTestRule.onRoot().captureRoboImage(
        roborazziOptions = RoborazziOptions(
            compareOptions = RoborazziOptions.CompareOptions(
                changeThreshold = 0.01f,  // 1% threshold
            )
        )
    )
}
```

### Running Tests

```bash
# Record golden images
./gradlew recordRoborazziDebug

# Verify against golden images
./gradlew verifyRoborazziDebug

# Compare and generate diff images
./gradlew compareRoborazziDebug
```

---

## Best Practices

### DO: Test Visual States

```kotlin
// Test all visual variants
@Test fun button_enabled() { }
@Test fun button_disabled() { }
@Test fun button_loading() { }
@Test fun button_pressed() { }
```

### DO: Isolate Components

```kotlin
// Wrap in theme to ensure consistency
paparazzi.snapshot {
    AppTheme {
        Surface {
            ComponentUnderTest()
        }
    }
}
```

### DO: Use Deterministic Data

```kotlin
// Fixed data for reproducible screenshots
val sampleUser = User(
    id = "test-id",
    name = "John Doe",
    avatarUrl = "placeholder",  // Use placeholder, not real URL
)
```

### DON'T: Include Dynamic Content

```kotlin
// DON'T: Timestamps will differ
Text("Last updated: ${System.currentTimeMillis()}")

// DO: Use fixed values
Text("Last updated: Jan 1, 2024")
```

### DON'T: Rely on Network Images

```kotlin
// DON'T: Network images may vary
AsyncImage(model = user.avatarUrl)

// DO: Use placeholder or fake
Image(painterResource(R.drawable.test_avatar))
```

---

## File Organization

```
src/test/
└── java/com/example/
    └── screenshots/
        ├── ButtonScreenshotTest.kt
        ├── CardScreenshotTest.kt
        └── ScreenScreenshotTest.kt

src/test/snapshots/  (Paparazzi golden images)
└── images/
    ├── ButtonScreenshotTest_primaryButton_default.png
    └── ButtonScreenshotTest_primaryButton_disabled.png
```
