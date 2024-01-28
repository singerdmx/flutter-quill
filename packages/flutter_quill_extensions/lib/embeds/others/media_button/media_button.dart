// // ignore_for_file: use_build_context_synchronously

// import 'dart:math' as math;
// import 'dart:ui';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_quill/extensions.dart';
// import 'package:flutter_quill/flutter_quill.dart';
// import 'package:flutter_quill/translations.dart';
// import 'package:image_picker/image_picker.dart';

// import '../../../models/config/toolbar/buttons/media_button.dart';
// import '../../embed_types.dart';
// import '../utils/image_video_utils.dart';

// /// Widget which combines [ImageButton] and [VideButton] widgets. This widget
// /// has more customization and uses dialog similar to one which is used
// /// on [http://quilljs.com].
// class QuillToolbarMediaButton extends StatelessWidget {
//   QuillToolbarMediaButton({
//     required this.controller,
//     this.options,
//     super.key,
//   }) : assert(options.type == QuillMediaType.image,
//             'Video selection is not supported yet');

//   final QuillController controller;
//   final QuillToolbarMediaButtonOptions options;

//   double _iconSize(BuildContext context) {
//     final baseFontSize = baseButtonExtraOptions(context).globalIconSize;
//     final iconSize = options.iconSize;
//     return iconSize ?? baseFontSize;
//   }

//   VoidCallback? _afterButtonPressed(BuildContext context) {
//     return options.afterButtonPressed ??
//         baseButtonExtraOptions(context).afterButtonPressed;
//   }

//   QuillIconTheme? _iconTheme(BuildContext context) {
//     return options.iconTheme ?? baseButtonExtraOptions(context).iconTheme;
//   }

//   QuillToolbarBaseButtonOptions baseButtonExtraOptions(
//BuildContext context) {
//     return context.requireQuillToolbarBaseButtonOptions;
//   }

//   (IconData, String) get _defaultData {
//     switch (options.type) {
//       case QuillMediaType.image:
//         return (Icons.perm_media, 'Photo media button');
//       case QuillMediaType.video:
//         throw UnsupportedError('The video is not supported yet.');
//     }
//   }

//   IconData _iconData(BuildContext context) {
//     return options.iconData ??
//         baseButtonExtraOptions(context).iconData ??
//         _defaultData.$1;
//   }

//   String _tooltip(BuildContext context) {
//     return options.tooltip ??
//         baseButtonExtraOptions(context).tooltip ??
//         _defaultData.$2;
//     // ('Camera'.i18n);
//   }

//   void _sharedOnPressed(BuildContext context) {
//     _onPressedHandler(context);
//     _afterButtonPressed(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tooltip = _tooltip(context);
//     final iconSize = _iconSize(context);
//     final iconData = _iconData(context);
//     final childBuilder =
//         options.childBuilder ?? baseButtonExtraOptions(context).childBuilder;
//     final iconTheme = _iconTheme(context);

//     if (childBuilder != null) {
//       return childBuilder(
//         QuillToolbarMediaButtonOptions(
//           type: options.type,
//           onMediaPickedCallback: options.onMediaPickedCallback,
//           onImagePickCallback: options.onImagePickCallback,
//           onVideoPickCallback: options.onVideoPickCallback,
//           iconData: iconData,
//           afterButtonPressed: _afterButtonPressed(context),
//           autovalidateMode: options.autovalidateMode,
//           childrenSpacing: options.childrenSpacing,
//           dialogBarrierColor: options.dialogBarrierColor,
//           dialogTheme: options.dialogTheme,
//           filePickImpl: options.filePickImpl,
//           fillColor: options.fillColor,
//           galleryButtonText: options.galleryButtonText,
//           iconTheme: iconTheme,
//           iconSize: iconSize,
//           iconButtonFactor: iconButtonFactor,
//           hintText: options.hintText,
//           labelText: options.labelText,
//           submitButtonSize: options.submitButtonSize,
//           linkButtonText: options.linkButtonText,
//           mediaFilePicker: options.mediaFilePicker,
//           submitButtonText: options.submitButtonText,
//           validationMessage: options.validationMessage,
//           webImagePickImpl: options.webImagePickImpl,
//           webVideoPickImpl: options.webVideoPickImpl,
//           tooltip: options.tooltip,
//         ),
//         QuillToolbarMediaButtonExtraOptions(
//           context: context,
//           controller: controller,
//           onPressed: () => _sharedOnPressed(context),
//         ),
//       );
//     }

