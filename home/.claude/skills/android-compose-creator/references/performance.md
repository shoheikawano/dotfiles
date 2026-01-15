# Performance Best Practices

## Table of Contents
1. [Understanding Recomposition](#understanding-recomposition)
2. [Stability and Skipping](#stability-and-skipping)
3. [Lists and LazyLayouts](#lists-and-lazylayouts)
4. [Lambda and Object Allocation](#lambda-and-object-allocation)
5. [Measuring Performance](#measuring-performance)
6. [Do's and Don'ts](#dos-and-donts)

---

## Understanding Recomposition

### Compose Phases
```
Composition → Layout → Drawing

- Composition: What UI to show (Composable functions run)
- Layout: Where to place UI (measure + place)
- Drawing: How to render UI (draw commands)
```

### Recomposition Triggers
```kotlin
// State reads cause recomposition
@Composable
fun Counter() {
    var count by remember { mutableStateOf(0) }  // State
    Text("Count: $count")  // Reads state → will recompose when count changes
    Button(onClick = { count++ }) { Text("Add") }
}
```

### Defer Reads Pattern
```kotlin
// DON'T: Read state during composition
@Composable
fun BadScrollingBox(scrollState: ScrollState) {
    val offset = scrollState.value  // Read during composition
    Box(modifier = Modifier.offset(y = offset.dp))
}

// DO: Defer read to layout/draw phase
@Composable
fun GoodScrollingBox(scrollState: ScrollState) {
    Box(
        modifier = Modifier.offset {
            IntOffset(0, scrollState.value)  // Read during layout
        }
    )
}

// DO: Use graphicsLayer for draw-phase reads
@Composable
fun AnimatedBox(alpha: State<Float>) {
    Box(
        modifier = Modifier.graphicsLayer {
            this.alpha = alpha.value  // Read during draw
        }
    )
}
```

---

## Stability and Skipping

### Stable Types
```kotlin
// Primitives are stable: Int, String, Float, Boolean, etc.

// Data classes with stable properties are stable
@Immutable
data class User(
    val id: String,
    val name: String,
    val age: Int,
)

// Mark mutable-but-stable classes with @Stable
@Stable
class CounterState {
    var count by mutableStateOf(0)
}
```

### Unstable Types (Prevent Skipping)
```kotlin
// Lists, Maps, Sets are unstable by default
data class UiState(
    val items: List<Item>,  // Unstable! Prevents skipping
)

// Fix 1: Use @Immutable (if truly immutable)
@Immutable
data class UiState(
    val items: List<Item>,
)

// Fix 2: Use kotlinx.collections.immutable
data class UiState(
    val items: ImmutableList<Item>,  // Stable
)
```

### Lambda Stability
```kotlin
// DON'T: Inline lambda captures changing values
@Composable
fun ParentBad(items: List<Item>) {
    items.forEach { item ->
        ChildComponent(
            onClick = { viewModel.select(item) }  // New lambda every recomposition
        )
    }
}

// DO: Use remember for lambdas
@Composable
fun ParentGood(items: List<Item>) {
    items.forEach { item ->
        val onClick = remember(item.id) { { viewModel.select(item) } }
        ChildComponent(onClick = onClick)
    }
}

// DO: Use method references when possible
@Composable
fun ParentBetter() {
    ChildComponent(onClick = viewModel::onSelect)  // Stable reference
}
```

---

## Lists and LazyLayouts

### Use key() for Item Identity
```kotlin
// DO: Provide stable keys
LazyColumn {
    items(
        items = users,
        key = { user -> user.id }  // Stable identity
    ) { user ->
        UserItem(user)
    }
}

// DON'T: Use index as key for dynamic lists
LazyColumn {
    itemsIndexed(users) { index, user ->
        // index as implicit key - bad for insertions/deletions
        UserItem(user)
    }
}
```

### Avoid Nested Scrolling
```kotlin
// DON'T: LazyColumn inside LazyColumn
LazyColumn {
    item {
        LazyColumn { /* nested scroll - bad */ }
    }
}

// DO: Use single LazyColumn with different item types
LazyColumn {
    item { Header() }
    items(mainItems) { MainItem(it) }
    item { SectionDivider() }
    items(secondaryItems) { SecondaryItem(it) }
}
```

### ContentType for Heterogeneous Lists
```kotlin
LazyColumn {
    items(
        items = feedItems,
        key = { it.id },
        contentType = { item ->
            when (item) {
                is FeedItem.Post -> "post"
                is FeedItem.Ad -> "ad"
                is FeedItem.Story -> "story"
            }
        }
    ) { item ->
        when (item) {
            is FeedItem.Post -> PostCard(item)
            is FeedItem.Ad -> AdBanner(item)
            is FeedItem.Story -> StoryRow(item)
        }
    }
}
```

### Prefetching and Placeholders
```kotlin
// Configure prefetch
LazyColumn(
    state = rememberLazyListState(),
    // Prefetch 3 items beyond visible
    flingBehavior = rememberSnapFlingBehavior(lazyListState),
) { }

// Use placeholder for expensive items
@Composable
fun ImageItem(imageUrl: String) {
    AsyncImage(
        model = imageUrl,
        contentDescription = null,
        placeholder = painterResource(R.drawable.placeholder),
        modifier = Modifier.size(100.dp),
    )
}
```

---

## Lambda and Object Allocation

### Remember Expensive Objects
```kotlin
// DON'T: Create object every recomposition
@Composable
fun BadExample() {
    val dateFormat = SimpleDateFormat("yyyy-MM-dd")  // New every time
}

// DO: Remember expensive objects
@Composable
fun GoodExample() {
    val dateFormat = remember { SimpleDateFormat("yyyy-MM-dd") }
}
```

### Avoid Allocations in Modifiers
```kotlin
// DON'T: Create Dp/Color inside modifier chains
Box(
    modifier = Modifier
        .padding(16.dp)  // OK: Dp is inline class
        .background(Color(0xFF123456))  // Allocation every recomposition!
)

// DO: Remember or extract colors
val backgroundColor = remember { Color(0xFF123456) }
// Or use theme: MaterialTheme.colorScheme.surface
```

### derivedStateOf for Computed Values
```kotlin
// DON'T: Expensive computation every recomposition
@Composable
fun FilteredList(items: List<Item>, query: String) {
    val filtered = items.filter { it.name.contains(query) }  // Every recomp
}

// DO: derivedStateOf caches until dependencies change
@Composable
fun FilteredList(items: List<Item>, query: String) {
    val filtered by remember(items) {
        derivedStateOf { items.filter { it.name.contains(query) } }
    }
}
```

---

## Measuring Performance

### Layout Inspector
```kotlin
// Enable composition counts in Android Studio Layout Inspector
// Shows recomposition count and skip count per composable
```

### Composition Tracing
```kotlin
// Add tracing to identify slow composables
@Composable
fun ExpensiveScreen() {
    trace("ExpensiveScreen") {
        // Screen content
    }
}
```

### Strong Skipping Mode (Compose 1.5.4+)
```kotlin
// In build.gradle.kts
composeCompiler {
    enableStrongSkippingMode = true  // More aggressive skipping
}
```

---

## Do's and Don'ts

### DO: Use Modifier.Node for Custom Modifiers
```kotlin
// Modern approach (1.3+)
class CircleModifierNode : DrawModifierNode, Modifier.Node() {
    override fun ContentDrawScope.draw() {
        drawCircle(Color.Red)
        drawContent()
    }
}

fun Modifier.circle() = this then CircleModifierElement

private data object CircleModifierElement : ModifierNodeElement<CircleModifierNode>() {
    override fun create() = CircleModifierNode()
    override fun update(node: CircleModifierNode) {}
}
```

### DON'T: Use Modifier.composed When Avoidable
```kotlin
// DON'T: composed creates new modifier instance per use
fun Modifier.rippleBackground() = composed {
    val color = MaterialTheme.colorScheme.primary
    this.background(color)
}

// DO: If you need composition, use Modifier.Node
// Or pass values as parameters
fun Modifier.coloredBackground(color: Color) = this.background(color)

@Composable
fun Example() {
    val color = MaterialTheme.colorScheme.primary
    Box(modifier = Modifier.coloredBackground(color))
}
```

### DO: Minimize State Scope
```kotlin
// DON'T: Large parent recomposes for tiny state change
@Composable
fun BadScreen() {
    var searchQuery by remember { mutableStateOf("") }  // Declared too high

    Column {
        ExpensiveHeader()  // Recomposes when searchQuery changes!
        SearchBar(query = searchQuery, onQueryChange = { searchQuery = it })
        ExpensiveList()    // Recomposes when searchQuery changes!
    }
}

// DO: Isolate state to where it's needed
@Composable
fun GoodScreen() {
    Column {
        ExpensiveHeader()  // Never recomposes for search
        SearchSection()    // Contains its own state
        ExpensiveList()    // Never recomposes for search
    }
}

@Composable
private fun SearchSection() {
    var searchQuery by remember { mutableStateOf("") }
    SearchBar(query = searchQuery, onQueryChange = { searchQuery = it })
    SearchResults(query = searchQuery)
}
```

### DON'T: Use remember {} for Simple Values
```kotlin
// DON'T: Unnecessary remember
val padding = remember { 16.dp }  // Dp is already stable/cheap

// DO: Direct usage
val padding = 16.dp
```
