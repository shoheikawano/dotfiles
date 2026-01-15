# UiState Design

## Sealed Interface vs Data Class

### When to Use Sealed Interface

Use when states are **mutually exclusive**:

```kotlin
sealed interface ProfileUiState {
    data object Loading : ProfileUiState
    data class Success(val user: User) : ProfileUiState
    data class Error(val message: String) : ProfileUiState
}

// Usage in Composable
when (uiState) {
    ProfileUiState.Loading -> LoadingIndicator()
    is ProfileUiState.Success -> ProfileContent(uiState.user)
    is ProfileUiState.Error -> ErrorMessage(uiState.message)
}
```

### When to Use Data Class

Use when states can **coexist**:

```kotlin
data class HomeUiState(
    val isLoading: Boolean = false,
    val items: List<Item> = emptyList(),
    val error: String? = null,
    val isRefreshing: Boolean = false,
    val selectedFilter: Filter = Filter.All,
)

// Usage - can show items while refreshing
Column {
    if (uiState.isRefreshing) RefreshIndicator()
    ItemList(uiState.items)
    if (uiState.error != null) ErrorSnackbar(uiState.error)
}
```

## Decision Matrix

| Scenario | Pattern |
|----------|---------|
| Loading → Success → Error (exclusive) | Sealed interface |
| Can show data + loading spinner | Data class |
| Pull-to-refresh over existing data | Data class |
| Pagination (loading more while showing list) | Data class |
| Simple form with validation | Data class |
| Wizard steps (one at a time) | Sealed interface |

## Sealed Interface Patterns

### Basic Pattern
```kotlin
sealed interface ScreenUiState {
    data object Loading : ScreenUiState
    data class Success(val data: Data) : ScreenUiState
    data class Error(val message: String) : ScreenUiState
}
```

### With Partial Loading
```kotlin
sealed interface ArticleUiState {
    data object Loading : ArticleUiState

    data class Success(
        val article: Article,
        val isCommentsLoading: Boolean = false,
        val comments: List<Comment> = emptyList(),
    ) : ArticleUiState

    data class Error(val message: String) : ArticleUiState
}
```

### Nested Sealed Classes
```kotlin
sealed interface CheckoutUiState {
    data object Loading : CheckoutUiState

    sealed interface Active : CheckoutUiState {
        data class Cart(val items: List<CartItem>) : Active
        data class Shipping(val address: Address?) : Active
        data class Payment(val method: PaymentMethod?) : Active
        data class Review(val order: Order) : Active
    }

    data class Completed(val orderId: String) : CheckoutUiState
    data class Error(val message: String) : CheckoutUiState
}
```

## Data Class Patterns

### Standard Form State
```kotlin
data class LoginUiState(
    val email: String = "",
    val password: String = "",
    val emailError: String? = null,
    val passwordError: String? = null,
    val isLoading: Boolean = false,
    val isPasswordVisible: Boolean = false,
) {
    val isValid: Boolean
        get() = email.isNotBlank() &&
                password.isNotBlank() &&
                emailError == null &&
                passwordError == null
}
```

### List with Filters
```kotlin
data class ProductListUiState(
    val products: List<Product> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null,
    val searchQuery: String = "",
    val selectedCategory: Category? = null,
    val sortOrder: SortOrder = SortOrder.Newest,
) {
    val filteredProducts: List<Product>
        get() = products
            .filter { selectedCategory == null || it.category == selectedCategory }
            .filter { it.name.contains(searchQuery, ignoreCase = true) }
            .sortedWith(sortOrder.comparator)
}
```

### Pagination State
```kotlin
data class FeedUiState(
    val items: List<FeedItem> = emptyList(),
    val isLoading: Boolean = false,
    val isLoadingMore: Boolean = false,
    val error: String? = null,
    val hasMorePages: Boolean = true,
    val currentPage: Int = 0,
)
```

## Stability Annotations

### @Immutable
```kotlin
@Immutable
data class User(
    val id: String,
    val name: String,
    val email: String,
)
```

### @Stable
```kotlin
@Stable
data class UiState(
    val items: List<Item>,  // List is unstable, but we mark class stable
    val selectedId: String?,
)
```

### Using ImmutableList
```kotlin
import kotlinx.collections.immutable.ImmutableList
import kotlinx.collections.immutable.persistentListOf

data class TodoUiState(
    val items: ImmutableList<TodoItem> = persistentListOf(),
    val isLoading: Boolean = false,
)

// Creating
val state = TodoUiState(
    items = items.toImmutableList()
)
```

## Common Mistakes

### DON'T: Mutable Properties
```kotlin
// DON'T
data class UiState(
    var isLoading: Boolean = false,  // Mutable!
)

// DO
data class UiState(
    val isLoading: Boolean = false,  // Immutable
)
```

### DON'T: Domain Objects Directly
```kotlin
// DON'T: Exposes domain model to UI
data class UiState(
    val user: UserEntity,  // Domain/DB entity
)

// DO: Map to UI model
data class UiState(
    val user: UserUiModel,  // UI-specific model
)

data class UserUiModel(
    val displayName: String,
    val avatarUrl: String,
    val memberSince: String,  // Already formatted
)
```

### DON'T: Too Many Boolean Flags
```kotlin
// DON'T
data class UiState(
    val isLoading: Boolean,
    val isError: Boolean,
    val isEmpty: Boolean,
    val isSuccess: Boolean,
)

// DO: Use sealed interface for exclusive states
sealed interface UiState {
    data object Loading : UiState
    data object Empty : UiState
    data class Success(val data: Data) : UiState
    data class Error(val message: String) : UiState
}
```