//     final theme = Theme.of(context);

//     final iconColor =
//         options.iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
//     final iconFillColor = options.iconTheme?.iconUnselectedFillColor ??
//         options.fillColor ??
//         theme.canvasColor;

//     return QuillToolbarIconButton(
//       icon: Icon(iconData, size: iconSize, color: iconColor),
//       tooltip: tooltip,
//       highlightElevation: 0,
//       hoverElevation: 0,
//       size: iconSize * iconButtonFactor,
//       fillColor: iconFillColor,
//       borderRadius: iconTheme?.borderRadius ?? 2,
//       onPressed: () => _sharedOnPressed(context),
//     );
//   }

//   Future<void> _onPressedHandler(BuildContext context) async {
//     if (options.onMediaPickedCallback == null) {
//       _inputLink(context);
//       return;
//     }
//     final mediaSource = await showDialog<MediaPickSetting>(
//       context: context,
//       builder: (_) => MediaSourceSelectorDialog(
//         dialogTheme: options.dialogTheme,
//         galleryButtonText: options.galleryButtonText,
//         linkButtonText: options.linkButtonText,
//       ),
//     );
//     if (mediaSource == null) {
//       return;
//     }
//     switch (mediaSource) {
//       case MediaPickSetting.gallery:
//         await _pickImage();
//         break;
//       case MediaPickSetting.link:
//         _inputLink(context);
//         break;
//       case MediaPickSetting.camera:
//         await ImageVideoUtils.handleImageButtonTap(
//           context,
//           controller,
//           ImageSource.camera,
//           options.onImagePickCallback,
//           filePickImpl: options.filePickImpl,
//           webImagePickImpl: options.webImagePickImpl,
//         );
//         break;
//       case MediaPickSetting.video:
//         await ImageVideoUtils.handleVideoButtonTap(
//           context,
//           controller,
//           ImageSource.camera,
//           options.onVideoPickCallback,
//           filePickImpl: options.filePickImpl,
//           webVideoPickImpl: options.webVideoPickImpl,
//         );
//         break;
//     }
//   }

//   Future<void> _pickImage() async {
//     if (!(kIsWeb || isMobile() || isDesktop())) {
//       throw UnsupportedError(
//         'Unsupported target platform: ${defaultTargetPlatform.name}',
//       );
//     }

//     final mediaFileUrl = await _pickMediaFileUrl();

//     if (mediaFileUrl != null) {
//       final index = controller.selection.baseOffset;
//       final length = controller.selection.extentOffset - index;
//       controller.replaceText(
//         index,
//         length,
//         BlockEmbed.image(mediaFileUrl),
//         null,
//       );
//     }
//   }

//   Future<MediaFileUrl?> _pickMediaFileUrl() async {
//     final mediaFile = await options.mediaFilePicker?.call(options.type);
//     return mediaFile != null
//         ? options.onMediaPickedCallback?.call(mediaFile)
//         : null;
//   }

//   void _inputLink(BuildContext context) {
//     showDialog<String>(
//       context: context,
//       builder: (_) => MediaLinkDialog(
//         dialogTheme: options.dialogTheme,
//         labelText: options.labelText,
//         hintText: options.hintText,
//         buttonText: options.submitButtonText,
//         buttonSize: options.submitButtonSize,
//         childrenSpacing: options.childrenSpacing,
//         autovalidateMode: options.autovalidateMode,
//         validationMessage: options.validationMessage,
//       ),
//     ).then(_linkSubmitted);
//   }

//   void _linkSubmitted(String? value) {
//     if (value != null && value.isNotEmpty) {
//       final index = controller.selection.baseOffset;
//       final length = controller.selection.extentOffset - index;
//       final data = options.type.isImage
//           ? BlockEmbed.image(value)
//           : BlockEmbed.video(value);
//       controller.replaceText(index, length, data, null);
//     }
//   }
// }

