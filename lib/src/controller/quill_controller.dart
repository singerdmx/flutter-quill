import 'dart:math' as math;

import 'package:flutter/services.dart' show ClipboardData, Clipboard;
import 'package:flutter/widgets.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:meta/meta.dart' show experimental;

import '../../quill_delta.dart';
import '../common/structs/image_url.dart';
import '../common/structs/offset_value.dart';
import '../common/utils/embeds.dart';
import '../delta/delta_diff.dart';
import '../delta/delta_x.dart';
import '../document/attribute.dart';
import '../document/document.dart';
import '../document/nodes/embeddable.dart';
import '../document/nodes/leaf.dart';
import '../document/structs/doc_change.dart';
import '../document/style.dart';
import '../editor/config/editor_configurations.dart';
import '../editor_toolbar_controller_shared/clipboard/clipboard_service_provider.dart';
import '../toolbar/config/simple_toolbar_configurations.dart';
import 'quill_controller_configurations.dart';

typedef ReplaceTextCallback = bool Function(int index, int len, Object? data);
typedef DeleteCallback = void Function(int cursorPosition, bool forward);

class QuillController extends ChangeNotifier {
  QuillController({
    required Document document,
    required TextSelection selection,
    this.configurations = const QuillControllerConfigurations(),
    this.keepStyleOnNewLine = true,
    this.onReplaceText,
    this.onDelete,
    this.onSelectionCompleted,
    this.onSelectionChanged,
    this.readOnly = false,
    this.editorFocusNode,
  })  : _document = document,
        _selection = selection;

  factory QuillController.basic(
          {QuillControllerConfigurations configurations =
              const QuillControllerConfigurations(),
          FocusNode? editorFocusNode}) =>
      QuillController(
        configurations: configurations,
        editorFocusNode: editorFocusNode,
        document: Document(),
        selection: const TextSelection.collapsed(offset: 0),
      );

  final QuillControllerConfigurations configurations;

  /// Editor configurations
  ///
  /// Caches configuration set in QuillEditor ctor.
  QuillEditorConfigurations? _editorConfigurations;
  QuillEditorConfigurations get editorConfigurations =>
      _editorConfigurations ?? const QuillEditorConfigurations();
  set editorConfigurations(QuillEditorConfigurations? value) =>
      _editorConfigurations = document.editorConfigurations = value;

  /// Toolbar configurations
  ///
  /// Caches configuration set in QuillSimpleToolbar ctor.
  QuillSimpleToolbarConfigurations? _toolbarConfigurations;
  QuillSimpleToolbarConfigurations get toolbarConfigurations =>
      _toolbarConfigurations ?? const QuillSimpleToolbarConfigurations();
  set toolbarConfigurations(QuillSimpleToolbarConfigurations? value) =>
      _toolbarConfigurations = value;

  /// Document managed by this controller.
  Document _document;

  Document get document => _document;

  set document(Document doc) {
    _document = doc;
    _document.editorConfigurations = editorConfigurations;

    // Prevent the selection from
    _selection = const TextSelection(baseOffset: 0, extentOffset: 0);

    notifyListeners();
  }

  @experimental
  void setContents(
    Delta delta, {
    ChangeSource changeSource = ChangeSource.local,
  }) {
    final newDocument = Document.fromDelta(delta);

    final change = DocChange(_document.toDelta(), delta, changeSource);
    newDocument.documentChangeObserver.add(change);
    newDocument.history.handleDocChange(change);

    _document = newDocument;
    notifyListeners();
  }

  /// Tells whether to keep or reset the [toggledStyle]
  /// when user adds a new line.
  final bool keepStyleOnNewLine;

  /// Currently selected text within the [document].
  TextSelection get selection => _selection;
  TextSelection _selection;

  /// Custom [replaceText] handler
  /// Return false to ignore the event
  ReplaceTextCallback? onReplaceText;

  /// Custom delete handler
  DeleteCallback? onDelete;

  void Function()? onSelectionCompleted;
  void Function(TextSelection textSelection)? onSelectionChanged;

  /// Store any styles attribute that got toggled by the tap of a button
  /// and that has not been applied yet.
  /// It gets reset after each format action within the [document].
  Style toggledStyle = const Style();

  /// [raw_editor_actions] handling of backspace event may need to force the style displayed in the toolbar
  void forceToggledStyle(Style style) {
    toggledStyle = style;
    notifyListeners();
  }

  bool ignoreFocusOnTextChange = false;

  /// Skip requestKeyboard being called in
  /// RawEditorState#_didChangeTextEditingValue
  bool skipRequestKeyboard = false;

