import 'package:flutter/widgets.dart' show BuildContext;

import '../../flutter_quill.dart';

// TODO: The comments of this file is outdated and needs to be updated

/// Public shared extension
extension QuillProviderExt on BuildContext {
  /// return [QuillProvider] as not null
  /// throw exception if it's not in the widget tree
  QuillProvider get requireQuillProvider {
    return QuillProvider.ofNotNull(this);
  }

  /// return nullable [QuillProvider]
  /// don't throw exception if it's not in the widget tree
  /// instead it will be null
  QuillProvider? get quillProvider {
    return QuillProvider.of(this);
  }

  /// return nullable [QuillController]
  /// since the quill controller is in the [QuillProvider] then we need to get
  /// the provider widget first and then we will return the controller
  /// don't throw exception if [QuillProvider] is not in the widget tree
  /// instead it will be null
  QuillController? get quilController {
    return quillProvider?.configurations.controller;
  }

  /// return [QuillController] as not null
  /// since the quill controller is in the [QuillProvider] then we need to get
  /// the provider widget first and then we will return the controller
  /// throw exception if [QuillProvider] is not in the widget tree
  QuillController get requireQuillController {
    return requireQuillProvider.configurations.controller;
  }

  /// return [QuillConfigurations] as not null
  /// since the quill configurations is in the [QuillProvider] then we need to
  /// get the provider widget first and then we will return quill configurations
  /// throw exception if [QuillProvider] is not in the widget tree
  QuillConfigurations get requireQuillConfigurations {
    return requireQuillProvider.configurations;
  }

  /// return nullable [QuillConfigurations]
  /// since the quill configurations is in the [QuillProvider] then we need to
  /// get the provider widget first and then we will return quill configurations
  /// don't throw exception if [QuillProvider] is not in the widget tree
  QuillConfigurations? get quillConfigurations {
    return quillProvider?.configurations;
  }

  /// return [QuillSharedConfigurations] as not null. Since the quill
  /// shared configurations is in the [QuillProvider] then we need to get the
  /// provider widget first and then we will return shared configurations
  /// throw exception if [QuillProvider] is not in the widget tree
  QuillSharedConfigurations get requireQuillSharedConfigurations {
    return requireQuillConfigurations.sharedConfigurations;
  }

  /// return nullable [QuillSharedConfigurations] . Since the quill
  /// shared configurations is in the [QuillProvider] then we need to get the
  /// provider widget first and then we will return shared configurations
  /// don't throw exception if [QuillProvider] is not in the widget tree
  QuillSharedConfigurations? get quillSharedConfigurations {
    return quillConfigurations?.sharedConfigurations;
  }

  /// return [QuillEditorConfigurations] as not null . Since the quill
  /// editor configurations is in the [QuillEditorProvider]
  ///  then we need to get the
  /// provider widget first and then we will return editor configurations
  /// throw exception if [QuillProvider] is not in the widget tree
  QuillEditorConfigurations get requireQuillEditorConfigurations {
    return QuillEditorProvider.ofNotNull(this).editorConfigurations;
  }

  /// return nullable [QuillEditorConfigurations]. Since the quill
  /// editor configurations is in the [QuillEditorProvider]
  ///  then we need to get the
  /// provider widget first and then we will return editor configurations
  /// don't throw exception if [QuillProvider] is not in the widget tree
  QuillEditorConfigurations? get quillEditorConfigurations {
    return QuillEditorProvider.of(this)?.editorConfigurations;
  }

  /// return [QuillToolbarConfigurations] as not null . Since the quill
  /// toolbar configurations is in the [QuillToolbarProvider]
  /// then we need to get the
  /// provider widget first and then we will return toolbar configurations
  /// throw exception if [QuillProvider] is not in the widget tree
  QuillToolbarConfigurations get requireQuillToolbarConfigurations {
    return QuillToolbarProvider.ofNotNull(this).toolbarConfigurations;
  }

  /// return nullable [QuillToolbarConfigurations]. Since the quill
  /// toolbar configurations is in the [QuillToolbarProvider]
  ///  then we need to get the
  /// provider widget first and then we will return toolbar configurations
  /// don't throw exception if [QuillProvider] is not in the widget tree
  QuillToolbarConfigurations? get quillToolbarConfigurations {
    return QuillToolbarProvider.of(this)?.toolbarConfigurations;
  }

  /// return [QuillBaseToolbarConfigurations] as not null . Since the quill
  /// toolbar configurations is in the [QuillBaseToolbarProvider]
  /// then we need to get the
  /// provider widget first and then we will return toolbar configurations
  /// throw exception if [QuillBaseToolbarProvider] is not in the widget tree
  QuillBaseToolbarConfigurations get requireQuillBaseToolbarConfigurations {
    return QuillBaseToolbarProvider.ofNotNull(this).toolbarConfigurations;
  }

  /// return nullable [QuillBaseToolbarConfigurations]. Since the quill
  /// toolbar configurations is in the [QuillBaseToolbarProvider]
  ///  then we need to get the
  /// provider widget first and then we will return toolbar configurations
  /// don't throw exception if [QuillBaseToolbarProvider] is not in the widget tree
  QuillBaseToolbarConfigurations? get quillBaseToolbarConfigurations {
    return QuillBaseToolbarProvider.of(this)?.toolbarConfigurations;
  }

  /// return nullable [QuillToolbarBaseButtonOptions]. Since the quill
  /// toolbar base button options is in the [QuillProvider] then we need to
  /// get the provider widget first and then we will return base button
  /// don't throw exception if [QuillProvider] is not in the widget tree
  QuillToolbarBaseButtonOptions? get quillToolbarBaseButtonOptions {
    return quillToolbarConfigurations?.buttonOptions.base;
  }

  /// return [QuillToolbarBaseButtonOptions] as not null. Since the quill
  /// toolbar base button options is in the [QuillProvider] then we need to
  /// get the provider widget first and then we will return base button
  /// throw exception if [QuillProvider] is not in the widget tree
  QuillToolbarBaseButtonOptions get requireQuillToolbarBaseButtonOptions {
    return quillToolbarConfigurations?.buttonOptions.base ??
        quillBaseToolbarConfigurations?.buttonOptions.base ??
        (throw ArgumentError(
          "The buttonOptions is required and it's required",
        ));
  }

  /// return nullable [QuillToolbarBaseButtonOptions]. Since the quill
  /// quill editor block options is in the [QuillEditorProvider] then we need to
  /// get the provider widget first and then we will return block options
  /// throw exception if [QuillEditorProvider] is not in the widget tree
  QuillEditorElementOptions? get quillEditorElementOptions {
    return quillEditorConfigurations?.elementOptions;
  }

  /// return [QuillToolbarBaseButtonOptions] as not null. Since the quill
  /// quill editor block options is in the [QuillEditorProvider] then we need to
  /// get the provider widget first and then we will return block options
  /// don't throw exception if [QuillEditorProvider] is not in the widget tree
  QuillEditorElementOptions get requireQuillEditorElementOptions {
    return requireQuillEditorConfigurations.elementOptions;
  }
}
