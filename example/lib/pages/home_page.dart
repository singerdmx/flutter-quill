import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/plugins/plugin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';

import '../plugins/notes_plugin.dart';
import '../plugins/table_plugin.dart';
import '../shortcuts/edit_shortcuts.dart';
import '../universal_ui/universal_ui.dart';
import 'read_only_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  QuillController? _controller;
  final FocusNode _focusNode = FocusNode();

  BuildContext? _mainContext;

  QuillEditor? quillEditor;
  GlobalKey? quillKey;

  // overlayEntry 弹窗
  OverlayEntry? _overlayEntry;

  // 插件展示
  List<PluginItemView> slashList = [];
  List<PluginItemView> _totalValueList = [];
  List<PluginItemView> _valueList = [];

  // 插件注册器
  Map<String, PluginRegistor> registorMap = {};

  @override
  void initState() {
    super.initState();
    quillKey = GlobalKey();
    _loadFromAssets();
  }

  Future<void> _loadFromAssets() async {
    try {
      final result = await rootBundle.loadString('assets/demo.json');
      final doc = Document.fromJson(jsonDecode(result));
      setState(() {
        _controller = QuillController(
            document: doc, selection: const TextSelection.collapsed(offset: 0));
      });
    } catch (error) {
      final doc = Document()..insert(0, 'Empty asset');
      setState(() {
        _controller = QuillController(
            document: doc, selection: const TextSelection.collapsed(offset: 0));
      });
    }
    // 注册监听时间
    _controller?.addListener(editorListener);
    _focusNode.addListener(_advanceTextFocusListener);

    initPlugins();
  }

  // TODO-LIST 初始化插件以及插件导入时想办法如何处理
  // （导入插件时需要检查插件名称是否已经存在，或者给个时间戳+插件名称）
  void initPlugins() {
    // slash 列表
    slashList = [
      PluginItemView(
          title: 'header1',
          onTap: () {
            _controller?.formatSelection(Attribute.h1);
          }),
      PluginItemView(
          title: 'header2',
          onTap: () {
            _controller?.formatSelection(Attribute.h2);
          }),
      PluginItemView(
          title: 'header3',
          onTap: () {
            _controller?.formatSelection(Attribute.h3);
          }),

      // 自定义插件
      PluginItemView(
          title: 'tables',
          onTap: () {
            registorMap['tables']?.initFunction(_mainContext!, _controller!);
          }),
      PluginItemView(
          title: 'notes',
          onTap: () {
            registorMap['notes']?.initFunction(_mainContext!, _controller!);
          })
    ];

    // 注册自定义插件
    registorMap['notes'] = NotePlugin();
    registorMap['tables'] = TablePlugin();
  }

  Widget customElementsEmbedBuilder(
    BuildContext context,
    QuillController controller,
    CustomBlockEmbed block,
    bool readOnly,
    void Function(GlobalKey videoContainerKey)? onVideoInit,
  ) {
    final registor = registorMap[block.type];
    if (registor != null) {
      return registor.buildWidget(context, controller, block, readOnly);
    } else {
      return SizedBox();
    }
  }

  void editorListener() {
    // try {
    // 当前光标索引
    final index = _controller?.selection.baseOffset ?? 0;
    // 编辑器文本
    var value = _controller?.plainTextEditingValue.text;
    if (value is String && value.trim().isNotEmpty) {
      // 光标位置
      final selection = _controller?.selection.copyWith(
        baseOffset: index,
        extentOffset: index,
      );
      var newString = '';
      List<String> arr = value.split('\n');
      int length = 0; // 计数器
      // 判断当前是第几行的数据
      for (var i = 0; i < arr.length; i++) {
        // 回撤 占一个字符
        length += arr[i].length + 1;
        if (index < length) {
          newString = arr[i];
          break;
        }
      }

      // 筛选搜索
      if (_overlayEntry?.mounted ?? false) {
        if (newString.isEmpty) {
          return;
        }
        newString = newString.substring(1, newString.length);
        _valueList =
            _totalValueList.where((e) => e.title.contains(newString)).toList();
        setState(() {});
        return;
      }

      switch (newString) {
        case '/':
          _valueList = slashList;
          _totalValueList = slashList;
          if (_overlayEntry == null && !(_overlayEntry?.mounted ?? false)) {
            _overlayEntry = _createOverlayEntry();
            Overlay.of(_mainContext!)!.insert(_overlayEntry!);
          }
          setState(() {});
          break;
        case ':':
          // 表情包快捷方式
          break;
        case '# ':
          // TODO 删除多余的字符
          _controller?.replaceText(index - 2, 2, '', selection);
          _controller?.formatSelection(Attribute.h1);
          break;
        case '## ':
          _controller?.replaceText(index - 3, 3, '', selection);
          _controller?.formatSelection(Attribute.h2);
          break;
        case '### ':
          _controller?.replaceText(index - 4, 4, '', selection);
          _controller?.formatSelection(Attribute.h3);
          break;
        case '> ':
          _controller?.replaceText(index - 2, 2, '', selection);
          _controller?.formatSelection(Attribute.blockQuote);
          break;
        default:
      }
    }
    // }
    // catch (e) {
    //   print('Exception in catching last charector : $e');
    // }
  }

  void _advanceTextFocusListener() {
    if (_focusNode.hasPrimaryFocus) {
      if (_overlayEntry != null) {
        if (_overlayEntry!.mounted) {
          _overlayEntry!.remove();
          _overlayEntry = null;
        }
      }
    }
  }

  OverlayEntry _createOverlayEntry() {
    // https://github.com/singerdmx/flutter-quill/pull/589
    // 光标位置
    Offset? cursorOffset = (quillKey?.currentState
            as EditorTextSelectionGestureDetectorBuilderDelegate)
        .editableTextKey
        .currentState
        ?.renderEditor
        .getEndpointsForSelection(_controller!.selection)
        .last
        .point;
    Size size = MediaQuery.of(_mainContext!).size;
    double topOffset = size.height - cursorOffset!.dy > 480
        ? cursorOffset.dy + 80
        : cursorOffset.dy - 400 + 80;

    return OverlayEntry(
      builder: (ctx) => Positioned(
        left: cursorOffset.dx + 20,
        top: topOffset,
        height: 400,
        width: 300,
        child: Card(
          shadowColor: Colors.grey,
          elevation: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _valueList.map((e) {
              return InkWell(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, bottom: 5),
                  child: Text(
                    e.title,
                    style: const TextStyle(color: Colors.black, fontSize: 22),
                  ),
                ),
                onTap: () {
                  // 删除该行数据(后面看下有没有更好的办法处理)
                  final index = _controller?.selection.baseOffset ?? 0;
                  final selection = _controller?.selection.copyWith(
                    baseOffset: index,
                    extentOffset: index,
                  );
                  var newString = '';
                  List<String> arr =
                      _controller!.plainTextEditingValue.text.split('\n');
                  int length = 0; // 计数器
                  // 判断当前是第几行的数据
                  for (var i = 0; i < arr.length; i++) {
                    // 回撤 占一个字符
                    length += arr[i].length + 1;
                    if (index < length) {
                      newString = arr[i];
                      break;
                    }
                  }
                  _controller?.replaceText(index - newString.length,
                      newString.length, '', selection);

                  e.onTap();
                  _removeOverLay();
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _removeOverLay() {
    try {
      if (_overlayEntry != null && _overlayEntry!.mounted) {
        _overlayEntry!.remove();
        _overlayEntry = null;
        // hashTagWordList.value = <HashTagSearchResponseBean>[];
        // atMentionSearchList.value = <AtMentionSearchResponseBean>[];
      }
    } catch (e) {
      print('Exception in removing overlay :$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _mainContext = context;
    if (_controller == null) {
      return const Scaffold(body: Center(child: Text('Loading...')));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Flutter Quill',
        ),
        actions: [
          IconButton(
            onPressed: () {
              registorMap['notes']?.initFunction(context, _controller!);
              // setState(() {

              // });
            },
            icon: const Icon(Icons.note_add),
          ),
        ],
      ),
      drawer: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        color: Colors.grey.shade800,
        child: _buildMenuBar(context),
      ),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event.data.isControlPressed && event.character == 'b') {
            if (_controller!
                .getSelectionStyle()
                .attributes
                .keys
                .contains('bold')) {
              _controller!
                  .formatSelection(Attribute.clone(Attribute.bold, null));
            } else {
              _controller!.formatSelection(Attribute.bold);
            }
          }
        },
        child: GridEditShortcuts(
          child: _buildWelcomeEditor(context),
          controller: _controller!,
        ),
      ),
    );
  }

  Widget _buildWelcomeEditor(BuildContext context) {
    quillEditor = QuillEditor(
      key: quillKey,
      controller: _controller!,
      scrollController: ScrollController(),
      scrollable: true,
      focusNode: _focusNode,
      autoFocus: false,
      readOnly: false,
      placeholder: '输入/唤起更多',
      expands: false,
      padding: EdgeInsets.zero,
      customStyles: DefaultStyles(
        h1: DefaultTextBlockStyle(
            const TextStyle(
              fontSize: 32,
              color: Colors.black,
              height: 1.15,
              fontWeight: FontWeight.w300,
            ),
            const Tuple2(16, 0),
            const Tuple2(0, 0),
            null),
        sizeSmall: const TextStyle(fontSize: 9),
      ),
      customElementsEmbedBuilder: customElementsEmbedBuilder,
    );
    if (kIsWeb) {
      quillEditor = QuillEditor(
          key: quillKey,
          controller: _controller!,
          scrollController: ScrollController(),
          scrollable: true,
          focusNode: _focusNode,
          autoFocus: false,
          readOnly: false,
          placeholder: 'Add content',
          expands: false,
          padding: EdgeInsets.zero,
          customStyles: DefaultStyles(
            h1: DefaultTextBlockStyle(
                const TextStyle(
                  fontSize: 32,
                  color: Colors.black,
                  height: 1.15,
                  fontWeight: FontWeight.w300,
                ),
                const Tuple2(16, 0),
                const Tuple2(0, 0),
                null),
            sizeSmall: const TextStyle(fontSize: 9),
          ),
          embedBuilder: defaultEmbedBuilderWeb);
    }
    var toolbar = QuillToolbar.basic(
      controller: _controller!,
      // provide a callback to enable picking images from device.
      // if omit, "image" button only allows adding images from url.
      // same goes for videos.
      onImagePickCallback: _onImagePickCallback,
      onVideoPickCallback: _onVideoPickCallback,
      // uncomment to provide a custom "pick from" dialog.
      // mediaPickSettingSelector: _selectMediaPickSetting,
      showAlignmentButtons: true,
    );
    if (kIsWeb) {
      toolbar = QuillToolbar.basic(
        controller: _controller!,
        onImagePickCallback: _onImagePickCallback,
        webImagePickImpl: _webImagePickImpl,
        showAlignmentButtons: true,
      );
    }
    if (_isDesktop()) {
      toolbar = QuillToolbar.basic(
        controller: _controller!,
        onImagePickCallback: _onImagePickCallback,
        filePickImpl: openFileSystemPickerForDesktop,
        showAlignmentButtons: true,
      );
    }

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 15,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: quillEditor,
            ),
          ),
          kIsWeb
              ? Expanded(
                  child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: toolbar,
                ))
              : Container(child: toolbar)
        ],
      ),
    );
  }

  bool _isDesktop() => !kIsWeb && !Platform.isAndroid && !Platform.isIOS;

  Future<String?> openFileSystemPickerForDesktop(BuildContext context) async {
    return await FilesystemPicker.open(
      context: context,
      rootDirectory: await getApplicationDocumentsDirectory(),
      fsType: FilesystemType.file,
      fileTileSelectMode: FileTileSelectMode.wholeTile,
    );
  }

  // Renders the image picked by imagePicker from local file storage
  // You can also upload the picked image to any server (eg : AWS s3
  // or Firebase) and then return the uploaded image URL.
  Future<String> _onImagePickCallback(File file) async {
    // Copies the picked file from temporary cache to applications directory
    final appDocDir = await getApplicationDocumentsDirectory();
    final copiedFile =
        await file.copy('${appDocDir.path}/${basename(file.path)}');
    return copiedFile.path.toString();
  }

  Future<String?> _webImagePickImpl(
      OnImagePickCallback onImagePickCallback) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return null;
    }

    // Take first, because we don't allow picking multiple files.
    final fileName = result.files.first.name;
    final file = File(fileName);

    return onImagePickCallback(file);
  }

  // Renders the video picked by imagePicker from local file storage
  // You can also upload the picked video to any server (eg : AWS s3
  // or Firebase) and then return the uploaded video URL.
  Future<String> _onVideoPickCallback(File file) async {
    // Copies the picked file from temporary cache to applications directory
    final appDocDir = await getApplicationDocumentsDirectory();
    final copiedFile =
        await file.copy('${appDocDir.path}/${basename(file.path)}');
    return copiedFile.path.toString();
  }

  // ignore: unused_element
  Future<MediaPickSetting?> _selectMediaPickSetting(BuildContext context) =>
      showDialog<MediaPickSetting>(
        context: context,
        builder: (ctx) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.collections),
                label: const Text('Gallery'),
                onPressed: () => Navigator.pop(ctx, MediaPickSetting.Gallery),
              ),
              TextButton.icon(
                icon: const Icon(Icons.link),
                label: const Text('Link'),
                onPressed: () => Navigator.pop(ctx, MediaPickSetting.Link),
              )
            ],
          ),
        ),
      );

  Widget _buildMenuBar(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const itemStyle = TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Divider(
          thickness: 2,
          color: Colors.white,
          indent: size.width * 0.1,
          endIndent: size.width * 0.1,
        ),
        ListTile(
          title: const Center(child: Text('Read only demo', style: itemStyle)),
          dense: true,
          visualDensity: VisualDensity.compact,
          onTap: _readOnly,
        ),
        Divider(
          thickness: 2,
          color: Colors.white,
          indent: size.width * 0.1,
          endIndent: size.width * 0.1,
        ),
      ],
    );
  }

  void _readOnly() {
    Navigator.push(
      super.context,
      MaterialPageRoute(
        builder: (context) => ReadOnlyPage(),
      ),
    );
  }

  Future<void> _addEditNote(BuildContext context, {Document? document}) async {
    final isEditing = document != null;
    final quillEditorController = QuillController(
      document: document ?? Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.only(left: 16, top: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${isEditing ? 'Edit' : 'Add'} note'),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            )
          ],
        ),
        content: QuillEditor.basic(
          controller: quillEditorController,
          readOnly: false,
        ),
      ),
    );

    if (quillEditorController.document.isEmpty()) return;

    final block = BlockEmbed.custom(
      NotesBlockEmbed.fromDocument(quillEditorController.document),
    );
    final controller = _controller!;
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;

    if (isEditing) {
      final offset = getEmbedNode(controller, controller.selection.start).item1;
      controller.replaceText(
          offset, 1, block, TextSelection.collapsed(offset: offset));
    } else {
      controller.replaceText(index, length, block, null);
    }
  }
}

class NotesBlockEmbed extends CustomBlockEmbed {
  const NotesBlockEmbed(String value) : super(noteType, value);

  static const String noteType = 'notes';

  static NotesBlockEmbed fromDocument(Document document) =>
      NotesBlockEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}
