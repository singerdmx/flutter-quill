# Quill Overview
This document describes the most important files and classes in Quill.

## QUILL EDITOR, RENDER EDITOR, HANDLERS

**editor.dart**

`abstract EditorState extends State<RawEditor>`
- RawEditorState can be reference from QuillEditorState. This interface details several methods that are available from the mixins added to the RawEditor class.
- These methods are defined in the inherited classes from Flutter. So this Class helps us keep in mind several useful methods such as:
- showToolbar()
  - Triggers the mobile OS text selection toolbar.
- requestKeyboard()
  - Triggers the mobile OS keyboard
- getSelectionOverlay()

**abstract RenderAbstractEditor**
- Base interface for editable render objects
- Defines which methods the RenderEditor must implement
- Defined for the sake of documenting the most important operations
  Useful:
- selectWordAtPosition() selectLineAtPosition();
- getLocalRectForCaret() - Useful to enforce visibility of full caret at given position
- getPositionForOffset() getEndpointsForSelection()
- selectWordsInRange()
  - selectPositionAt()
- Selects text between coordinates
- selectWord()

**defaultEmbedBuilder()**

`BlockEmbed` &rarr; `Image, video or CustomEmbedBlock`
- It could be replaced with a custom implementation that supports all sorts of embeds (VS data types)
- Provided as argument in the QuillEditor instance

**QuillEditor**

- Gets the init params
  - Almost all the props that QuillEditor receives are passed to RawEditor
  - Basically QuillEditor is a wrapper that handles gestures and styling for the RawEditor
- Controller has the document, Controller will be passed to the RawEditor
- customStyleBuilder - Can override the styles of each attribute type.


`_QuillEditorState` &rarr; `EditorTextSelectionGestureDetectorBuilderDelegate`

`QuillEditorState` has a build method. This build method handles the assignment of styling depending on the current platform ios/android/web
QuillEditorState initialises a child named RawEditor

- `init()` it inits EditorTextSelectionGestureDetectorBuilder

  Keeps the delegate as a reference to _QuillEditorState
  From a global key we can get the current state (to read the state values, somewhat a counterpattern)
  EditorState? get editor => delegate.editableTextKey.currentState;

  Get the render editor from the state
  RenderEditor? get renderEditor => editor?.renderEditor;

- `build()`
  - `selectionColor` &rarr; Controls the color of the selection
- The local theme controls the selectionColor and the CursorColor
- In the end it returns the RawEditor wrapped in the gestureDetector
  - `getEditableTextKey()` - Reference to the editor widget key

`_QuillEditorSelectionGestureDetectorBuilder`
- `_onTapping()` - Searches for the Line. Attempts to update the selection. 
If not possible it fallbacks to a few platform dependent scenarios. Invoked by `onSingleTapUp()`
- `onSingleTapUp()` - override


TextSelectionChangedHandler



**RenderEditor**

