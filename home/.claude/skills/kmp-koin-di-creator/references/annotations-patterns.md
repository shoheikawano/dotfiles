# Annotations-based Koin Patterns

## Table of Contents
- [Core Annotations](#core-annotations)
- [Module Definition](#module-definition)
- [Scopes and Qualifiers](#scopes-and-qualifiers)
- [ViewModel Annotations](#viewmodel-annotations)
- [Platform-Specific](#platform-specific)
- [Generated Code Integration](#generated-code-integration)
- [Migration from DSL](#migration-from-dsl)

## Core Annotations

### @Single - Singleton

```kotlin
@Single
class ApiClient(
    private val httpClient: HttpClient
)

// With interface binding
@Single(binds = [UserRepository::class])
class UserRepositoryImpl(
    private val apiClient: ApiClient,
    private val database: AppDatabase
) : UserRepository
```

### @Factory - New Instance

```kotlin
@Factory
class GetUserUseCase(
    private val repository: UserRepository
)

@Factory
class ValidateInputUseCase
```

### @Scoped - Custom Scope

```kotlin
@Scoped(AuthScope::class)
class AuthSession

@Scoped(AuthScope::class)
class TokenManager(
    private val session: AuthSession
)
```

## Module Definition

### @Module with @ComponentScan

```kotlin
// Auto-discover all annotated classes in package
@Module
@ComponentScan("com.example.feature.auth")
class AuthModule
```

### @Module without ComponentScan

```kotlin
// Manual includes
@Module(includes = [NetworkModule::class, DatabaseModule::class])
class CoreModule
```

### Combining Modules

```kotlin
@Module
@ComponentScan("com.example.feature.auth")
class AuthModule

@Module
@ComponentScan("com.example.feature.profile")
class ProfileModule

// Root module combining all
@Module(includes = [AuthModule::class, ProfileModule::class, CoreModule::class])
class AppModule
```

## Scopes and Qualifiers

### Named Qualifier

```kotlin
@Single
@Named("production")
class ProductionApiClient : ApiClient

@Single
@Named("staging")
class StagingApiClient : ApiClient

// Inject by name
@Single
class AuthService(
    @Named("production") private val apiClient: ApiClient
)
```

### Custom Qualifier

```kotlin
@Qualifier
@Retention(AnnotationRetention.RUNTIME)
annotation class IoDispatcher

@Single
@IoDispatcher
fun provideIoDispatcher(): CoroutineDispatcher = Dispatchers.IO

@Single
class DataSync(
    @IoDispatcher private val dispatcher: CoroutineDispatcher
)
```

## ViewModel Annotations

### @KoinViewModel

```kotlin
@KoinViewModel
class HomeViewModel(
    private val getUserUseCase: GetUserUseCase,
    private val analytics: Analytics
) : ViewModel()
```

### ViewModel with Parameters

```kotlin
@KoinViewModel
class ProductDetailViewModel(
    private val productId: String, // Runtime parameter
    private val repository: ProductRepository
) : ViewModel()

// Usage in Compose
@Composable
fun ProductDetailScreen(productId: String) {
    val viewModel: ProductDetailViewModel = koinViewModel { parametersOf(productId) }
}
```

### ViewModel with SavedStateHandle

```kotlin
@KoinViewModel
class EditViewModel(
    private val savedStateHandle: SavedStateHandle,
    private val repository: Repository
) : ViewModel()
```

## Platform-Specific

### expect/actual with Annotations

```kotlin
// commonMain - expect class with interface
expect class PlatformPreferences : Preferences

// androidMain - actual with annotation
@Single(binds = [Preferences::class])
actual class PlatformPreferences(
    private val context: Context
) : Preferences {
    // Android SharedPreferences implementation
}

// iosMain - actual with annotation
@Single(binds = [Preferences::class])
actual class PlatformPreferences : Preferences {
    // iOS NSUserDefaults implementation
}
```

### Platform Module Pattern

```kotlin
// commonMain
@Module
@ComponentScan("com.example.common")
class CommonModule

// androidMain
@Module
@ComponentScan("com.example.android")
class AndroidPlatformModule

// iosMain
@Module
@ComponentScan("com.example.ios")
class IosPlatformModule
```

### @Provided for External Dependencies

```kotlin
// When dependency comes from outside Koin (e.g., Android Context)
@Single
class AndroidFileStorage(
    @Provided private val context: Context
) : FileStorage
```

## Generated Code Integration

### Build Configuration

KSP generates `Module.kt` files. Include in startKoin:

```kotlin
// Generated: AuthModule.kt becomes AuthModuleGen
import com.example.di.AuthModuleGen

fun initKoin() {
    startKoin {
        modules(
            AuthModuleGen.module,
            ProfileModuleGen.module,
            // ...
        )
    }
}
```

### Generated Module Access

```kotlin
// Access generated module
val koinModule = AuthModuleGen.module

// Or use defaultModule for root
startKoin {
    modules(defaultModule)
}
```

## Migration from DSL

### Before (DSL)

```kotlin
val authModule = module {
    single<AuthRepository> { AuthRepositoryImpl(get()) }
    factory { LoginUseCase(get()) }
    viewModel { LoginViewModel(get(), get()) }
}
```

### After (Annotations)

```kotlin
@Module
@ComponentScan("com.example.auth")
class AuthModule

@Single(binds = [AuthRepository::class])
class AuthRepositoryImpl(
    private val apiClient: ApiClient
) : AuthRepository

@Factory
class LoginUseCase(
    private val repository: AuthRepository
)

@KoinViewModel
class LoginViewModel(
    private val loginUseCase: LoginUseCase,
    private val analytics: Analytics
) : ViewModel()
```

### Hybrid Approach

Mix annotations with DSL for complex cases:

```kotlin
@Module
@ComponentScan("com.example.feature")
class FeatureModule

// DSL for dynamic/conditional bindings
val dynamicModule = module {
    single {
        if (BuildConfig.DEBUG) DebugLogger() else ReleaseLogger()
    }
}

// Combine both
startKoin {
    modules(FeatureModuleGen.module, dynamicModule)
}
```
