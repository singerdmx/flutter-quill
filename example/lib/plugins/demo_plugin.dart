/*
 * @Author: joahyan joahyan@163.com
 * @Date: 2022-07-27 21:23:06
 * @LastEditors: joahyan joahyan@163.com
 * @LastEditTime: 2022-07-28 20:11:28
 * @FilePath: \flutter-quill\example\lib\plugins\demo_plugin.dart
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../annotion/plugin_annotation.dart';
import 'plugin.dart';

@PluginAnnotation(attributeName: 'demo')
class DemoPlugin extends PluginRegistor {
  @override
  Widget buildWidget(
    BuildContext context,
    QuillController controller,
    CustomBlockEmbed block,
    bool readOnly,
  ) {
    throw UnimplementedError();
  }

  @override
  void initFunction(
    BuildContext context,
    QuillController controller, {
    Document? document,
  }) {}
  
}
