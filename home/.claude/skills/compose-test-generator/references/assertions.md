# Test Assertions

## Existence Assertions

```kotlin
// Node exists and is displayed
composeTestRule.onNodeWithTag("header").assertExists()
composeTestRule.onNodeWithTag("header").assertIsDisplayed()

// Node does not exist
composeTestRule.onNodeWithTag("error").assertDoesNotExist()

// Node exists but not displayed (e.g., scrolled off screen)
composeTestRule.onNodeWithTag("footer").assertExists()
composeTestRule.onNodeWithTag("footer").assertIsNotDisplayed()
```

## State Assertions

### Enabled/Disabled
```kotlin
composeTestRule.onNodeWithTag("submit").assertIsEnabled()
composeTestRule.onNodeWithTag("submit").assertIsNotEnabled()
```

### Focus
```kotlin
composeTestRule.onNodeWithTag("input").assertIsFocused()
composeTestRule.onNodeWithTag("input").assertIsNotFocused()
```

### Selection
```kotlin
composeTestRule.onNodeWithTag("option_1").assertIsSelected()
composeTestRule.onNodeWithTag("option_2").assertIsNotSelected()
```

### Toggle State
```kotlin
composeTestRule.onNodeWithTag("checkbox").assertIsOn()
composeTestRule.onNodeWithTag("checkbox").assertIsOff()

composeTestRule.onNodeWithTag("switch").assertIsToggleable()
```

## Content Assertions

### Text Content
```kotlin
// Exact match
composeTestRule.onNodeWithTag("title").assertTextEquals("Welcome")

// Contains text
composeTestRule.onNodeWithTag("message").assertTextContains("error")
composeTestRule.onNodeWithTag("message").assertTextContains("Error", ignoreCase = true)

// Multiple text values (for nodes with multiple text elements)
composeTestRule.onNodeWithTag("card").assertTextEquals("Title", "Subtitle")
```

### Content Description
```kotlin
composeTestRule.onNodeWithTag("icon").assertContentDescriptionEquals("Close")
composeTestRule.onNodeWithTag("icon").assertContentDescriptionContains("Close")
```

## Count Assertions

```kotlin
// Exact count
composeTestRule.onAllNodesWithTag("item").assertCountEquals(5)

// At least
composeTestRule.onAllNodesWithTag("item").assertAll(isEnabled())

// Filter and count
composeTestRule.onAllNodesWithTag("item")
    .filter(hasText("Active"))
    .assertCountEquals(3)
```

## Bounds/Position Assertions

```kotlin
// Get bounds
val bounds = composeTestRule.onNodeWithTag("box").getBoundsInRoot()

// Assert relative position
composeTestRule.onNodeWithTag("title")
    .assertTopPositionInRootIsEqualTo(16.dp)

composeTestRule.onNodeWithTag("title")
    .assertLeftPositionInRootIsEqualTo(16.dp)

// Assert size
composeTestRule.onNodeWithTag("icon")
    .assertWidthIsEqualTo(24.dp)
    .assertHeightIsEqualTo(24.dp)
```

## Hierarchy Assertions

```kotlin
// Has parent
composeTestRule.onNodeWithTag("child")
    .assertHasParent()

// Has no parent (root)
composeTestRule.onRoot().assertHasNoParent()

// Has children
composeTestRule.onNodeWithTag("container")
    .onChildren()
    .assertCountEquals(3)

// First/last child assertions
composeTestRule.onNodeWithTag("list")
    .onChildAt(0)
    .assertTextEquals("First Item")
```

## Custom Assertions

```kotlin
// Using assert with SemanticsMatcher
composeTestRule.onNodeWithTag("button").assert(
    hasClickAction() and isEnabled()
)

// Using assertAny for multiple nodes
composeTestRule.onAllNodesWithTag("item").assertAny(
    hasText("Special")
)

// Using assertAll
composeTestRule.onAllNodesWithTag("item").assertAll(
    isEnabled()
)
```

## Chained Assertions

```kotlin
composeTestRule.onNodeWithTag("submit_button")
    .assertExists()
    .assertIsDisplayed()
    .assertIsEnabled()
    .assertHasClickAction()
    .assertTextEquals("Submit")
```

## Negative Assertions

```kotlin
// Assert does not have
composeTestRule.onNodeWithTag("label").assert(
    !hasClickAction()
)

// No matching nodes
composeTestRule.onAllNodes(hasText("Error")).assertCountEquals(0)
```

## Async Assertions

```kotlin
// Wait then assert
composeTestRule.waitUntil(timeoutMillis = 3000) {
    composeTestRule.onAllNodesWithText("Loaded")
        .fetchSemanticsNodes().size == 1
}
composeTestRule.onNodeWithText("Loaded").assertIsDisplayed()

// Retry assertion
composeTestRule.waitUntilExactlyOneExists(
    hasText("Success"),
    timeoutMillis = 5000
)
```

## Debug Helpers

```kotlin
// Print semantic tree (useful for debugging)
composeTestRule.onRoot().printToLog("TREE")

// Print specific node
composeTestRule.onNodeWithTag("complex").printToLog("NODE")

// Get semantic node for inspection
val node = composeTestRule.onNodeWithTag("item").fetchSemanticsNode()
println(node.config)
```