// /// Provides a dialog for input link to media resource.
// class MediaLinkDialog extends StatefulWidget {
//   const MediaLinkDialog({
//     super.key,
//     this.link,
//     this.dialogTheme,
//     this.childrenSpacing = 16.0,
//     this.labelText,
//     this.hintText,
//     this.buttonText,
//     this.buttonSize,
//     this.autovalidateMode = AutovalidateMode.disabled,
//     this.validationMessage,
//   }) : assert(childrenSpacing > 0);

//   final String? link;
//   final QuillDialogTheme? dialogTheme;

//   /// The margin between child widgets in the dialog.
//   final double childrenSpacing;

//   /// The text of label in link add mode.
//   final String? labelText;

//   /// The hint text for link [TextField].
//   final String? hintText;

//   /// The text of the submit button.
//   final String? buttonText;

//   /// The size of dialog buttons.
//   final Size? buttonSize;

//   final AutovalidateMode autovalidateMode;
//   final String? validationMessage;

//   @override
//   State<MediaLinkDialog> createState() => _MediaLinkDialogState();
// }

// class _MediaLinkDialogState extends State<MediaLinkDialog> {
//   final _linkFocus = FocusNode();
//   final _linkController = TextEditingController();

//   @override
//   void dispose() {
//     _linkFocus.dispose();
//     _linkController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final constraints = widget.dialogTheme?.linkDialogConstraints ??
//         () {
//           final size = MediaQuery.sizeOf(context);
//           final maxWidth = kIsWeb ? size.width / 4 : size.width - 80;
//           return BoxConstraints(maxWidth: maxWidth, maxHeight: 80);
//         }();

//     final buttonStyle = widget.buttonSize != null
//         ? Theme.of(context)
//             .elevatedButtonTheme
//             .style
//             ?.copyWith(
//fixedSize: MaterialStatePropertyAll(widget.buttonSize))
//         : widget.dialogTheme?.buttonStyle;

//     final isWrappable = widget.dialogTheme?.isWrappable ?? false;

//     final children = [
//       Text(widget.labelText ?? 'Enter media'.i18n),
//       UtilityWidgets.maybeWidget(
//         enabled: !isWrappable,
//         wrapper: (child) => Expanded(
//           child: child,
//         ),
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: widget.childrenSpacing),
//           child: TextFormField(
//             controller: _linkController,
//             focusNode: _linkFocus,
//             style: widget.dialogTheme?.inputTextStyle,
//             keyboardType: TextInputType.url,
//             textInputAction: TextInputAction.done,
//             decoration: InputDecoration(
//               labelStyle: widget.dialogTheme?.labelTextStyle,
//               hintText: widget.hintText,
//             ),
//             autofocus: true,
//             autovalidateMode: widget.autovalidateMode,
//             validator: _validateLink,
//             onChanged: _linkChanged,
//           ),
//         ),
//       ),
//       ElevatedButton(
//         onPressed: _canPress() ? _submitLink : null,
//         style: buttonStyle,
//         child: Text(widget.buttonText ?? 'Ok'.i18n),
//       ),
//     ];

//     return Dialog(
//       backgroundColor: widget.dialogTheme?.dialogBackgroundColor,
//       shape: widget.dialogTheme?.shape ??
//           DialogTheme.of(context).shape ??
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//       child: ConstrainedBox(
//         constraints: constraints,
//         child: Padding(
//           padding:
//               widget.dialogTheme?.linkDialogPadding ?? const
// EdgeInsets.all(16),
//           child: Form(
//             child: isWrappable
//                 ? Wrap(
//                     alignment: WrapAlignment.center,
//                     crossAxisAlignment: WrapCrossAlignment.center,
//                     runSpacing: widget.dialogTheme?.runSpacing ?? 0.0,
//                     children: children,
//                   )
//                 : Row(
//                     children: children,
//                   ),
//           ),
//         ),
//       ),
//     );
//   }

//   bool _canPress() => _validateLink(_linkController.text) == null;

//   void _linkChanged(String value) {
//     setState(() {
//       _linkController.text = value;
//     });
//   }

