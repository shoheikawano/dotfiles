# Gradle Setup for Koin 4.x in KMP

## Table of Contents
- [Version Catalog](#version-catalog)
- [Root build.gradle.kts](#root-buildgradlekts)
- [Module build.gradle.kts](#module-buildgradlekts)
- [Annotations KSP Setup](#annotations-ksp-setup)
- [Compile-Time Verification](#compile-time-verification)

## Version Catalog

```toml
# gradle/libs.versions.toml
[versions]
koin = "4.0.0"
koin-annotations = "2.0.0"
ksp = "2.0.0-1.0.24"

[libraries]
# Core
koin-core = { module = "io.insert-koin:koin-core", version.ref = "koin" }

# Android
koin-android = { module = "io.insert-koin:koin-android", version.ref = "koin" }
koin-android-workmanager = { module = "io.insert-koin:koin-androidx-workmanager", version.ref = "koin" }

# Compose
koin-compose = { module = "io.insert-koin:koin-compose", version.ref = "koin" }
koin-compose-viewmodel = { module = "io.insert-koin:koin-compose-viewmodel", version.ref = "koin" }

# Annotations (optional)
koin-annotations = { module = "io.insert-koin:koin-annotations", version.ref = "koin-annotations" }
koin-ksp-compiler = { module = "io.insert-koin:koin-ksp-compiler", version.ref = "koin-annotations" }

# Testing
koin-test = { module = "io.insert-koin:koin-test", version.ref = "koin" }
koin-test-junit5 = { module = "io.insert-koin:koin-test-junit5", version.ref = "koin" }

[plugins]
ksp = { id = "com.google.devtools.ksp", version.ref = "ksp" }
```

## Root build.gradle.kts

```kotlin
// build.gradle.kts (root)
plugins {
    alias(libs.plugins.ksp) apply false
}
```

## Module build.gradle.kts

### DSL-Only Setup (No Annotations)

```kotlin
// composeApp/build.gradle.kts
plugins {
    kotlin("multiplatform")
    id("com.android.application")
}

kotlin {
    androidTarget()

    listOf(iosX64(), iosArm64(), iosSimulatorArm64()).forEach {
        it.binaries.framework {
            baseName = "ComposeApp"
        }
    }

    sourceSets {
        commonMain.dependencies {
            implementation(libs.koin.core)
            implementation(libs.koin.compose)
            implementation(libs.koin.compose.viewmodel)
        }

        androidMain.dependencies {
            implementation(libs.koin.android)
        }

        commonTest.dependencies {
            implementation(libs.koin.test)
        }
    }
}
```

## Annotations KSP Setup

### Plugin Configuration

```kotlin
// composeApp/build.gradle.kts
plugins {
    kotlin("multiplatform")
    id("com.android.application")
    alias(libs.plugins.ksp)
}

kotlin {
    androidTarget()

    listOf(iosX64(), iosArm64(), iosSimulatorArm64()).forEach {
        it.binaries.framework {
            baseName = "ComposeApp"
        }
    }

    sourceSets {
        commonMain.dependencies {
            implementation(libs.koin.core)
            implementation(libs.koin.compose)
            implementation(libs.koin.compose.viewmodel)
            implementation(libs.koin.annotations)
        }

        androidMain.dependencies {
            implementation(libs.koin.android)
        }
    }
}

// KSP configuration for each target
dependencies {
    // Common
    add("kspCommonMainMetadata", libs.koin.ksp.compiler)

    // Android
    add("kspAndroid", libs.koin.ksp.compiler)

    // iOS
    add("kspIosX64", libs.koin.ksp.compiler)
    add("kspIosArm64", libs.koin.ksp.compiler)
    add("kspIosSimulatorArm64", libs.koin.ksp.compiler)
}

// Make generated sources visible
kotlin.sourceSets.commonMain {
    kotlin.srcDir("build/generated/ksp/metadata/commonMain/kotlin")
}
```

### KSP Arguments

```kotlin
// composeApp/build.gradle.kts
ksp {
    arg("KOIN_CONFIG_CHECK", "true")  // Enable compile-time verification
    arg("KOIN_DEFAULT_MODULE", "true") // Generate defaultModule
}
```

## Compile-Time Verification

### Enable Config Check

```kotlin
// build.gradle.kts
ksp {
    arg("KOIN_CONFIG_CHECK", "true")
}
```

This validates at compile time:
- All dependencies are resolvable
- No circular dependencies
- All required bindings exist

### Runtime Verification (DSL)

```kotlin
// For DSL-based projects, verify at startup (debug builds only)
fun initKoin(checkModules: Boolean = false) {
    startKoin {
        modules(appModule)
        if (checkModules) {
            checkModules {
                // Provide test values for platform-specific deps
                withInstance(mockContext)
            }
        }
    }
}
```

### Test Verification

```kotlin
class KoinConfigurationTest : KoinTest {
    @Test
    fun verifyKoinConfiguration() {
        koinApplication {
            modules(appModule)
            checkModules {
                withInstance<Context>(mockContext)
            }
        }
    }
}
```

## Common Issues

### KSP Not Generating Code

Ensure tasks run in correct order:

```kotlin
// build.gradle.kts
tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    if (name != "kspCommonMainKotlinMetadata") {
        dependsOn("kspCommonMainKotlinMetadata")
    }
}
```

### Missing Android Context

Provide context in startKoin:

```kotlin
startKoin {
    androidContext(applicationContext)
    modules(appModule)
}
```

### iOS Initialization Issues

Export Koin to iOS properly:

```kotlin
// iosMain/KoinHelper.kt
object KoinHelper {
    fun initKoin() {
        startKoin {
            modules(appModule, iosModule)
        }
    }

    fun getKoin() = KoinPlatform.getKoin()
}
```

```swift
// iOS Swift
KoinHelper.shared.doInitKoin()
```
