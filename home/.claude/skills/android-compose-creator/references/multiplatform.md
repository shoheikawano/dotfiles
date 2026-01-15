# Compose Multiplatform Best Practices

## Table of Contents
1. [Project Structure](#project-structure)
2. [Expect/Actual Pattern](#expectactual-pattern)
3. [Platform-Specific UI](#platform-specific-ui)
4. [Resources](#resources)
5. [Common Gotchas](#common-gotchas)
6. [Do's and Don'ts](#dos-and-donts)

---

## Project Structure

### Recommended Source Set Layout
```
shared/
├── commonMain/           # Shared code for all platforms
│   └── kotlin/
│       ├── ui/           # Shared Compose UI
│       ├── domain/       # Business logic
│       └── data/         # Repositories, models
├── androidMain/          # Android-specific implementations
│   └── kotlin/
├── iosMain/              # iOS-specific implementations
│   └── kotlin/
├── desktopMain/          # Desktop-specific (JVM)
│   └── kotlin/
└── wasmJsMain/           # Web/WASM-specific
    └── kotlin/
```

### Gradle Configuration
```kotlin
// shared/build.gradle.kts
kotlin {
    androidTarget()
    iosX64()
    iosArm64()
    iosSimulatorArm64()
    jvm("desktop")

    sourceSets {
        commonMain.dependencies {
            implementation(compose.runtime)
            implementation(compose.foundation)
            implementation(compose.material3)
            implementation(compose.components.resources)
        }
        androidMain.dependencies {
            implementation(libs.androidx.activity.compose)
        }
    }
}
```

---

## Expect/Actual Pattern

### Declaring Platform Abstractions
```kotlin
// commonMain: Declare expectation
expect class PlatformContext

expect fun getPlatformName(): String

expect fun openUrl(url: String)

// androidMain: Provide implementation
actual typealias PlatformContext = android.content.Context

actual fun getPlatformName(): String = "Android"

actual fun openUrl(url: String) {
    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
    context.startActivity(intent)
}

// iosMain: Provide implementation
actual class PlatformContext  // No-op on iOS

actual fun getPlatformName(): String = "iOS"

actual fun openUrl(url: String) {
    UIApplication.sharedApplication.openURL(NSURL(string = url)!!)
}
```

### Expect/Actual for Composables
```kotlin
// commonMain
@Composable
expect fun BackHandler(enabled: Boolean = true, onBack: () -> Unit)

// androidMain
@Composable
actual fun BackHandler(enabled: Boolean, onBack: () -> Unit) {
    androidx.activity.compose.BackHandler(enabled = enabled, onBack = onBack)
}

// iosMain
@Composable
actual fun BackHandler(enabled: Boolean, onBack: () -> Unit) {
    // iOS handles back differently via navigation
}
```

### Interface-Based Abstraction (Alternative)
```kotlin
// commonMain - Often cleaner than expect/actual
interface FileSystem {
    suspend fun readText(path: String): String
    suspend fun writeText(path: String, content: String)
}

// Provide via DI
@Composable
fun App(fileSystem: FileSystem) {
    CompositionLocalProvider(LocalFileSystem provides fileSystem) {
        AppContent()
    }
}
```

---

## Platform-Specific UI

### Conditional Rendering by Platform
```kotlin
// commonMain
expect val isIos: Boolean
expect val isAndroid: Boolean
expect val isDesktop: Boolean

@Composable
fun AdaptiveButton(
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit,
) {
    if (isIos) {
        // Cupertino-style button
        CupertinoButton(onClick = onClick, modifier = modifier, content = content)
    } else {
        // Material button
        Button(onClick = onClick, modifier = modifier, content = content)
    }
}
```

### Window Size Classes
```kotlin
// Use window size for adaptive layouts
@Composable
fun AdaptiveLayout() {
    BoxWithConstraints {
        when {
            maxWidth < 600.dp -> PhoneLayout()
            maxWidth < 840.dp -> TabletLayout()
            else -> DesktopLayout()
        }
    }
}

// Or use official WindowSizeClass
@Composable
fun ResponsiveScreen(windowSizeClass: WindowSizeClass) {
    when (windowSizeClass.widthSizeClass) {
        WindowWidthSizeClass.Compact -> ListDetail()
        WindowWidthSizeClass.Medium -> ListDetailPane()
        WindowWidthSizeClass.Expanded -> TwoPane()
    }
}
```

---

## Resources

### Compose Multiplatform Resources (1.6+)
```kotlin
// Place resources in commonMain/composeResources/
// drawable/  → images
// values/    → strings, colors
// font/      → fonts
// files/     → raw files

// Access in code
@Composable
fun Logo() {
    Image(
        painter = painterResource(Res.drawable.logo),
        contentDescription = "Logo",
    )
}

@Composable
fun Greeting() {
    Text(stringResource(Res.string.hello_world))
}
```

### Localization
```kotlin
// commonMain/composeResources/values/strings.xml
// <resources>
//     <string name="greeting">Hello</string>
// </resources>

// commonMain/composeResources/values-ja/strings.xml
// <resources>
//     <string name="greeting">こんにちは</string>
// </resources>

@Composable
fun LocalizedGreeting() {
    Text(stringResource(Res.string.greeting))
}
```

---

## Common Gotchas

### Touch vs Click
```kotlin
// iOS/Desktop: Pointer-based input
// Android: Touch-based input

// DO: Use Modifier.clickable for cross-platform
Box(modifier = Modifier.clickable { onClick() })

// Platform-specific: Hover (desktop/iOS pointer)
Box(
    modifier = Modifier
        .hoverable(interactionSource = remember { MutableInteractionSource() })
        .clickable { onClick() }
)
```

### Keyboard Handling
```kotlin
// Different virtual keyboards per platform
@Composable
fun EmailField() {
    var email by remember { mutableStateOf("") }
    TextField(
        value = email,
        onValueChange = { email = it },
        keyboardOptions = KeyboardOptions(
            keyboardType = KeyboardType.Email,
            imeAction = ImeAction.Next,
        ),
    )
}
```

### Safe Area / Insets
```kotlin
// Android: WindowInsets
// iOS: SafeAreaInsets

@Composable
fun SafeScreen(content: @Composable () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .windowInsetsPadding(WindowInsets.safeDrawing)
    ) {
        content()
    }
}
```

### Threading Differences
```kotlin
// commonMain: Use Dispatchers.Main for UI
// iOS: Main thread is critical
// Android: Main thread for UI updates

// DO: Keep heavy work off main thread
LaunchedEffect(key) {
    withContext(Dispatchers.Default) {
        // Heavy computation
    }
    // Back on Main for state update
}
```

---

## Do's and Don'ts

### DO: Use Common Material3 Components
```kotlin
// DO: Material3 works everywhere
@Composable
fun SharedButton(onClick: () -> Unit) {
    Button(onClick = onClick) {
        Text("Click me")
    }
}

// MaterialTheme works on all platforms
MaterialTheme(
    colorScheme = if (isSystemInDarkTheme()) DarkColors else LightColors
) {
    AppContent()
}
```

### DO: Abstract Platform Capabilities
```kotlin
// DO: Create clear abstractions for platform features
interface Haptics {
    fun click()
    fun heavyClick()
}

// Inject per platform
val LocalHaptics = staticCompositionLocalOf<Haptics> {
    error("No Haptics provided")
}

@Composable
fun HapticButton(onClick: () -> Unit) {
    val haptics = LocalHaptics.current
    Button(onClick = {
        haptics.click()
        onClick()
    }) {
        Text("Tap me")
    }
}
```

### DON'T: Use Platform-Specific APIs Directly
```kotlin
// DON'T: Android-specific in commonMain
@Composable
fun BadExample() {
    val context = LocalContext.current  // Won't compile in commonMain
}

// DO: Abstract via expect/actual or DI
@Composable
expect fun getAppVersion(): String

// Or inject
@Composable
fun GoodExample(appVersion: String) {
    Text("Version: $appVersion")
}
```

### DON'T: Assume Screen Dimensions
```kotlin
// DON'T: Hardcode sizes
Box(modifier = Modifier.size(375.dp, 812.dp))  // iPhone X size

// DO: Use fillMaxSize or constraints
Box(
    modifier = Modifier
        .fillMaxSize()
        .padding(16.dp)
)

// Or adapt to window size
BoxWithConstraints {
    val isLandscape = maxWidth > maxHeight
    if (isLandscape) LandscapeLayout() else PortraitLayout()
}
```

### DON'T: Ignore Platform Conventions
```kotlin
// DON'T: Force Android patterns on iOS
@Composable
fun BadIosNavigation() {
    // Bottom navigation bar on iOS (not idiomatic)
    BottomNavigation { }
}

// DO: Respect platform conventions or make explicitly cross-platform
@Composable
fun AdaptiveNavigation() {
    if (isIos) {
        TabView { }  // iOS tab bar
    } else {
        NavigationBar { }  // Android navigation bar
    }
}
```
