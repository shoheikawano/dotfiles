# Node Selectors

## Finding Nodes

### By Text
```kotlin
// Exact match
composeTestRule.onNodeWithText("Submit")

// Substring match
composeTestRule.onNodeWithText("Sub", substring = true)

// Case insensitive
composeTestRule.onNodeWithText("submit", ignoreCase = true)

// Multiple nodes
composeTestRule.onAllNodesWithText("Item")
```

### By Test Tag (Preferred)
```kotlin
// In composable
Button(
    onClick = {},
    modifier = Modifier.testTag("submit_button")
) { Text("Submit") }

// In test
composeTestRule.onNodeWithTag("submit_button")
composeTestRule.onAllNodesWithTag("list_item")

// With useUnmergedTree for inner nodes
composeTestRule.onNodeWithTag("icon", useUnmergedTree = true)
```

### By Content Description
```kotlin
// For accessibility-labeled elements
composeTestRule.onNodeWithContentDescription("Close")
composeTestRule.onNodeWithContentDescription("Profile picture")
```

### By Semantic Properties
```kotlin
import androidx.compose.ui.test.*

// Single matchers
composeTestRule.onNode(hasClickAction())
composeTestRule.onNode(hasText("Hello"))
composeTestRule.onNode(isToggleable())
composeTestRule.onNode(isSelectable())
composeTestRule.onNode(isFocusable())
composeTestRule.onNode(isDialog())

// State matchers
composeTestRule.onNode(isEnabled())
composeTestRule.onNode(isNotEnabled())
composeTestRule.onNode(isFocused())
composeTestRule.onNode(isSelected())
composeTestRule.onNode(isOn())  // For toggles
composeTestRule.onNode(isOff())
```

## Combining Matchers

### AND (both conditions)
```kotlin
composeTestRule.onNode(
    hasText("Delete") and hasClickAction()
)

composeTestRule.onNode(
    hasTestTag("item") and hasText("Title")
)
```

### OR (either condition)
```kotlin
composeTestRule.onNode(
    hasText("OK") or hasText("Confirm")
)
```

### Ancestor/Descendant
```kotlin
// Node with specific parent
composeTestRule.onNode(
    hasText("Title") and hasAnyAncestor(hasTestTag("card"))
)

// Node with specific child
composeTestRule.onNode(
    hasTestTag("row") and hasAnyDescendant(hasText("Error"))
)

// Direct parent/child
composeTestRule.onNode(
    hasParent(hasTestTag("container"))
)
composeTestRule.onNode(
    hasAnyChild(hasText("Label"))
)
```

### Sibling
```kotlin
composeTestRule.onNode(
    hasTestTag("icon") and hasAnySibling(hasText("Settings"))
)
```

## Index-Based Selection

```kotlin
// First matching node
composeTestRule.onAllNodesWithTag("item")[0]

// Specific index
composeTestRule.onAllNodesWithTag("item")[2]

// First/last
composeTestRule.onAllNodesWithText("Delete").onFirst()
composeTestRule.onAllNodesWithText("Delete").onLast()
```

## Test Tag Best Practices

### DO: Unique, Descriptive Tags
```kotlin
Modifier.testTag("profile_screen_avatar")
Modifier.testTag("settings_notifications_toggle")
Modifier.testTag("cart_item_${item.id}_delete_button")
```

### DON'T: Generic Tags
```kotlin
Modifier.testTag("button")      // Too generic
Modifier.testTag("text")        // Too generic
Modifier.testTag("1")           // Meaningless
```

### Dynamic Tags for Lists
```kotlin
LazyColumn {
    itemsIndexed(items) { index, item ->
        ListItem(
            modifier = Modifier.testTag("item_${item.id}")
        )
    }
}

// In test
composeTestRule.onNodeWithTag("item_123").performClick()
```