  /// True when this [QuillController] instance has been disposed.
  ///
  /// A safety mechanism to ensure that listeners don't crash when adding,
  /// removing or listeners to this instance.
  bool _isDisposed = false;

  Stream<DocChange> get changes => document.changes;

  TextEditingValue get plainTextEditingValue => TextEditingValue(
        text: document.toPlainText(),
        selection: selection,
      );

  /// Only attributes applied to all characters within this range are
  /// included in the result.
  Style getSelectionStyle() {
    return document
        .collectStyle(selection.start, selection.end - selection.start)
        .mergeAll(toggledStyle);
  }

  // Increases or decreases the indent of the current selection by 1.
  void indentSelection(bool isIncrease) {
    if (selection.isCollapsed) {
      _indentSelectionFormat(isIncrease);
    } else {
      _indentSelectionEachLine(isIncrease);
    }
  }

  void _indentSelectionFormat(bool isIncrease) {
    final indent = getSelectionStyle().attributes[Attribute.indent.key];
    if (indent == null) {
      if (isIncrease) {
        formatSelection(Attribute.indentL1);
      }
      return;
    }
    if (indent.value == 1 && !isIncrease) {
      formatSelection(Attribute.clone(Attribute.indentL1, null));
      return;
    }
    if (isIncrease) {
      if (indent.value < 5) {
        formatSelection(Attribute.getIndentLevel(indent.value + 1));
      }
      return;
    }
    formatSelection(Attribute.getIndentLevel(indent.value - 1));
  }

  void _indentSelectionEachLine(bool isIncrease) {
    final styles = document.collectAllStylesWithOffset(
      selection.start,
      selection.end - selection.start,
    );
    for (final style in styles) {
      final indent = style.value.attributes[Attribute.indent.key];
      final formatIndex = math.max(style.offset, selection.start);
      final formatLength = math.min(
            style.offset + (style.length ?? 0),
            selection.end,
          ) -
          style.offset;
      Attribute? formatAttribute;
      if (indent == null) {
        if (isIncrease) {
          formatAttribute = Attribute.indentL1;
        }
      } else if (indent.value == 1 && !isIncrease) {
        formatAttribute = Attribute.clone(Attribute.indentL1, null);
      } else if (isIncrease) {
        if (indent.value < 5) {
          formatAttribute = Attribute.getIndentLevel(indent.value + 1);
        }
      } else {
        formatAttribute = Attribute.getIndentLevel(indent.value - 1);
      }
      if (formatAttribute != null) {
        document.format(formatIndex, formatLength, formatAttribute);
      }
    }
    notifyListeners();
  }

  /// Returns all styles and Embed for each node within selection
  List<OffsetValue> getAllIndividualSelectionStylesAndEmbed() {
    final stylesAndEmbed = document.collectAllIndividualStyleAndEmbed(
        selection.start, selection.end - selection.start);
    return stylesAndEmbed;
  }

  /// Returns plain text for each node within selection
  String getPlainText() {
    final text =
        document.getPlainText(selection.start, selection.end - selection.start);
    return text;
  }

  /// Returns all styles for any character within the specified text range.
  List<Style> getAllSelectionStyles() {
    final styles = document.collectAllStyles(
        selection.start, selection.end - selection.start)
      ..add(toggledStyle);
    return styles;
  }

  void undo() {
    final result = document.undo();
    if (result.changed) {
      _handleHistoryChange(result.len);
    }
  }

  void _handleHistoryChange(int len) {
    updateSelection(
      TextSelection.collapsed(
        offset: len,
      ),
      ChangeSource.local,
    );
  }

  void redo() {
    final result = document.redo();
    if (result.changed) {
      _handleHistoryChange(result.len);
    }
  }

  bool get hasUndo => document.hasUndo;

  bool get hasRedo => document.hasRedo;

  /// clear editor
  void clear() {
    replaceText(0, plainTextEditingValue.text.length - 1, '',
        const TextSelection.collapsed(offset: 0));
  }

