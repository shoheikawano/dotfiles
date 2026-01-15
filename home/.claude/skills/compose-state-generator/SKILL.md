---
name: compose-state-generator
description: |
  Generate ViewModel, UiState, and state management code for Compose applications.
  Use when: (1) Creating ViewModel with StateFlow, (2) Designing UiState sealed classes,
  (3) Implementing state hoisting patterns, (4) Adding one-time events/effects,
  (5) Connecting ViewModel to Compose screens.
  Triggers: "viewmodel", "uistate", "stateflow", "state management", "mvi",
  "one-time event", "side effect", "compose state".
context: fork
agent: general-purpose
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
---

# Compose State Generator

Generate idiomatic state management code for Compose following UDF (Unidirectional Data Flow).

## Quick Start

```kotlin
// UiState
sealed interface ProfileUiState {
    data object Loading : ProfileUiState
    data class Success(val user: User) : ProfileUiState
    data class Error(val message: String) : ProfileUiState
}

// ViewModel
class ProfileViewModel(
    private val userRepository: UserRepository,
) : ViewModel() {
    private val _uiState = MutableStateFlow<ProfileUiState>(ProfileUiState.Loading)
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()
}
```

## Decision Tree

```
What kind of state?
├─ Screen-level state → ViewModel + UiState
├─ Component-level state → State hoisting or remember
└─ Shared across screens → SharedFlow or StateHolder

Is there async loading?
├─ Yes → Sealed interface (Loading/Success/Error)
└─ No → Data class with fields

Need one-time events?
├─ Yes → Channel + Flow for events
└─ No → Just StateFlow for state
```

## References

| File | When to Read |
|------|--------------|
| [viewmodel-patterns.md](references/viewmodel-patterns.md) | ViewModel structure, StateFlow setup |
| [uistate-design.md](references/uistate-design.md) | Sealed vs data class, state modeling |
| [multiplatform.md](references/multiplatform.md) | KMP ViewModel alternatives |

## Standard ViewModel Template

```kotlin
class FeatureViewModel(
    private val repository: FeatureRepository,
    savedStateHandle: SavedStateHandle,  // Optional: for args
) : ViewModel() {

    private val _uiState = MutableStateFlow(FeatureUiState())
    val uiState: StateFlow<FeatureUiState> = _uiState.asStateFlow()

    private val _events = Channel<FeatureEvent>(Channel.BUFFERED)
    val events = _events.receiveAsFlow()

    init {
        loadData()
    }

    fun onAction(action: FeatureAction) {
        when (action) {
            is FeatureAction.Refresh -> loadData()
            is FeatureAction.ItemClick -> handleItemClick(action.id)
        }
    }

    private fun loadData() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            repository.getData()
                .onSuccess { data ->
                    _uiState.update { it.copy(isLoading = false, items = data) }
                }
                .onFailure { error ->
                    _uiState.update { it.copy(isLoading = false, error = error.message) }
                }
        }
    }
}
```

## Output Location

```
feature/
├── FeatureScreen.kt        # UI
├── FeatureViewModel.kt     # ViewModel
├── FeatureUiState.kt       # State model (or in ViewModel file if small)
└── FeatureAction.kt        # Actions/Events (optional, if complex)
```
