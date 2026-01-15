# Architecture Best Practices

## Table of Contents
1. [Screen Architecture](#screen-architecture)
2. [ViewModel Integration](#viewmodel-integration)
3. [Navigation](#navigation)
4. [Dependency Injection](#dependency-injection)
5. [Do's and Don'ts](#dos-and-donts)

---

## Screen Architecture

### Three-Layer Pattern
```kotlin
// Layer 1: Route (Navigation entry point)
fun NavGraphBuilder.profileRoute(
    onNavigateToSettings: () -> Unit,
    onNavigateBack: () -> Unit,
) {
    composable("profile/{userId}") { backStackEntry ->
        val userId = backStackEntry.arguments?.getString("userId") ?: return@composable
        ProfileRoute(
            userId = userId,
            onNavigateToSettings = onNavigateToSettings,
            onNavigateBack = onNavigateBack,
        )
    }
}

// Layer 2: Route Composable (ViewModel connection)
@Composable
fun ProfileRoute(
    userId: String,
    onNavigateToSettings: () -> Unit,
    onNavigateBack: () -> Unit,
    viewModel: ProfileViewModel = viewModel { ProfileViewModel(userId) },
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    ProfileScreen(
        uiState = uiState,
        onSettingsClick = onNavigateToSettings,
        onBackClick = onNavigateBack,
        onRetry = viewModel::retry,
    )
}

// Layer 3: Screen (Pure UI)
@Composable
fun ProfileScreen(
    uiState: ProfileUiState,
    onSettingsClick: () -> Unit,
    onBackClick: () -> Unit,
    onRetry: () -> Unit,
    modifier: Modifier = Modifier,
) {
    when (uiState) {
        is ProfileUiState.Loading -> LoadingContent(modifier)
        is ProfileUiState.Success -> ProfileContent(
            user = uiState.user,
            onSettingsClick = onSettingsClick,
            modifier = modifier,
        )
        is ProfileUiState.Error -> ErrorContent(
            onRetry = onRetry,
            modifier = modifier,
        )
    }
}
```

### UI State Modeling
```kotlin
// Sealed hierarchy for mutually exclusive states
sealed interface ProfileUiState {
    data object Loading : ProfileUiState
    data class Success(val user: User) : ProfileUiState
    data class Error(val message: String) : ProfileUiState
}

// Data class for parallel states
data class HomeUiState(
    val isLoading: Boolean = false,
    val items: List<Item> = emptyList(),
    val error: String? = null,
    val isRefreshing: Boolean = false,
)
```

---

## ViewModel Integration

### StateFlow Pattern
```kotlin
class ProfileViewModel(
    private val userId: String,
    private val userRepository: UserRepository,
) : ViewModel() {

    private val _uiState = MutableStateFlow<ProfileUiState>(ProfileUiState.Loading)
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()

    init {
        loadUser()
    }

    fun retry() = loadUser()

    private fun loadUser() {
        viewModelScope.launch {
            _uiState.value = ProfileUiState.Loading
            try {
                val user = userRepository.getUser(userId)
                _uiState.value = ProfileUiState.Success(user)
            } catch (e: Exception) {
                _uiState.value = ProfileUiState.Error(e.message ?: "Unknown error")
            }
        }
    }
}
```

### Collecting State in Compose
```kotlin
// DO: Use collectAsStateWithLifecycle (Android)
@Composable
fun ProfileRoute(viewModel: ProfileViewModel = viewModel()) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    ProfileScreen(uiState = uiState)
}

// For Compose Multiplatform (without lifecycle)
@Composable
fun ProfileRoute(viewModel: ProfileViewModel) {
    val uiState by viewModel.uiState.collectAsState()
    ProfileScreen(uiState = uiState)
}
```

### One-Time Events
```kotlin
class LoginViewModel : ViewModel() {
    private val _events = Channel<LoginEvent>(Channel.BUFFERED)
    val events = _events.receiveAsFlow()

    fun login(email: String, password: String) {
        viewModelScope.launch {
            try {
                authRepository.login(email, password)
                _events.send(LoginEvent.NavigateToHome)
            } catch (e: AuthException) {
                _events.send(LoginEvent.ShowError(e.message))
            }
        }
    }
}

sealed interface LoginEvent {
    data object NavigateToHome : LoginEvent
    data class ShowError(val message: String) : LoginEvent
}

// Collecting in Compose
@Composable
fun LoginRoute(
    onNavigateToHome: () -> Unit,
    viewModel: LoginViewModel = viewModel(),
) {
    val snackbarHostState = remember { SnackbarHostState() }

    LaunchedEffect(Unit) {
        viewModel.events.collect { event ->
            when (event) {
                LoginEvent.NavigateToHome -> onNavigateToHome()
                is LoginEvent.ShowError -> snackbarHostState.showSnackbar(event.message)
            }
        }
    }

    LoginScreen(
        onLogin = viewModel::login,
        snackbarHostState = snackbarHostState,
    )
}
```

---

## Navigation

### Type-Safe Navigation (Compose 2.8+)
```kotlin
// Define routes as serializable classes
@Serializable
data object Home

@Serializable
data class Profile(val userId: String)

@Serializable
data class Settings(val section: String? = null)

// NavHost setup
@Composable
fun AppNavHost(
    navController: NavHostController = rememberNavController(),
    modifier: Modifier = Modifier,
) {
    NavHost(
        navController = navController,
        startDestination = Home,
        modifier = modifier,
    ) {
        composable<Home> {
            HomeRoute(
                onNavigateToProfile = { userId ->
                    navController.navigate(Profile(userId))
                },
            )
        }

        composable<Profile> { backStackEntry ->
            val profile: Profile = backStackEntry.toRoute()
            ProfileRoute(
                userId = profile.userId,
                onNavigateBack = { navController.popBackStack() },
            )
        }
    }
}
```

### Nested Navigation
```kotlin
// Feature module navigation graph
fun NavGraphBuilder.settingsGraph(
    navController: NavController,
    onNavigateToLogin: () -> Unit,
) {
    navigation<SettingsGraph>(startDestination = SettingsMain) {
        composable<SettingsMain> {
            SettingsMainRoute(
                onNavigateToNotifications = {
                    navController.navigate(SettingsNotifications)
                },
                onNavigateToPrivacy = {
                    navController.navigate(SettingsPrivacy)
                },
                onLogout = onNavigateToLogin,
            )
        }
        composable<SettingsNotifications> { /* ... */ }
        composable<SettingsPrivacy> { /* ... */ }
    }
}
```

---

## Dependency Injection

### Hilt + ViewModel (Android)
```kotlin
@HiltViewModel
class ProfileViewModel @Inject constructor(
    private val userRepository: UserRepository,
    savedStateHandle: SavedStateHandle,
) : ViewModel() {
    private val userId: String = savedStateHandle["userId"]!!
    // ...
}

@Composable
fun ProfileRoute(
    viewModel: ProfileViewModel = hiltViewModel(),
) {
    // ...
}
```

### Koin (Multiplatform)
```kotlin
// Module definition
val appModule = module {
    single { UserRepository(get()) }
    viewModel { params -> ProfileViewModel(params.get(), get()) }
}

// Usage in Compose
@Composable
fun ProfileRoute(
    userId: String,
    viewModel: ProfileViewModel = koinViewModel { parametersOf(userId) },
) {
    // ...
}
```

### Manual DI with CompositionLocal
```kotlin
// Define local
val LocalUserRepository = staticCompositionLocalOf<UserRepository> {
    error("No UserRepository provided")
}

// Provide at app level
@Composable
fun App(userRepository: UserRepository) {
    CompositionLocalProvider(LocalUserRepository provides userRepository) {
        AppContent()
    }
}

// Consume
@Composable
fun ProfileRoute() {
    val userRepository = LocalUserRepository.current
    val viewModel = remember { ProfileViewModel(userRepository) }
    // ...
}
```

---

## Do's and Don'ts

### DO: Keep Screen Composables Pure
```kotlin
// DO: Screen only receives state and emits events
@Composable
fun ProfileScreen(
    uiState: ProfileUiState,
    onEditClick: () -> Unit,
    modifier: Modifier = Modifier,
)

// DON'T: Screen has side effects
@Composable
fun ProfileScreen(userId: String) {
    val user = userRepository.getUser(userId)  // Wrong!
}
```

### DO: Use Separate Events for User Actions
```kotlin
// DO
sealed interface HomeEvent {
    data class ItemClick(val id: String) : HomeEvent
    data object RefreshClick : HomeEvent
    data class SearchQueryChange(val query: String) : HomeEvent
}

fun onEvent(event: HomeEvent) {
    when (event) {
        is HomeEvent.ItemClick -> navigateToDetail(event.id)
        HomeEvent.RefreshClick -> refresh()
        is HomeEvent.SearchQueryChange -> updateSearch(event.query)
    }
}

// DON'T: Multiple callback parameters
@Composable
fun HomeScreen(
    onItemClick: (String) -> Unit,
    onRefreshClick: () -> Unit,
    onSearchQueryChange: (String) -> Unit,
    // ... 10 more callbacks
)
```

### DON'T: Pass ViewModel to Child Composables
```kotlin
// DON'T
@Composable
fun ProfileScreen(viewModel: ProfileViewModel) {
    ProfileHeader(viewModel)  // Wrong!
    ProfileContent(viewModel) // Wrong!
}

// DO: Extract state and pass as parameters
@Composable
fun ProfileScreen(
    uiState: ProfileUiState,
    onEditClick: () -> Unit,
) {
    ProfileHeader(
        name = uiState.name,
        avatarUrl = uiState.avatarUrl,
    )
    ProfileContent(
        bio = uiState.bio,
        onEditClick = onEditClick,
    )
}
```

### DON'T: Create ViewModel in Composable Body
```kotlin
// DON'T
@Composable
fun ProfileScreen() {
    val viewModel = ProfileViewModel()  // Wrong! New instance every recomposition
}

// DO: Use viewModel() or hiltViewModel()
@Composable
fun ProfileRoute() {
    val viewModel: ProfileViewModel = viewModel()
}
```