  void replaceText(
    int index,
    int len,
    Object? data,
    TextSelection? textSelection, {
    bool ignoreFocus = false,
    bool shouldNotifyListeners = true,
  }) {
    assert(data is String || data is Embeddable || data is Delta);

    if (onReplaceText != null && !onReplaceText!(index, len, data)) {
      return;
    }

    Delta? delta;
    Style? style;
    if (len > 0 || data is! String || data.isNotEmpty) {
      delta = document.replace(index, len, data);

      /// Remove block styles as they can only be attached to line endings
      style = Style.attr(Map<String, Attribute>.fromEntries(toggledStyle
          .attributes.entries
          .where((a) => a.value.scope != AttributeScope.block)));
      var shouldRetainDelta = style.isNotEmpty &&
          delta.isNotEmpty &&
          delta.length <= 2 &&
          delta.last.isInsert;
      if (shouldRetainDelta &&
          style.isNotEmpty &&
          delta.length == 2 &&
          delta.last.data == '\n') {
        // if all attributes are inline, shouldRetainDelta should be false
        final anyAttributeNotInline =
            style.values.any((attr) => !attr.isInline);
        if (!anyAttributeNotInline) {
          shouldRetainDelta = false;
        }
      }
      if (shouldRetainDelta) {
        final retainDelta = Delta()
          ..retain(index)
          ..retain(data is String ? data.length : 1, style.toJson());
        document.compose(retainDelta, ChangeSource.local);
      }
    }

    if (textSelection != null) {
      if (delta == null || delta.isEmpty) {
        _updateSelection(textSelection);
      } else {
        final user = Delta()
          ..retain(index)
          ..insert(data)
          ..delete(len);
        final positionDelta = getPositionDelta(user, delta);
        _updateSelection(
            textSelection.copyWith(
              baseOffset: textSelection.baseOffset + positionDelta,
              extentOffset: textSelection.extentOffset + positionDelta,
            ),
            insertNewline: data == '\n');
      }
    }

    if (ignoreFocus) {
      ignoreFocusOnTextChange = true;
    }
    if (shouldNotifyListeners) {
      notifyListeners();
    }
    ignoreFocusOnTextChange = false;
  }

  /// Called in two cases:
  /// forward == false && textBefore.isEmpty
  /// forward == true && textAfter.isEmpty
  /// Android only
  /// see https://github.com/singerdmx/flutter-quill/discussions/514
  void handleDelete(int cursorPosition, bool forward) =>
      onDelete?.call(cursorPosition, forward);

  void formatTextStyle(int index, int len, Style style) {
    style.attributes.forEach((key, attr) {
      formatText(index, len, attr);
    });
  }

  void formatText(
    int index,
    int len,
    Attribute? attribute, {
    bool shouldNotifyListeners = true,
  }) {
    if (len == 0 &&
        attribute!.isInline &&
        attribute.key != Attribute.link.key) {
      // Add the attribute to our toggledStyle.
      // It will be used later upon insertion.
      toggledStyle = toggledStyle.put(attribute);
    }

    final change = document.format(index, len, attribute);
    // Transform selection against the composed change and give priority to
    // the change. This is needed in cases when format operation actually
    // inserts data into the document (e.g. embeds).
    final adjustedSelection = selection.copyWith(
        baseOffset: change.transformPosition(selection.baseOffset),
        extentOffset: change.transformPosition(selection.extentOffset));
    if (selection != adjustedSelection) {
      _updateSelection(adjustedSelection);
    }
    if (shouldNotifyListeners) {
      notifyListeners();
    }
  }

  void formatSelection(Attribute? attribute,
      {bool shouldNotifyListeners = true}) {
    formatText(
      selection.start,
      selection.end - selection.start,
      attribute,
      shouldNotifyListeners: shouldNotifyListeners,
    );
  }

  void moveCursorToStart() {
    updateSelection(
      const TextSelection.collapsed(offset: 0),
      ChangeSource.local,
    );
  }

  void moveCursorToPosition(int position) {
    updateSelection(
      TextSelection.collapsed(offset: position),
      ChangeSource.local,
    );
  }

  void moveCursorToEnd() {
    updateSelection(
      TextSelection.collapsed(offset: plainTextEditingValue.text.length),
      ChangeSource.local,
    );
  }

  void updateSelection(TextSelection textSelection, ChangeSource source) {
    _updateSelection(textSelection);
    notifyListeners();
  }

