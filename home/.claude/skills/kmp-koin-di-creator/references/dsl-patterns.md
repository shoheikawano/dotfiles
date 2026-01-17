# DSL-based Koin Patterns

## Table of Contents
- [Basic Definitions](#basic-definitions)
- [Scoped Definitions](#scoped-definitions)
- [Named Qualifiers](#named-qualifiers)
- [Platform-Specific with expect/actual](#platform-specific-with-expectactual)
- [ViewModel Patterns](#viewmodel-patterns)
- [Module Composition](#module-composition)
- [Testing](#testing)

## Basic Definitions

### single{} - Singleton

```kotlin
// Interface binding
single<UserRepository> { UserRepositoryImpl(get()) }

// Concrete class (type inferred)
single { ApiClient(get()) }

// With parameters
single { DatabaseConfig(host = "localhost", port = 5432) }
```

### factory{} - New Instance Each Time

```kotlin
// Use cases (stateless, create fresh each time)
factory { GetUserUseCase(get()) }
factory { ValidateEmailUseCase() }

// Parameterized factory
factory { (userId: String) -> UserDetailViewModel(userId, get()) }
```

### viewModel{} - ViewModel Scoped to Lifecycle

```kotlin
// Standard ViewModel
viewModel { HomeViewModel(get(), get()) }

// With SavedStateHandle
viewModel { (handle: SavedStateHandle) -> EditViewModel(handle, get()) }

// Parameterized
viewModel { (userId: String) -> ProfileViewModel(userId, get()) }
```

## Scoped Definitions

### Custom Scopes

```kotlin
val featureModule = module {
    // Define scope
    scope<AuthScope> {
        scoped { AuthSession() }
        scoped { TokenManager(get()) }
    }
}

// Usage
class AuthScope : ScopeComponent

// Create/close scope
val scope = getKoin().createScope<AuthScope>()
scope.close()
```

## Named Qualifiers

### Using named()

```kotlin
val networkModule = module {
    single(named("auth")) {
        OkHttpClient.Builder()
            .addInterceptor(AuthInterceptor(get()))
            .build()
    }

    single(named("logging")) {
        OkHttpClient.Builder()
            .addInterceptor(HttpLoggingInterceptor())
            .build()
    }
}

// Inject by name
single {
    AuthApi(get(named("auth")))
}
```

### Using StringQualifier

```kotlin
val AUTH_CLIENT = named("authClient")
val PUBLIC_CLIENT = named("publicClient")

val networkModule = module {
    single(AUTH_CLIENT) { createAuthClient() }
    single(PUBLIC_CLIENT) { createPublicClient() }
}
```

## Platform-Specific with expect/actual

### expect Declaration (commonMain)

```kotlin
// commonMain/di/PlatformModule.kt
expect val platformModule: Module
```

### actual Implementation (androidMain)

```kotlin
// androidMain/di/PlatformModule.kt
actual val platformModule = module {
    single<FileStorage> { AndroidFileStorage(androidContext()) }
    single<Preferences> { AndroidPreferences(androidContext()) }
    single { WorkManager.getInstance(androidContext()) }
}
```

### actual Implementation (iosMain)

```kotlin
// iosMain/di/PlatformModule.kt
actual val platformModule = module {
    single<FileStorage> { IosFileStorage() }
    single<Preferences> { IosPreferences() }
}
```

### Interface + Implementations Pattern

```kotlin
// commonMain
interface ImageLoader {
    suspend fun load(url: String): ByteArray
}

// androidMain
class AndroidImageLoader(private val context: Context) : ImageLoader {
    override suspend fun load(url: String): ByteArray = // Coil implementation
}

// iosMain
class IosImageLoader : ImageLoader {
    override suspend fun load(url: String): ByteArray = // NSURLSession implementation
}

// Platform modules bind the implementation
// androidMain
actual val platformModule = module {
    single<ImageLoader> { AndroidImageLoader(androidContext()) }
}
```

## ViewModel Patterns

### Basic ViewModel

```kotlin
val viewModelModule = module {
    viewModel { HomeViewModel(get()) }
    viewModel { SettingsViewModel(get(), get()) }
}

// In Composable
@Composable
fun HomeScreen(viewModel: HomeViewModel = koinViewModel()) {
    // ...
}
```

### ViewModel with Parameters

```kotlin
val viewModelModule = module {
    viewModel { (productId: String) ->
        ProductDetailViewModel(productId, get())
    }
}

// In Composable
@Composable
fun ProductDetailScreen(productId: String) {
    val viewModel: ProductDetailViewModel = koinViewModel { parametersOf(productId) }
}
```

### ViewModel with SavedStateHandle

```kotlin
viewModel { (handle: SavedStateHandle) ->
    EditProfileViewModel(handle, get())
}

// Access in ViewModel
class EditProfileViewModel(
    private val savedStateHandle: SavedStateHandle,
    private val repository: ProfileRepository
) : ViewModel() {
    private val userId: String = savedStateHandle["userId"] ?: ""
}
```

## Module Composition

### Feature Module Pattern

```kotlin
// Each feature exposes a single module
val authModule = module {
    includes(authDataModule, authDomainModule, authUiModule)
}

private val authDataModule = module {
    single<AuthRepository> { AuthRepositoryImpl(get()) }
    single { AuthRemoteDataSource(get()) }
}

private val authDomainModule = module {
    factory { LoginUseCase(get()) }
    factory { LogoutUseCase(get()) }
}

private val authUiModule = module {
    viewModel { LoginViewModel(get(), get()) }
    viewModel { SignUpViewModel(get()) }
}
```

### Root AppModule

```kotlin
val appModule = module {
    includes(
        // Core
        networkModule,
        databaseModule,

        // Features
        authModule,
        profileModule,
        settingsModule,

        // Platform
        platformModule
    )
}
```

### Lazy Module Loading

```kotlin
// Load module on demand
val lazyFeatureModule = lazyModule {
    single { ExpensiveService() }
}

// Load when needed
koin.loadModules(listOf(lazyFeatureModule))
```

## Testing

### Test Module Override

```kotlin
@Test
fun testWithMock() {
    val testModule = module {
        single<UserRepository> { MockUserRepository() }
    }

    startKoin {
        modules(appModule, testModule)
    }

    // Test with mock
    val repo: UserRepository = get()
    // ...

    stopKoin()
}
```

### checkModules Verification

```kotlin
class ModuleCheckTest : KoinTest {
    @Test
    fun verifyKoinConfiguration() {
        koinApplication {
            modules(appModule)
            checkModules()
        }
    }
}
```

### Inject in Tests

```kotlin
class UserRepositoryTest : KoinTest {
    private val repository: UserRepository by inject()

    @Before
    fun setup() {
        startKoin { modules(testModule) }
    }

    @After
    fun tearDown() {
        stopKoin()
    }

    @Test
    fun testGetUser() {
        val user = repository.getUser("123")
        assertNotNull(user)
    }
}
```
