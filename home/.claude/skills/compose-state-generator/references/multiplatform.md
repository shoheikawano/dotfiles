# KMP State Management

## ViewModel Alternatives for KMP

### Jetbrains Lifecycle ViewModel
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

## Coding format
- Always define UiState class and Event class in the same file as their ViewModel file, and not in a separate file
