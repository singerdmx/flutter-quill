/*
 * @Author: joahyan joahyan@163.com
 * @Date: 2022-07-25 14:52:47
 * @LastEditors: joahyan joahyan@163.com
 * @LastEditTime: 2022-07-28 10:05:24
 * @FilePath: \flutter-quill\lib\src\models\documents\plugin.dart
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

// plugin 实体类(主要用于展示,后期可能设计图标之类)
class PluginItemView {
  final String title;
  final Function onTap;
  PluginItemView({
    required this.title,
    required this.onTap,
  });
}

// 主要用于注册插件
abstract class PluginRegistor {
  late String attributeName;
  // 组件样式
  Widget buildWidget(
    BuildContext context,
    QuillController controller,
    CustomBlockEmbed block,
    bool readOnly,
  );

  // 快捷方式渲染的数据
  void initFunction(BuildContext context, QuillController controller,
      {Document? document});
}
