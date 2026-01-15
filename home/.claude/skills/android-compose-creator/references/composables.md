# Composables Best Practices

## Table of Contents
1. [Naming Conventions](#naming-conventions)
2. [Function Signatures](#function-signatures)
3. [Modifier Handling](#modifier-handling)
4. [Slot APIs](#slot-apis)
5. [Do's and Don'ts](#dos-and-donts)

---

## Naming Conventions

### UI-Emitting Composables: PascalCase
```kotlin
// DO
@Composable
fun UserAvatar(imageUrl: String, modifier: Modifier = Modifier)

@Composable
fun SettingsScreen(onNavigateBack: () -> Unit)

// DON'T
@Composable
fun userAvatar(imageUrl: String) // Wrong: lowercase

@Composable
fun RenderUserAvatar() // Wrong: verb prefix
```

### Value-Returning Composables: camelCase with `remember` prefix
```kotlin
// DO
@Composable
fun rememberScrollState(): ScrollState

@Composable
fun rememberLazyListState(): LazyListState

// DON'T
@Composable
fun RememberScrollState(): ScrollState // Wrong: PascalCase

@Composable
fun getScrollState(): ScrollState // Wrong: no remember prefix
```

---

## Function Signatures

### Parameter Order
```kotlin
@Composable
fun MyComponent(
    // 1. Required parameters (no defaults)
    title: String,
    onAction: () -> Unit,

    // 2. Optional parameters (with defaults)
    subtitle: String? = null,
    enabled: Boolean = true,

    // 3. Trailing lambda slots (if any, before modifier)
    icon: @Composable (() -> Unit)? = null,

    // 4. Modifier (ALWAYS last, ALWAYS with default)
    modifier: Modifier = Modifier,
) {
    // Apply modifier to root composable
    Column(modifier = modifier) { }
}
```

### Event Handler Naming
```kotlin
// DO: Use "on" prefix + action verb
onClick: () -> Unit
onValueChange: (String) -> Unit
onDismissRequest: () -> Unit
onNavigateToDetails: (id: String) -> Unit

// DON'T
clickHandler: () -> Unit      // Wrong: no "on" prefix
handleClick: () -> Unit       // Wrong: no "on" prefix
valueChanged: (String) -> Unit // Wrong: past tense
```

---

## Modifier Handling

### Always Accept and Apply Modifier
```kotlin
// DO
@Composable
fun CustomCard(
    title: String,
    modifier: Modifier = Modifier,
) {
    Card(modifier = modifier) {  // Apply to root
        Text(title)
    }
}

// DON'T
@Composable
fun CustomCard(title: String) {  // Missing modifier parameter
    Card {
        Text(title)
    }
}

// DON'T
@Composable
fun CustomCard(
    title: String,
    modifier: Modifier = Modifier,
) {
    Card {  // Not applying modifier!
        Column(modifier = modifier) {  // Wrong: applied to child
            Text(title)
        }
    }
}
```

### Modifier Chaining
```kotlin
// DO: Chain modifiers, caller's modifier first
@Composable
fun ClickableCard(
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Card(
        modifier = modifier  // Caller's modifier first
            .clickable(onClick = onClick)  // Then internal modifiers
            .padding(16.dp)
    ) { }
}

// DON'T: Internal modifiers before caller's
Card(
    modifier = Modifier
        .padding(16.dp)
        .then(modifier)  // Wrong order
)
```

### Modifier Factory Functions
```kotlin
// DO: For custom modifiers, use factory extension
fun Modifier.shimmer(): Modifier = composed {
    val transition = rememberInfiniteTransition()
    // ...
    this.drawBehind { /* shimmer effect */ }
}

// Usage
Box(modifier = Modifier.shimmer())
```

---

## Slot APIs

### Content Slots for Flexibility
```kotlin
// DO: Use slot API for customizable content
@Composable
fun DialogWithActions(
    title: String,
    onDismiss: () -> Unit,
    confirmButton: @Composable () -> Unit,
    dismissButton: @Composable (() -> Unit)? = null,
    icon: @Composable (() -> Unit)? = null,
    content: @Composable () -> Unit,
    modifier: Modifier = Modifier,
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        icon = icon,
        title = { Text(title) },
        text = content,
        confirmButton = confirmButton,
        dismissButton = dismissButton?.let { { it() } },
        modifier = modifier,
    )
}

// DON'T: Hardcode content structure
@Composable
fun DialogWithActions(
    title: String,
    message: String,  // Too restrictive
    confirmText: String,
    onConfirm: () -> Unit,
)
```

### Trailing Lambda for Primary Content
```kotlin
// DO
@Composable
fun Section(
    title: String,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit,
) {
    Column(modifier = modifier) {
        Text(title, style = MaterialTheme.typography.titleMedium)
        content()
    }
}

// Usage - clean trailing lambda
Section(title = "Settings") {
    SettingsItem(text = "Notifications")
    SettingsItem(text = "Privacy")
}
```

---

## Do's and Don'ts

### DO: Keep Composables Focused
```kotlin
// DO: Single responsibility
@Composable
fun UserListItem(
    user: User,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    ListItem(
        headlineContent = { Text(user.name) },
        supportingContent = { Text(user.email) },
        leadingContent = { UserAvatar(user.avatarUrl) },
        modifier = modifier.clickable(onClick = onClick),
    )
}

// DON'T: God composable doing everything
@Composable
fun UserListItemWithNetworkAndCacheAndAnalytics(/*...*/)
```

### DO: Extract Repeated Patterns
```kotlin
// DO: Reusable components for repeated patterns
@Composable
fun SectionHeader(
    title: String,
    modifier: Modifier = Modifier,
) {
    Text(
        text = title,
        style = MaterialTheme.typography.titleSmall,
        color = MaterialTheme.colorScheme.primary,
        modifier = modifier.padding(horizontal = 16.dp, vertical = 8.dp),
    )
}
```

### DON'T: Pass Mutable Objects
```kotlin
// DON'T: Mutable state as parameter
@Composable
fun Counter(state: MutableState<Int>)  // Bad

// DO: Pass immutable value + callback
@Composable
fun Counter(
    count: Int,
    onCountChange: (Int) -> Unit,
)
```

### DON'T: Use `var` for Parameters
```kotlin
// DON'T
@Composable
fun MyComponent(var title: String)  // Won't compile anyway

// DO: Always immutable parameters
@Composable
fun MyComponent(title: String)
```

### DON'T: Return Values from UI Composables
```kotlin
// DON'T
@Composable
fun UserCard(user: User): ClickResult  // Wrong

// DO: Use callbacks
@Composable
fun UserCard(
    user: User,
    onClick: () -> Unit,
)
```
