# State Management Best Practices

## Table of Contents
1. [State Basics](#state-basics)
2. [Remember Variants](#remember-variants)
3. [State Hoisting](#state-hoisting)
4. [Side Effects](#side-effects)
5. [Do's and Don'ts](#dos-and-donts)

---

## State Basics

### Creating State
```kotlin
// DO: Use remember with mutableStateOf
@Composable
fun Counter() {
    var count by remember { mutableStateOf(0) }
    Button(onClick = { count++ }) {
        Text("Count: $count")
    }
}

// DO: Use rememberSaveable for configuration change survival
@Composable
fun SearchField() {
    var query by rememberSaveable { mutableStateOf("") }
    TextField(value = query, onValueChange = { query = it })
}
```

### State Delegation Patterns
```kotlin
// Using 'by' delegation (preferred for simple cases)
var text by remember { mutableStateOf("") }
text = "new value"  // Direct assignment

// Using state object (when you need State<T> reference)
val textState = remember { mutableStateOf("") }
textState.value = "new value"  // Access via .value

// Destructuring (useful for callbacks)
val (text, setText) = remember { mutableStateOf("") }
TextField(value = text, onValueChange = setText)
```

---

## Remember Variants

### remember
```kotlin
// Survives recomposition, lost on configuration change
val expensiveObject = remember { ExpensiveObject() }

// With key - recalculates when key changes
val filtered = remember(searchQuery) {
    items.filter { it.contains(searchQuery) }
}
```

### rememberSaveable
```kotlin
// Survives configuration changes (uses Bundle)
var selectedTab by rememberSaveable { mutableStateOf(0) }

// Custom Saver for complex objects
data class User(val id: String, val name: String)

val UserSaver = Saver<User, Map<String, String>>(
    save = { mapOf("id" to it.id, "name" to it.name) },
    restore = { User(it["id"]!!, it["name"]!!) }
)

var user by rememberSaveable(stateSaver = UserSaver) {
    mutableStateOf(User("1", "John"))
}

// Using listSaver/mapSaver shortcuts
val UserListSaver = listSaver(
    save = { listOf(it.id, it.name) },
    restore = { User(it[0], it[1]) }
)
```

### rememberCoroutineScope
```kotlin
@Composable
fun ScrollToTopButton(listState: LazyListState) {
    val scope = rememberCoroutineScope()
    Button(onClick = {
        scope.launch {
            listState.animateScrollToItem(0)
        }
    }) {
        Text("Scroll to Top")
    }
}
```

### rememberUpdatedState
```kotlin
// Capture latest value for long-running effects
@Composable
fun LandingScreen(onTimeout: () -> Unit) {
    val currentOnTimeout by rememberUpdatedState(onTimeout)

    LaunchedEffect(Unit) {
        delay(3000)
        currentOnTimeout()  // Uses latest callback
    }
}
```

---

## State Hoisting

### The Pattern
```kotlin
// Stateless: receives state and emits events
@Composable
fun ExpandableCard(
    expanded: Boolean,
    onExpandChange: (Boolean) -> Unit,
    title: String,
    content: @Composable () -> Unit,
    modifier: Modifier = Modifier,
) {
    Card(modifier = modifier) {
        Row(
            modifier = Modifier.clickable { onExpandChange(!expanded) }
        ) {
            Text(title)
            Icon(
                if (expanded) Icons.Default.ExpandLess
                else Icons.Default.ExpandMore
            )
        }
        AnimatedVisibility(visible = expanded) {
            content()
        }
    }
}

// Stateful: manages its own state
@Composable
fun ExpandableCard(
    title: String,
    content: @Composable () -> Unit,
    modifier: Modifier = Modifier,
) {
    var expanded by rememberSaveable { mutableStateOf(false) }
    ExpandableCard(
        expanded = expanded,
        onExpandChange = { expanded = it },
        title = title,
        content = content,
        modifier = modifier,
    )
}
```

### State Holder Pattern
```kotlin
// State holder class
@Stable
class SearchBarState(
    initialQuery: String = "",
    initialActive: Boolean = false,
) {
    var query by mutableStateOf(initialQuery)
        private set
    var active by mutableStateOf(initialActive)
        private set

    fun updateQuery(newQuery: String) {
        query = newQuery
    }

    fun activate() { active = true }
    fun deactivate() { active = false }
}

// Remember function
@Composable
fun rememberSearchBarState(
    initialQuery: String = "",
    initialActive: Boolean = false,
): SearchBarState = remember {
    SearchBarState(initialQuery, initialActive)
}

// Usage
@Composable
fun SearchScreen() {
    val searchState = rememberSearchBarState()
    SearchBar(state = searchState)
}
```

---

## Side Effects

### LaunchedEffect
```kotlin
// Run suspend function when key changes
@Composable
fun UserProfile(userId: String) {
    var user by remember { mutableStateOf<User?>(null) }

    LaunchedEffect(userId) {  // Restarts when userId changes
        user = repository.getUser(userId)
    }

    user?.let { UserContent(it) }
}
```

### DisposableEffect
```kotlin
// Setup/cleanup pattern
@Composable
fun LifecycleObserver(onStart: () -> Unit, onStop: () -> Unit) {
    val lifecycleOwner = LocalLifecycleOwner.current

    DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event ->
            when (event) {
                Lifecycle.Event.ON_START -> onStart()
                Lifecycle.Event.ON_STOP -> onStop()
                else -> Unit
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)

        onDispose {
            lifecycleOwner.lifecycle.removeObserver(observer)
        }
    }
}
```

### SideEffect
```kotlin
// Run after every successful recomposition (no suspend)
@Composable
fun AnalyticsScreen(screenName: String) {
    SideEffect {
        analytics.logScreenView(screenName)
    }
}
```

### produceState
```kotlin
// Convert non-Compose state to Compose state
@Composable
fun UserData(userId: String): State<Result<User>> {
    return produceState<Result<User>>(
        initialValue = Result.Loading,
        key1 = userId
    ) {
        value = try {
            Result.Success(repository.getUser(userId))
        } catch (e: Exception) {
            Result.Error(e)
        }
    }
}
```

### derivedStateOf
```kotlin
// Optimize when derived state changes less frequently
@Composable
fun ItemList(items: List<Item>) {
    val listState = rememberLazyListState()

    // Only recomposes when crossing threshold, not on every scroll
    val showScrollToTop by remember {
        derivedStateOf { listState.firstVisibleItemIndex > 5 }
    }

    Box {
        LazyColumn(state = listState) { /* items */ }
        if (showScrollToTop) {
            ScrollToTopButton()
        }
    }
}
```

### snapshotFlow
```kotlin
// Convert Compose state to Flow
@Composable
fun AutoSaveForm() {
    var text by remember { mutableStateOf("") }

    LaunchedEffect(Unit) {
        snapshotFlow { text }
            .debounce(500)
            .collect { repository.saveDraft(it) }
    }
}
```

---

## Do's and Don'ts

### DO: Use Stable/Immutable Classes
```kotlin
// DO: Mark stable classes
@Stable
class UiState(
    val items: List<Item>,
    val isLoading: Boolean,
)

// Or use @Immutable for truly immutable
@Immutable
data class User(val id: String, val name: String)
```

### DON'T: Create State in Lambdas
```kotlin
// DON'T
items.forEach { item ->
    var expanded by remember { mutableStateOf(false) }  // Wrong
}

// DO: Use key parameter
items.forEach { item ->
    key(item.id) {
        var expanded by remember { mutableStateOf(false) }  // Correct
    }
}
```

### DON'T: Read/Write State in Composition
```kotlin
// DON'T: Side effects in composition
@Composable
fun BadCounter() {
    var count by remember { mutableStateOf(0) }
    count++  // WRONG: modifying during composition
    Text("$count")
}

// DO: Modify in callbacks or effects
@Composable
fun GoodCounter() {
    var count by remember { mutableStateOf(0) }
    LaunchedEffect(Unit) { count++ }  // Or in onClick
}
```

### DON'T: Use Heavy Keys
```kotlin
// DON'T
LaunchedEffect(heavyObject) { }  // May not detect changes

// DO: Use stable, lightweight keys
LaunchedEffect(heavyObject.id) { }
```

### DON'T: Forget to Cancel Effects
```kotlin
// DON'T: Manual coroutine without cancellation
@Composable
fun BadExample() {
    val scope = rememberCoroutineScope()
    Button(onClick = {
        scope.launch {
            delay(5000)
            doSomething()  // May run after composable leaves
        }
    })
}

// DO: Use LaunchedEffect for composition-bound work
@Composable
fun GoodExample(trigger: Boolean) {
    LaunchedEffect(trigger) {
        if (trigger) {
            delay(5000)
            doSomething()  // Cancelled if composable leaves
        }
    }
}
```
