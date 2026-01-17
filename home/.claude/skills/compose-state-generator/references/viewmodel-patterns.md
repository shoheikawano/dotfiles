# ViewModel Patterns

## Basic ViewModel Structure

```kotlin
class FeatureViewModel(
    private val repository: FeatureRepository,
) : ViewModel() {

    // Private mutable state
    private val _uiState = MutableStateFlow(FeatureUiState())

    // Public immutable state
    val uiState: StateFlow<FeatureUiState> = _uiState.asStateFlow()

    // Load on init
    init {
        loadData()
    }

    // Public action handler
    fun onRefresh() {
        loadData()
    }

    // Private implementation
    private fun loadData() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            // ... fetch data
        }
    }
}
```

## StateFlow Patterns

### Single State Update
```kotlin
_uiState.update { currentState ->
    currentState.copy(isLoading = true)
}
```

### Multiple Field Update
```kotlin
_uiState.update { it.copy(
    isLoading = false,
    items = newItems,
    error = null,
)}
```

### Conditional Update
```kotlin
_uiState.update { currentState ->
    if (currentState.isLoading) {
        currentState.copy(items = newItems, isLoading = false)
    } else {
        currentState
    }
}
```

## Dependency Injection

### Hilt (Android)
```kotlin
@HiltViewModel
class ProfileViewModel @Inject constructor(
    private val userRepository: UserRepository,
    private val analyticsTracker: AnalyticsTracker,
    savedStateHandle: SavedStateHandle,
) : ViewModel() {

    private val userId: String = savedStateHandle["userId"]!!
}

// Usage in Composable
@Composable
fun ProfileRoute(
    viewModel: ProfileViewModel = hiltViewModel()
)
```

### Koin (Multiplatform)
```kotlin
val viewModelModule = module {
    viewModel { params ->
        ProfileViewModel(
            userId = params.get(),
            userRepository = get(),
        )
    }
}

// Usage
@Composable
fun ProfileRoute(
    userId: String,
    viewModel: ProfileViewModel = koinViewModel { parametersOf(userId) }
)
```

### Manual Factory
```kotlin
class ProfileViewModel(
    private val userId: String,
    private val repository: UserRepository,
) : ViewModel() {

    class Factory(
        private val userId: String,
        private val repository: UserRepository,
    ) : ViewModelProvider.Factory {
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            return ProfileViewModel(userId, repository) as T
        }
    }
}

// Usage
val viewModel: ProfileViewModel = viewModel(
    factory = ProfileViewModel.Factory(userId, repository)
)
```

## Combining Multiple Data Sources

### Using combine
```kotlin
class DashboardViewModel(
    private val userRepository: UserRepository,
    private val statsRepository: StatsRepository,
) : ViewModel() {

    val uiState: StateFlow<DashboardUiState> = combine(
        userRepository.userFlow,
        statsRepository.statsFlow,
    ) { user, stats ->
        DashboardUiState(
            userName = user.name,
            totalItems = stats.itemCount,
        )
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = DashboardUiState(),
    )
}
```

