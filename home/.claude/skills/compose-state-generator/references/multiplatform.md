# KMP State Management

## ViewModel Alternatives for KMP

### Option 1: Jetbrains Lifecycle ViewModel (Recommended)
```kotlin
// build.gradle.kts
commonMain.dependencies {
    implementation("org.jetbrains.androidx.lifecycle:lifecycle-viewmodel-compose:2.8.0")
}

// Usage - same as Android
class ProfileViewModel : ViewModel() {
    private val _uiState = MutableStateFlow(ProfileUiState())
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()
}

@Composable
fun ProfileScreen(
    viewModel: ProfileViewModel = viewModel { ProfileViewModel() }
) {
    val uiState by viewModel.uiState.collectAsState()
}
```

### Option 2: moko-mvvm
```kotlin
// build.gradle.kts
commonMain.dependencies {
    implementation("dev.icerock.moko:mvvm-core:0.16.1")
    implementation("dev.icerock.moko:mvvm-compose:0.16.1")
}

// ViewModel
class ProfileViewModel : ViewModel() {
    private val _uiState = MutableStateFlow(ProfileUiState())
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()
}

// Composable
@Composable
fun ProfileScreen() {
    val viewModel = getViewModel(Unit, viewModelFactory { ProfileViewModel() })
    val uiState by viewModel.uiState.collectAsState()
}
```

### Option 3: Simple StateHolder (No Library)
```kotlin
// State holder class
class ProfileStateHolder(
    private val repository: UserRepository,
    private val scope: CoroutineScope,
) {
    private val _uiState = MutableStateFlow(ProfileUiState())
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()

    fun load() {
        scope.launch {
            _uiState.update { it.copy(isLoading = true) }
            val user = repository.getUser()
            _uiState.update { it.copy(isLoading = false, user = user) }
        }
    }
}

// Remember in Composable
@Composable
fun ProfileScreen(repository: UserRepository) {
    val scope = rememberCoroutineScope()
    val stateHolder = remember { ProfileStateHolder(repository, scope) }

    LaunchedEffect(Unit) { stateHolder.load() }

    val uiState by stateHolder.uiState.collectAsState()
}
```

## Platform-Specific ViewModelScope

```kotlin
// commonMain
expect val Dispatchers.Main: CoroutineDispatcher

// androidMain
actual val Dispatchers.Main: CoroutineDispatcher = kotlinx.coroutines.Dispatchers.Main

// iosMain
actual val Dispatchers.Main: CoroutineDispatcher = kotlinx.coroutines.Dispatchers.Main
```

## Collecting State

```kotlin
// Android with Lifecycle
val uiState by viewModel.uiState.collectAsStateWithLifecycle()

// KMP (no lifecycle dependency)
val uiState by viewModel.uiState.collectAsState()
```

## DI for KMP ViewModels

### Koin
```kotlin
// commonMain
val viewModelModule = module {
    viewModel { ProfileViewModel(get()) }
    viewModel { params -> DetailViewModel(params.get(), get()) }
}

// Composable
@Composable
fun ProfileRoute() {
    val viewModel = koinViewModel<ProfileViewModel>()
}

@Composable
fun DetailRoute(itemId: String) {
    val viewModel = koinViewModel<DetailViewModel> { parametersOf(itemId) }
}
```

### Manual with CompositionLocal
```kotlin
// Define
val LocalUserRepository = staticCompositionLocalOf<UserRepository> {
    error("No UserRepository provided")
}

// Provide at root
@Composable
fun App() {
    CompositionLocalProvider(
        LocalUserRepository provides RealUserRepository()
    ) {
        AppContent()
    }
}

// Use in ViewModel creation
@Composable
fun ProfileRoute() {
    val repository = LocalUserRepository.current
    val viewModel = remember { ProfileViewModel(repository) }
}
```
