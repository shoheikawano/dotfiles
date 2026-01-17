---
name: kmp-koin-di-creator
description: >-
  Generate Koin dependency injection code for Kotlin Multiplatform (KMP) projects using Koin 4.x.
  Use when (1) Setting up Koin DI in KMP projects, (2) Creating Koin modules for features,
  (3) Implementing DSL-based or Annotations-based DI, (4) Configuring platform-specific dependencies with expect/actual,
  (5) Adding ViewModels with Koin, (6) Structuring DI for clean architecture (UI/Domain/Data layers).
  Triggers include koin, dependency injection, di module, koin module, @Single, @Factory, viewModel{}, single{}, factory{}, kmp di, multiplatform di.
metadata:
  context: fork
  agent: general-purpose
  user-invocable: true
---

# KMP Koin DI Creator

Generate Koin 4.x dependency injection code following feature-based module organization with Android Modern Architecture (UI/Domain/Data layers).

## Approach Selection

Koin 4.x offers two approaches:

| Approach | When to Use |
|----------|-------------|
| **DSL-based** | Rapid prototyping, smaller projects, runtime flexibility |
| **Annotations-based** | Larger projects, compile-time safety, auto-discovery |

Ask the user which approach they prefer if not specified.

## Quick Start

### DSL-based Module

```kotlin
// feature/auth/di/AuthModule.kt
val authModule = module {
    // Data layer
    single<AuthRepository> { AuthRepositoryImpl(get()) }
    single { AuthRemoteDataSource(get()) }

    // Domain layer - pure Kotlin, no Koin deps in use cases
    factory { LoginUseCase(get()) }
    factory { LogoutUseCase(get()) }

    // UI layer
    viewModel { LoginViewModel(get(), get()) }
}
```

### Annotations-based Module

```kotlin
// feature/auth/di/AuthModule.kt
@Module
@ComponentScan("com.example.auth")
class AuthModule

// feature/auth/data/AuthRepositoryImpl.kt
@Single
class AuthRepositoryImpl(
    private val remoteDataSource: AuthRemoteDataSource
) : AuthRepository

// feature/auth/ui/LoginViewModel.kt
@KoinViewModel
class LoginViewModel(
    private val loginUseCase: LoginUseCase,
    private val logoutUseCase: LogoutUseCase
) : ViewModel()
```

## Module Organization

Follow feature-based structure with clean architecture layers:

```
composeApp/
  src/
    commonMain/
      kotlin/com/example/
        di/
          AppModule.kt          # Root module aggregating features
        feature/
          auth/
            di/AuthModule.kt    # Feature DI module
            data/               # Repositories, data sources
            domain/             # Use cases (pure Kotlin, NO Koin)
            ui/                 # ViewModels, UI state
          profile/
            di/ProfileModule.kt
            data/
            domain/
            ui/
    androidMain/
      kotlin/com/example/
        di/AndroidModule.kt     # Android-specific bindings
        MainApplication.kt      # Koin initialization
    iosMain/
      kotlin/com/example/
        di/IosModule.kt         # iOS-specific bindings
        KoinHelper.kt           # iOS initialization helper
```

## Workflow

1. **Determine approach** - DSL or Annotations (ask if unclear)
2. **Identify feature scope** - What feature/layer needs DI?
3. **Generate module code** - Create appropriate Koin module
4. **Handle platform-specific** - Use expect/actual for platform deps
5. **Update root module** - Include new module in AppModule
6. **Configure Gradle** - Ensure dependencies are correct

## References

For detailed implementation patterns:

- **DSL approach**: See [references/dsl-patterns.md](references/dsl-patterns.md)
- **Annotations approach**: See [references/annotations-patterns.md](references/annotations-patterns.md)
- **Gradle configuration**: See [references/gradle-setup.md](references/gradle-setup.md)

## Platform Initialization

### Android (Application class)

```kotlin
class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        startKoin {
            androidContext(this@MainApplication)
            modules(appModule, androidModule)
        }
    }
}
```

### iOS (Helper function)

```kotlin
// iosMain/KoinHelper.kt
fun initKoin() {
    startKoin {
        modules(appModule, iosModule)
    }
}

// Call from Swift: KoinHelperKt.doInitKoin()
```

## Best Practices

- Keep domain layer free of Koin dependencies (pure Kotlin use cases)
- Use interfaces for shared code testability
- Prefer constructor injection over field injection
- Enable compile-time verification with `KOIN_CONFIG_CHECK=true`
- Separate platform modules (androidModule, iosModule)