  void compose(Delta delta, TextSelection textSelection, ChangeSource source) {
    if (delta.isNotEmpty) {
      document.compose(delta, source);
    }

    textSelection = selection.copyWith(
      baseOffset: delta.transformPosition(selection.baseOffset, force: false),
      extentOffset: delta.transformPosition(
        selection.extentOffset,
        force: false,
      ),
    );
    if (selection != textSelection) {
      _updateSelection(textSelection);
    }

    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    // By using `_isDisposed`, make sure that `addListener` won't be called on a
    // disposed `ChangeListener`
    if (!_isDisposed) {
      super.addListener(listener);
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    // By using `_isDisposed`, make sure that `removeListener` won't be called
    // on a disposed `ChangeListener`
    if (!_isDisposed) {
      super.removeListener(listener);
    }
  }

  @override
  void dispose() {
    if (!_isDisposed) {
      document.close();
    }

    _isDisposed = true;
    super.dispose();
  }

  void _updateSelection(TextSelection textSelection,
      {bool insertNewline = false}) {
    _selection = textSelection;
    final end = document.length - 1;
    _selection = selection.copyWith(
        baseOffset: math.min(selection.baseOffset, end),
        extentOffset: math.min(selection.extentOffset, end));
    if (keepStyleOnNewLine) {
      if (insertNewline && selection.start > 0) {
        final style = document.collectStyle(selection.start - 1, 0);
        final ignoredStyles = style.attributes.values.where(
          (s) => !s.isInline || s.key == Attribute.link.key,
        );
        toggledStyle = style.removeAll(ignoredStyles.toSet());
      } else {
        toggledStyle = const Style();
      }
    } else {
      toggledStyle = const Style();
    }
    onSelectionChanged?.call(textSelection);
  }

  /// Given offset, find its leaf node in document
  Leaf? queryNode(int offset) {
    return document.querySegmentLeafNode(offset).leaf;
  }

  // Notify toolbar buttons directly with attributes
  Map<String, Attribute> toolbarButtonToggler = const {};

  /// Clipboard caches last copy to allow paste with styles. Static to allow paste between multiple instances of editor.
  static String _pastePlainText = '';
  static Delta _pasteDelta = Delta();
  static List<OffsetValue> _pasteStyleAndEmbed = <OffsetValue>[];

  String get pastePlainText => _pastePlainText;
  Delta get pasteDelta => _pasteDelta;
  List<OffsetValue> get pasteStyleAndEmbed => _pasteStyleAndEmbed;

  bool readOnly;

  /// Used to give focus to the editor following a toolbar action
  FocusNode? editorFocusNode;

  ImageUrl? _copiedImageUrl;
  ImageUrl? get copiedImageUrl => _copiedImageUrl;

  set copiedImageUrl(ImageUrl? value) {
    _copiedImageUrl = value;
    Clipboard.setData(const ClipboardData(text: ''));
  }

  bool clipboardSelection(bool copy) {
    copiedImageUrl = null;

    /// Get the text for the selected region and expand the content of Embedded objects.
    _pastePlainText = document.getPlainText(
        selection.start, selection.end - selection.start, true);

    /// Get the internal representation so it can be pasted into a QuillEditor with style retained.
    _pasteStyleAndEmbed = getAllIndividualSelectionStylesAndEmbed();

    /// Get the deltas for the selection so they can be pasted into a QuillEditor with styles and embeds retained.
    _pasteDelta = document.toDelta().slice(selection.start, selection.end);

    if (!selection.isCollapsed) {
      Clipboard.setData(ClipboardData(text: _pastePlainText));
      if (!copy) {
        if (readOnly) return false;
        final sel = selection;
        replaceText(sel.start, sel.end - sel.start, '',
            TextSelection.collapsed(offset: sel.start));
      }
      return true;
    }
    return false;
  }

  /// Returns whether paste operation was handled here.
  /// updateEditor is called if paste operation was successful.
  Future<bool> clipboardPaste({void Function()? updateEditor}) async {
    if (readOnly || !selection.isValid) return true;

    final pasteUsingInternalImageSuccess = await _pasteInternalImage();
    if (pasteUsingInternalImageSuccess) {
      updateEditor?.call();
      return true;
    }

    final pasteUsingHtmlSuccess = await _pasteHTML();
    if (pasteUsingHtmlSuccess) {
      updateEditor?.call();
      return true;
    }

    final pasteUsingMarkdownSuccess = await _pasteMarkdown();
    if (pasteUsingMarkdownSuccess) {
      updateEditor?.call();
      return true;
    }

    // Snapshot the input before using `await`.
    // See https://github.com/flutter/flutter/issues/11427
    final plainTextClipboardData =
        await Clipboard.getData(Clipboard.kTextPlain);
    if (pasteUsingPlainOrDelta(plainTextClipboardData?.text)) {
      updateEditor?.call();
      return true;
    }

    if (await configurations.onClipboardPaste?.call() == true) {
      updateEditor?.call();
      return true;
    }

    return false;
  }

  /// Internal method to allow unit testing
  bool pasteUsingPlainOrDelta(String? clipboardText) {
    if (clipboardText != null) {
      /// Internal copy-paste preserves styles and embeds
      if (clipboardText == _pastePlainText &&
          _pastePlainText.isNotEmpty &&
          _pasteDelta.isNotEmpty) {
        replaceText(selection.start, selection.end - selection.start,
            _pasteDelta, TextSelection.collapsed(offset: selection.end));
      } else {
        replaceText(
            selection.start,
            selection.end - selection.start,
            clipboardText,
            TextSelection.collapsed(
                offset: selection.end + clipboardText.length));
      }
      return true;
    }
    return false;
  }

  void _pasteUsingDelta(Delta deltaFromClipboard) {
    replaceText(
      selection.start,
      selection.end - selection.start,
      deltaFromClipboard,
      TextSelection.collapsed(offset: selection.end),
    );
  }

  /// Return true if can paste internal image
  Future<bool> _pasteInternalImage() async {
    final copiedImageUrl = _copiedImageUrl;
    if (copiedImageUrl != null) {
      final index = selection.baseOffset;
      final length = selection.extentOffset - index;
      replaceText(
        index,
        length,
        BlockEmbed.image(copiedImageUrl.url),
        null,
      );
      if (copiedImageUrl.styleString.isNotEmpty) {
        formatText(
          getEmbedNode(this, index + 1).offset,
          1,
          StyleAttribute(copiedImageUrl.styleString),
        );
      }
      _copiedImageUrl = null;
      await Clipboard.setData(
        const ClipboardData(text: ''),
      );
      return true;
    }
    return false;
  }

  /// Return true if can paste using HTML
  Future<bool> _pasteHTML() async {
    final clipboardService = ClipboardServiceProvider.instance;

    Future<String?> getHTML() async {
      if (await clipboardService.canProvideHtmlTextFromFile()) {
        return await clipboardService.getHtmlTextFromFile();
      }
      if (await clipboardService.canProvideHtmlText()) {
        return await clipboardService.getHtmlText();
      }
      return null;
    }

    final htmlText = await getHTML();
    if (htmlText != null) {
      final htmlBody = html_parser.parse(htmlText).body?.outerHtml;
      // ignore: deprecated_member_use_from_same_package
      final deltaFromClipboard = DeltaX.fromHtml(htmlBody ?? htmlText);

      _pasteUsingDelta(deltaFromClipboard);

      return true;
    }
    return false;
  }

  /// Return true if can paste using Markdown
  Future<bool> _pasteMarkdown() async {
    final clipboardService = ClipboardServiceProvider.instance;

    Future<String?> getMarkdown() async {
      if (await clipboardService.canProvideMarkdownTextFromFile()) {
        return await clipboardService.getMarkdownTextFromFile();
      }
      if (await clipboardService.canProvideMarkdownText()) {
        return await clipboardService.getMarkdownText();
      }
      return null;
    }

    final markdownText = await getMarkdown();
    if (markdownText != null) {
      // ignore: deprecated_member_use_from_same_package
      final deltaFromClipboard = DeltaX.fromMarkdown(markdownText);

      _pasteUsingDelta(deltaFromClipboard);

      return true;
    }
    return false;
  }

  void replaceTextWithEmbeds(
    int index,
    int len,
    String insertedText,
    TextSelection? textSelection, {
    bool ignoreFocus = false,
    bool shouldNotifyListeners = true,
  }) {
    final containsEmbed =
        insertedText.codeUnits.contains(Embed.kObjectReplacementInt);
    insertedText =
        containsEmbed ? _adjustInsertedText(insertedText) : insertedText;

    replaceText(index, len, insertedText, textSelection,
        ignoreFocus: ignoreFocus, shouldNotifyListeners: shouldNotifyListeners);

    _applyPasteStyleAndEmbed(insertedText, index, containsEmbed);
  }

  void _applyPasteStyleAndEmbed(
      String insertedText, int start, bool containsEmbed) {
    if (insertedText == pastePlainText && pastePlainText != '' ||
        containsEmbed) {
      final pos = start;
      for (final p in pasteStyleAndEmbed) {
        final offset = p.offset;
        final styleAndEmbed = p.value;

        final local = pos + offset;
        if (styleAndEmbed is Embeddable) {
          replaceText(local, 0, styleAndEmbed, null);
        } else {
          final style = styleAndEmbed as Style;
          if (style.isInline) {
            formatTextStyle(local, p.length!, style);
          } else if (style.isBlock) {
            final node = document.queryChild(local).node;
            if (node != null && p.length == node.length - 1) {
              for (final attribute in style.values) {
                document.format(local, 0, attribute);
              }
            }
          }
        }
      }
    }
  }

  String _adjustInsertedText(String text) {
    final sb = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) == Embed.kObjectReplacementInt) {
        continue;
      }
      sb.write(text[i]);
    }
    return sb.toString();
  }
}
