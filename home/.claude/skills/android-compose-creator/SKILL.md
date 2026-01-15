---
name: android-compose-creator
description: |
  Generate Android/Kotlin Multiplatform code using Jetpack Compose and Compose Multiplatform (CMP).
  Use when: (1) Creating new Compose UI components, (2) Building screens with Compose,
  (3) Implementing state management in Compose, (4) Writing Compose Multiplatform shared UI,
  (5) Reviewing or refactoring Compose code, (6) Any Android/KMP UI development task.
  Triggers: "compose", "android ui", "kotlin multiplatform", "CMP", "jetpack compose",
  "composable", "@Composable", "Material3", "screen", "component".
---

# Android Compose Creator

Generate idiomatic, performant Compose Multiplatform code following official best practices.

## Quick Reference

### Composable Function Naming
```kotlin
// DO: PascalCase for UI-emitting composables
@Composable
fun ProfileCard(user: User, modifier: Modifier = Modifier) { }

// DO: camelCase for value-returning composables
@Composable
fun rememberProfileState(): ProfileState { }
```

### Standard Parameter Order
```kotlin
@Composable
fun Component(
    // 1. Required parameters
    title: String,
    onClick: () -> Unit,
    // 2. Optional parameters with defaults
    enabled: Boolean = true,
    // 3. modifier (always last with default)
    modifier: Modifier = Modifier,
) { }
```

### State Hoisting Pattern
```kotlin
// Stateless (preferred for reusability)
@Composable
fun Counter(
    count: Int,
    onIncrement: () -> Unit,
    modifier: Modifier = Modifier,
)

// Stateful wrapper
@Composable
fun Counter(modifier: Modifier = Modifier) {
    var count by remember { mutableStateOf(0) }
    Counter(count = count, onIncrement = { count++ }, modifier = modifier)
}
```

## References

Load these based on the task:

| File | When to Read |
|------|--------------|
| [composables.md](references/composables.md) | Writing any composable function |
| [state-management.md](references/state-management.md) | State, remember, side effects |
| [architecture.md](references/architecture.md) | Screen architecture, ViewModel integration |
| [performance.md](references/performance.md) | Optimizing recomposition, lazy lists |
| [multiplatform.md](references/multiplatform.md) | CMP expect/actual, platform-specific code |
| [testing.md](references/testing.md) | Writing UI tests for composables |

## Core Principles

1. **Unidirectional Data Flow** - State flows down, events flow up
2. **Single Source of Truth** - One owner for each piece of state
3. **Composition over Inheritance** - Small, focused composables
4. **Modifier as Last Parameter** - Always accept and apply Modifier
5. **Stateless by Default** - Hoist state to callers when possible