//   void _submitLink() => Navigator.pop(context, _linkController.text);

//   String? _validateLink(String? value) {
//     if ((value?.isEmpty ?? false) ||
//         !AutoFormatMultipleLinksRule.oneLineLinkRegExp.hasMatch(value!)) {
//       return widget.validationMessage ?? 'That is not a valid URL';
//     }

//     return null;
//   }
// }

// /// Media souce selector.
// class MediaSourceSelectorDialog extends StatelessWidget {
//   const MediaSourceSelectorDialog({
//     super.key,
//     this.dialogTheme,
//     this.galleryButtonText,
//     this.linkButtonText,
//   });

//   final QuillDialogTheme? dialogTheme;

//   /// The text of the gallery button [MediaSourceSelectorDialog].
//   final String? galleryButtonText;

//   /// The text of the link button [MediaSourceSelectorDialog].
//   final String? linkButtonText;

//   @override
//   Widget build(BuildContext context) {
//     final constraints = dialogTheme?.mediaSelectorDialogConstraints ??
//         () {
//           final size = MediaQuery.sizeOf(context);
//           double maxWidth, maxHeight;
//           if (kIsWeb) {
//             maxWidth = size.width / 7;
//             maxHeight = size.height / 7;
//           } else {
//             maxWidth = size.width - 80;
//             maxHeight = maxWidth / 2;
//           }
//           return BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight);
//         }();

//     final shape = dialogTheme?.shape ??
//         DialogTheme.of(context).shape ??
//         RoundedRectangleBorder(borderRadius: BorderRadius.circular(4));

//     return Dialog(
//       backgroundColor: dialogTheme?.dialogBackgroundColor,
//       shape: shape,
//       child: ConstrainedBox(
//         constraints: constraints,
//         child: Padding(
//           padding: dialogTheme?.mediaSelectorDialogPadding ??
//               const EdgeInsets.all(16),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: TextButtonWithIcon(
//                   icon: Icons.collections,
//                   label: galleryButtonText ?? 'Gallery'.i18n,
//                   onPressed: () =>
//                       Navigator.pop(context, MediaPickSetting.gallery),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: TextButtonWithIcon(
//                   icon: Icons.link,
//                   label: linkButtonText ?? 'Link'.i18n,
//                   onPressed: () =>
//                       Navigator.pop(context, MediaPickSetting.link),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class TextButtonWithIcon extends StatelessWidget {
//   const TextButtonWithIcon({
//     required this.label,
//     required this.icon,
//     required this.onPressed,
//     this.textStyle,
//     super.key,
//   });

//   final String label;
//   final IconData icon;
//   final VoidCallback onPressed;
//   final TextStyle? textStyle;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final scale = MediaQuery.maybeOf(context)?.textScaleFactor ?? 1;
//     final gap = scale <= 1 ? 8.0 : lerpDouble(8, 4, math.min(scale - 1, 1))!;
//     final buttonStyle = TextButtonTheme.of(context).style;
//     final shape = buttonStyle?.shape?.resolve({}) ??
//         const RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(
//             Radius.circular(4),
//           ),
//         );
//     return Material(
//       shape: shape,
//       textStyle: textStyle ??
//           theme.textButtonTheme.style?.textStyle?.resolve({}) ??
//           theme.textTheme.labelLarge,
//       elevation: buttonStyle?.elevation?.resolve({}) ?? 0,
//       child: InkWell(
//         customBorder: shape,
//         onTap: onPressed,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Icon(icon),
//               SizedBox(height: gap),
//               Flexible(child: Text(label)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Default file picker.
// // Future<QuillFile?> _defaultMediaPicker(QuillMediaType mediaType) async {
// //   final pickedFile = mediaType.isImage
// //       ? await ImagePicker().pickImage(source: ImageSource.gallery)
// //       : await ImagePicker().pickVideo(source: ImageSource.gallery);

// //   if (pickedFile != null) {
// //     return QuillFile(
// //       name: pickedFile.name,
// //       path: pickedFile.path,
// //       bytes: await pickedFile.readAsBytes(),
// //     );
// //   }

// //   return null;
// // }