Contains some extremely useful methods for handling the coordinates of words inside of the rendered document.
There methods are pivotal for synchronising the position of inline reactions to the quill editor

	class RenderEditor extends RenderEditableContainerBox
	with RelayoutWhenSystemFontsChangeMixin
	implements RenderAbstractEditor {


- onSelectionChanged()
- ViewportOffset? offset
- _updateSelectionExtentsVisibility()
  - React to selection changes
- startOffset, endOffset, _getOffsetForCaret()
  - Selection coordinates
- _getOffsetForCaret()
- size - Dimensions of the render box from Flutter.
- setDocument()
- setSelection()
  - getEndpointsForSelection() - Selection coordinates
- handleDragStart() handleDragEnd()
  - selectWordsInRange() &rarr; _handleSelectionChange()
- _paintHandleLayers - text selection handles on mobile
  - getPositionForOffset() - Gets us the text position (chars) from offset
- getOffsetToRevealCursor() - Used to reveal the cursor if scrolled
  - getWordBoundary() - Word boundary from click

**RenderEditableContainerBox** &rarr; RenderBox (dimensions) &rarr; RenderBoxContainerDefaultsMixin (HitTest) &rarr; RenderBoxContainerDefaultsMixin (add remove children)
- performLayout() - builds the layout dimensions for the widget &rarr; Called in many places
- childAtPosition() - Gets the child at TextPosition.


**controller.dart**

Embeds can be introduced as Embedabble via the controller, not only Quill. This method can be tracked to understand how to add topic from state store.

### QuillController
- updateSelection()
- addListener() - START UPDATE
- These methods are used to inform many parts of Quill that the controller state has changed
- This means we don't use ChangeNotifierProvider
- 15 listeners in total
- 12 for the buttons, stuff outside of Quill
- 1 for scroll arrows (if to show them)
- RawEditorState init and update listen _didChangeTextEditingValue &rarr; _onChangeTextEditingValue
- updateRemoteValueIfNeeded - When apps are sent into the background, the view ref is lost, when restoring the java code loses the state of the input.
- _showCaretOnScreen - Scrolls to show the carpet on screen
- start timer for blinking caret
- addPostFrameCallback - To be able to account for new lines of text when rendering the selection overlay
  - _updateOrDisposeSelectionOverlayIfNeeded - Updates the mobile context menu. We can show here the text selection menu as well (ideally with middleware override).
  EditorTextSelectionOverlay - An object that manages a pair of text selection handles.
- setState &rarr; Build &rarr; _Editor

### notifyListeners
- history change
- replace text
- format text
- update selection

- addListener, removeListener


**toolbar.dart**

Quill editors can have a Toolbar connected. The toolbar commands the controller which in turn commands the Document which commands the Renderer.
The toolbar can be customized to show all or part of the editing controls/buttons.
The Toolbar offers callbacks for reacting to adding images or videos.
For our own custom embeds we don't have to define extra callback here on the Toolbar context. We can host the logic in our own custom embeds (they are part of our own codebase).


**quill_icon_button.dart**

If we want to create more similar buttons for the Toolbar

**delegate.dart**

`EditorTextSelectionGestureDetectorBuilderDelegate` - Signatures for the methods that the EditableText (QuillEditor) must define to be able to run gesture detector
- `getEditableTextKey()`
  - EditableText is the delegate.
  - EditableText comes from Flutter
  - The key is the editor widget key.
  - The key is used to get the state.
  - In the state we have RenderEditor.


###  RAW EDITOR

**raw_editor.dart**
- Displays a document as a vertical list of document segments (lines and blocks)
  **RawEditorState** extends **EditorState**
    - Defines overrides and listener for all the exposed internal that were added by the mixing
    - Clipboard management, Keyboard management, Document changes management, Gestures Management
    - RawEditorState can be referenced from QuillEditorState.
    - EditorState interface details several methods that are available from the mixins added to the RawEditor class.

with `AutomaticKeepAliveClientMixin<RawEditor>`
- Indicates that the subtree through which this notification bubbles must be kept alive even if it would normally be discarded as an optimization.
- For example, a focused text field might fire this notification to indicate that it should not be disposed even if the user scrolls the field off screen.

WidgetsBindingObserver
- Notifies when new routes are pushed or poped such that the app can react accordingly (for ex if the app exits)

TickerProviderStateMixin<RawEditor>
- Synchronizes the animations of the widget with all other animations so that they can all complete before the new frame is to be rendered

RawEditorStateTextInputClientMixin
- Connector that links the editor to the Mobile keyboard

`RawEditorStateSelectionDelegateMixin`
- A mixin that controls text insertion operations. It is a delegate for Flutter's TextSelection.
- it can override the setter for `textEditingValue()`
  - It intercepts copy paste ops from the system, it commands the QuillEditor controller to run the necessary changes. 
  - In other words, that's how Quill knows how to react to text editing ops coming from the system (user input). 
 
`_getOffsetToRevealCaret()`
 - Finds the closest scroll offset to the current scroll offset that fully reveals the given caret rect. 
 - If the given rect's main axis extent is too large to be fully revealed in `renderEditable`, it will be centered along the main axis.



- build()
    - If no delta document is available an empty one will be created
    - If expanded true it builds an _Editor wrapped with Semantics and CompositedTransformTarget
        - Semantics is used for screen readers
        - CompositedTransformTarget - Hooks the custom widget into the mechanics of layout rendering and calculation of dimensions (Flutter).
        - Why CompositedTransformTarget? - Because Quill uses a custom renderer to render the document (for performance reasons)

    - If not expanded (meaning scrollable) it wraps the _editor with BaselineProxy QuillSingleChildScrollView and CompositedTransformTarget
      Since [SingleChildScrollView] does not implement `computeDistanceToActualBaseline` it prevents the editor from providing its baseline metrics.
      To address this issue we wrap the scroll view with [BaselineProxy] which mimics the editor's baseline.
      This implies that the first line has no styles applied to it.
      Why is computeDistanceToActualBaseline needed?
      If my intuition is right this is needed to scroll the page the right amount to offset the scroll to match the off screen selected text line when the carpet is moved.
      It computes the distance from top to the baseline of the first text. First text out of first editable text. I'll explain bellow, there are more lines of text in a Quill doc.

    - Nested in the _Editor we have the _buildChildren(_doc, context)
      This method loops trough the delta breaks it into text lines and text blocks and renders the corresponding children
      From here on the works of rendering the text starts

    - Finally the whole thing is wrapped in QuillStyles, Actions, Focus, QuillKeyboardListener and returned for the build()
        - Actions are callbacks registered to respond on Intents (Flutter alternative to callbacks)
          - _updateOrDisposeSelectionOverlayIfNeeded()
- Triggers the selection context menu on mobiles
- _selectionOverlay = EditorTextSelectionOverlay()
- _handleSelectionChanged()
  &rarr; widget.controller.updateSelection() Updates the state of the selection in memory (no visual change)
  &rarr; _selectionOverlay?.handlesVisible
- _buildChildren()
- compiles the list of nodes to be render as TextLine or TextBlock from the controller.document
- This is where we pass the embedBuilder to the block

**_Editor** extends **MultiChildRenderObjectWidget**
After all these layers: Gesture detectors, mixins, scrolls, actions, etc we finally arrive at the layer that handles the edit operations.
_Render creates and updates the RenderEditor which is basically the custom RenderBox that handles the coordination between multiple line models.
For example the RenderEditor knows how to coordinate multiple lines to draw a selection of text between them. It commands their widgets to render the correct selections.
This is where we need to add our own code for rendering multiple highlights. It queries and coordinates both the models and the render boxes.
MultiChildRenderObjectWidget takes the duty of rendering the line and block widgets that were created by the _buildChildren()



### Intents to Actions map

Flutter has a system of dispatching Intents when hotkeys are pressed and then Actions that react to these intents.
Actions can decide if they are enabled or not. This system is an alternative to callbacks.
https://docs.flutter.dev/development/ui/advanced/actions_and_shortcuts

Earlier it is mentioned that the `_Editor` is wrapped in Actions. Well this is the map it uses.
All these actions receive TextSelection and react to it by commanding the Controller.
```
DoNothingAndStopPropagationTextIntent
ReplaceTextIntent
UpdateSelectionIntent
DirectionalFocusIntent

// Delete
DeleteCharacterIntent
DeleteToNextWordBoundaryIntent
DeleteToLineBreakIntent

// Extend/Move Selection
ExtendSelectionByCharacterIntent
ExtendSelectionToNextWordBoundaryIntent
ExtendSelectionToLineBreakIntent
ExtendSelectionVerticallyToAdjacentLineIntent
ExtendSelectionToDocumentBoundaryIntent
ExtendSelectionToNextWordBoundaryOrCaretLocationIntent

// Copy Paste
SelectAllTextIntent
CopySelectionTextIntent
PasteTextIntent
```

**quill_single_child_scroll_view.dart**

`QuillSingleChildScrollView`

Very similar to `SingleChildView` but with a `ViewportBuilder` argument instead of a `Widget` &rarr; Meaning it can scroll over the CompositedTransformTarget instead of Widgets
A `ScrollController` serves several purposes.
It can be used to control the initial scroll position (see `ScrollController.initialScrollOffset`).
It can be used to control whether the scroll view should automatically save and restore its scroll position in the `PageStorage` (see `ScrollController.keepScrollOffset`).
It can be used to read the current scroll position (see `ScrollController.offset`), or change it (see `ScrollController.animateTo`)

showOnScreen() &rarr; The most important method here. It is invoked in several scenarios to expose the selected text on screen of off-page.
Now since our ArticlePage uses several stacked expanded editors (due to post topics) we don't use at all the scrolling behaviour.
If we wanted to use the scroll behaviour from Quill that means we would have to make the entire post topic together with the article topic.
It means one could copy paste the post topics to the bottom of the article which makes absolutely no sense. So therefore we have to handle this part ourselves.
And since the Article and topics are scrolled together by a greater scroll controller we are force to render the article editor as well in the expanded mode.
That make our situation a bit harder because we might have to redo some of the work needed to bring the selected text back into view when moving the carpet.
This is a luxury item for the moment, we don't care of this feature missing in the MVP. So no panic if we don't use the QuillEditorScroll.


`_Editor`
- A container with lifecycle calls create and update for RenderBoxes (RenderEditor)
- createRenderObject() updateRenderObject() &rarr; RenderEditor


**text_line.dart**

Callstack: `RawEditorState()` &rarr; `_buildChildren()` &rarr; `_getEditableTextLineFromNode()`
&rarr; `EditableTextLine()` &rarr; `_TextLineElement()` &rarr; `RenderEditableTextLine()` &rarr; `TextLine()` &rarr; `RichTextProxy()` &rarr; `RenderParagraphProxy` extends `RenderProxyBox` (we will talk proxy boxes separately)

When the rawEditor builds the children it uses 2 types of widgets: lines and blocks.
Bellow we will discuss how lines are renders. Blocks reuse lines.
Blocks are rendered for special graphical elements such as bullet lists.

`TextLine`

This is the actual line of text being rendered on screen. It uses editable text from flutter to render a basic text input.
Renders the proper text styling based on the delta text styling attributes. Contains lost of methods to accomplish this job.
This widget is rendered inside of an EditableTextLine as a child by the _getEditableTextLineFromNode() from RawEditor.
The widget itself renders a proxBox.
The EditableTextLine uses RenderEditableTextLine to render the highlight and caret on top of the raw text field.

`EditableTextLine`
- Creates and updates render objects base on the instructions received from the delta document.
- Passes the props to RenderEditableTextLine
  createRenderObject() &rarr; RenderEditableTextLine

`RenderEditableTextLine`

Creates new editable paragraph render box.
It contains many methods needed to coordinate imperatively how the text selection and caret sync with the document controller state.
This is where the hardwork of rendering and simulating the text interactions mechanics is happening.

Here's a list of methods to get a feeling of what happens in `RenderEditableTextLine`:

Most of these methods are wrappers over the TextLine (body) &rarr; They get their coordinates by querying the underlying text input.

setCursorCont()
setDevicePixelRatio()
setEnableInteractiveSelection()
setColor()
setTextSelection()
setLine() - The actual delta text content
setPadding()
containsTextSelection()
containsCursor()
getLineBoundary()
getOffsetForCaret()
getPositionForOffset()
getWordBoundary()
attach(), detach() &rarr; _onFloatingCursorChange
compute Min/Max Intrinsic Height/Width()
computeDistanceToActualBaseline()
performLayout() &rarr; Flutter layouting

#### Drawing text selection

For rendering custom highlights we are most interested in these methods:
- paint()
    - Draws the one of text and it's decorations. Custom decorations can be added.
    - It uses the offset of the parent (based on layout constraints) and the ofset of the text selection
- _paintSelection()
  - Handles the rendering of the selection
- Selection is rendered as new boxes in the paint area (RenderBox)- They can even have an offset
- Paints the _selectedRects
- draw cursor (above and bellow)
- By default, the cursor should be painted on top for iOS platforms and underneath for Android platforms.
- _selectedRects - The individual render boxes that compose a multiline selection
- getBoxesForSelection() &rarr; local TextSelection - Converts TextSelection to boxes coordinates
- list of TextBox.fromLTRBD (Flutter class)
- localSelection() does some sort of a conversion
  - setTextSelection() - Updates the text selection and clears the rect boxes
- if _attachedToCursorController it is marked for markNeedsLayout markNeedsPaint
- The cursor controller is defined for text fields, it is a change notifier and can be listened to
- When the text cursor changes position also the text selection will need to be repainted

`_TextLineElement` extends `enderObjectElement`
contains methods needed to sync the renderObject in the widget tree


**proxy.dart**

All sorts of rendering proxies for the items that can be rendered in Quill.
A proxy box isn't useful on its own because you might as well just replace the proxy box with its child.
However, RenderProxyBox is a useful base class for render objects that wish to mimic most, but not all, of the properties of their child.

For render objects with children, there are four possible scenarios:
* A single [RenderBox] child. In this scenario, consider inheriting from
  [RenderProxyBox] (if the render object sizes itself to match the child) or
  [RenderShiftedBox] (if the child will be smaller than the box and the box
  will align the child inside itself).
* A single child, but it isn't a [RenderBox]. Use the
  [RenderObjectWithChildMixin] mixin.
* A single list of children. Use the [ContainerRenderObjectMixin] mixin.
* A more complicated child model.
  https://programmer.group/the-operation-instruction-of-flutter-s-renderbox-principle-analysis.html

`RenderBaselineProxy` - Renders the scrollable input
`RenderEmbedProxy` - Renders embeds
`RichTextProxy` - rich text
`RenderParagraphProxy` - RenderProxyBox - Mimics it's children
`getBoxesForSelection()` - This code is used from Flutter


**models/quill_delta.dart**
- Container various utils for handling delta text
  - insert
- skip
- retain
  - slice - This might be super useful for splitting docs
- concat
  - diff
- delta.insert('\n' - used to add new character &rarr; Could be used to split our deltas
- DeltaIterator(document)..skip(index) - Skips [length] characters in source delta.
- Delta()..retain - Retain [count] of characters from current position.
- _trimNewLine() - Removes trailing '\n'

**text_selection.dart**

`EditorTextSelectionOverlay`
- Represents the selection overlay object (the highlight)
- It also renders the mobile actions menu and handles. This is from the system.


**document.dart**

The Document contains the Delta which contains all the operations. Inside operations we can find attributes. The attributes are useful for examining the text.

- These methods are extremely useful
  - insert &rarr; Can insert embeddable, Can replace selected text
  - delete
- replace
- format
- undo, hasUndo
- redo, hasRedo
- toPlainText
- isEmpty
- toDelta
- setCustomRules -&rarr; Could be extremely useful because we can edit the text editor each time something outstanding happens

**/rules**
- Contain business logic for handling operations and delta modifications
  - PreserveLineStyleOnSplitRule - Preserves the style to the split line

**node.dart**

An abstract node in a document tree.
Represents a segment of a Quill document with specified offset and length. The offset property is relative to parent.
See also documentOffset which provides absolute offset of this node within the document.