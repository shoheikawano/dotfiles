---
name: kotlin-compose-standards
description: |
  Kotlin/Compose coding standards reference. This skill defines mandatory coding conventions
  for Kotlin and Compose code generation. All Compose-related skills MUST reference these standards.
  Use when: (1) Generating Compose code, (2) Reviewing Compose code, (3) Checking coding standards.
  Triggers: "coding standards", "compose standards", "kotlin standards", "style guide".
context: fork
agent: general-purpose
user-invocable: false
allowed-tools:
  - Read
---

# Kotlin/Compose Coding Standards

**MANDATORY**: All Compose code generation skills MUST follow these rules.

## 1. Trailing Comma Rules

**Add trailing comma EXCEPT when passing Modifier as an argument.**

```kotlin
// DO: Trailing comma for regular parameters
data class User(
    val id: String,
    val name: String,  // trailing comma
)

// DO: Trailing comma in function definitions
@Composable
fun ProfileCard(
    user: User,
    modifier: Modifier = Modifier,
    onClick: () -> Unit = {},  // trailing comma
) { }

// DON'T: No trailing comma when passing Modifier
ProfileCard(
    user = user,
    modifier = Modifier
        .fillMaxWidth()
        .padding(16.dp)  // NO trailing comma - Modifier changes frequently
)

// DON'T: No trailing comma at end of Modifier chain
Button(
    onClick = onClick,
    modifier = Modifier
        .fillMaxWidth()
        .height(48.dp)  // NO trailing comma
)
```

**Rationale**: Modifier arguments change more frequently than other code. Without trailing comma, only one line changes in git diff instead of two.

## 2. Composable Function Definition Parameter Ordering

**Order: Required params → Modifier → Optional params**

```kotlin
// CORRECT order
@Composable
fun UserCard(
    // 1. Required parameters (no defaults)
    user: User,
    onClick: () -> Unit,
    // 2. Modifier parameter
    modifier: Modifier = Modifier,
    // 3. Optional parameters (with defaults)
    showAvatar: Boolean = true,
    avatarSize: Dp = 48.dp,
) { }

// WRONG order - don't do this
@Composable
fun UserCard(
    user: User,
    showAvatar: Boolean = true,  // optional before modifier
    modifier: Modifier = Modifier,
    onClick: () -> Unit,  // required after modifier
) { }
```

## 3. Composable Function Calling Parameter Ordering

**Pass Modifier at the END of the call, NO trailing comma.**

```kotlin
// CORRECT: Modifier last, no trailing comma
UserCard(
    user = user,
    onClick = { viewModel.onUserClick(user) },
    showAvatar = true,
    modifier = Modifier
        .fillMaxWidth()
        .padding(horizontal = 16.dp)  // NO trailing comma
)

// WRONG: Modifier not last
UserCard(
    modifier = Modifier.fillMaxWidth(),  // should be last
    user = user,
    onClick = onClick,
)
```

## 4. New Line Requirements

### End of File
**Always ensure a new line at the end of every file.**

### Modifier Method Chains
**Each Modifier method MUST be on its own line.**

```kotlin
// CORRECT: Each method on new line
Modifier
    .fillMaxWidth()
    .padding(16.dp)
    .background(Color.White)
    .clickable { onClick() }

// WRONG: Methods on same line
Modifier.fillMaxWidth().padding(16.dp)

// WRONG: Some methods combined
Modifier
    .fillMaxWidth().padding(16.dp)  // should be separate lines
    .background(Color.White)
```

## 5. Summary Checklist

When generating or reviewing Compose code, verify:

- [ ] Trailing commas present EXCEPT for Modifier arguments
- [ ] Function definition order: required → Modifier → optional
- [ ] Function call order: Modifier passed last
- [ ] No trailing comma after Modifier chain
- [ ] Each Modifier method on its own line
- [ ] New line at end of file

## Integration with Other Skills

Skills that generate Compose code MUST include this reference:

```markdown
## Coding Standards
This skill follows [kotlin-compose-standards](/Users/shoheikawano/.claude/skills/kotlin-compose-standards/skill.md).
All generated code MUST comply with these standards.
```
