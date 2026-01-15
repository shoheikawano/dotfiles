# Test Actions

## Click Actions

```kotlin
// Simple click
composeTestRule.onNodeWithTag("button").performClick()

// Double click
composeTestRule.onNodeWithTag("item").performTouchInput {
    doubleClick()
}

// Long click
composeTestRule.onNodeWithTag("item").performTouchInput {
    longClick()
}

// Click at position
composeTestRule.onNodeWithTag("canvas").performTouchInput {
    click(center)
    click(topLeft)
    click(Offset(100f, 200f))
}
```

## Text Input

```kotlin
// Type text (appends)
composeTestRule.onNodeWithTag("email_field").performTextInput("user@example.com")

// Clear text
composeTestRule.onNodeWithTag("email_field").performTextClearance()

// Replace text
composeTestRule.onNodeWithTag("email_field").performTextReplacement("new@example.com")

// Type with IME action
composeTestRule.onNodeWithTag("search_field").performTextInput("query")
composeTestRule.onNodeWithTag("search_field").performImeAction()  // Triggers search
```

## Scroll Actions

### LazyColumn/LazyRow
```kotlin
// Scroll to index
composeTestRule.onNodeWithTag("list").performScrollToIndex(10)

// Scroll to specific node
composeTestRule.onNodeWithTag("list").performScrollToNode(
    hasText("Target Item")
)

// Scroll to key
composeTestRule.onNodeWithTag("list").performScrollToKey("item_key")
```

### Regular Scrollable
```kotlin
// Scroll by pixels
composeTestRule.onNodeWithTag("scroll_container").performScrollBy(
    x = 0f,
    y = 500f
)

// Scroll to top/bottom
composeTestRule.onNodeWithTag("scroll_container").performTouchInput {
    swipeUp()   // Scroll down (content moves up)
    swipeDown() // Scroll up (content moves down)
}
```

## Swipe Gestures

```kotlin
composeTestRule.onNodeWithTag("card").performTouchInput {
    // Basic swipes
    swipeLeft()
    swipeRight()
    swipeUp()
    swipeDown()

    // Swipe with parameters
    swipeLeft(
        startX = centerX,
        endX = left,
        durationMillis = 200
    )

    // Custom swipe
    swipe(
        start = center,
        end = Offset(center.x - 300f, center.y),
        durationMillis = 300
    )
}
```

## Multi-Touch Gestures

```kotlin
composeTestRule.onNodeWithTag("image").performTouchInput {
    // Pinch to zoom
    pinch(
        start0 = center - Offset(100f, 0f),
        end0 = center - Offset(200f, 0f),
        start1 = center + Offset(100f, 0f),
        end1 = center + Offset(200f, 0f),
        durationMillis = 300
    )
}
```

## Focus Actions

```kotlin
// Request focus
composeTestRule.onNodeWithTag("text_field").requestFocus()

// Perform focus and then type
composeTestRule.onNodeWithTag("text_field").apply {
    requestFocus()
    performTextInput("Hello")
}
```

## Drag and Drop

```kotlin
composeTestRule.onNodeWithTag("draggable").performTouchInput {
    down(center)
    moveTo(center + Offset(200f, 0f))
    up()
}

// With velocity (fling)
composeTestRule.onNodeWithTag("item").performTouchInput {
    swipeWithVelocity(
        start = center,
        end = center + Offset(500f, 0f),
        endVelocity = 2000f
    )
}
```

## Semantic Actions

```kotlin
// Custom accessibility actions
composeTestRule.onNodeWithTag("card").performSemanticsAction(
    SemanticsActions.OnClick
)

composeTestRule.onNodeWithTag("slider").performSemanticsAction(
    SemanticsActions.SetProgress
) { it(0.75f) }

// Expand/collapse
composeTestRule.onNodeWithTag("expandable").performSemanticsAction(
    SemanticsActions.Expand
)
```

## Waiting for Actions to Complete

```kotlin
// After action, wait for idle
composeTestRule.onNodeWithTag("button").performClick()
composeTestRule.waitForIdle()

// Wait for condition
composeTestRule.waitUntil(timeoutMillis = 5000) {
    composeTestRule.onAllNodesWithTag("loaded")
        .fetchSemanticsNodes().isNotEmpty()
}

// Advance animation clock
composeTestRule.mainClock.advanceTimeBy(500)
composeTestRule.mainClock.advanceTimeUntilIdle()
```
