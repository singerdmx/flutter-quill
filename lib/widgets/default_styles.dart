import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tuple/tuple.dart';

class QuillStyles extends InheritedWidget {
  final DefaultStyles data;

  QuillStyles({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(QuillStyles oldWidget) {
    return data != oldWidget.data;
  }

  static DefaultStyles? getStyles(BuildContext context, bool nullOk) {
    var widget = context.dependOnInheritedWidgetOfExactType<QuillStyles>();
    if (widget == null && nullOk) {
      return null;
    }
    assert(widget != null);
    return widget!.data;
  }
}

class DefaultTextBlockStyle {
  final TextStyle style;

  final Tuple2<double, double> verticalSpacing;

  final Tuple2<double, double> lineSpacing;

  final BoxDecoration? decoration;

  DefaultTextBlockStyle(
      this.style, this.verticalSpacing, this.lineSpacing, this.decoration);
}

class DefaultStyles {
  final DefaultTextBlockStyle? h1;
  final DefaultTextBlockStyle? h2;
  final DefaultTextBlockStyle? h3;
  final DefaultTextBlockStyle? paragraph;
  final TextStyle? bold;
  final TextStyle? italic;
  final TextStyle? underline;
  final TextStyle? strikeThrough;
  final TextStyle? sizeSmall; // 'small'
  final TextStyle? sizeLarge; // 'large'
  final TextStyle? sizeHuge; // 'huge'
  final TextStyle? link;
  final DefaultTextBlockStyle? placeHolder;
  final DefaultTextBlockStyle? lists;
  final DefaultTextBlockStyle? quote;
  final DefaultTextBlockStyle? code;
  final DefaultTextBlockStyle? indent;
  final DefaultTextBlockStyle? align;

  DefaultStyles(
      {this.h1,
      this.h2,
      this.h3,
      this.paragraph,
      this.bold,
      this.italic,
      this.underline,
      this.strikeThrough,
      this.link,
      this.placeHolder,
      this.lists,
      this.quote,
      this.code,
      this.indent,
      this.align,
      this.sizeSmall,
      this.sizeLarge,
      this.sizeHuge});

  static DefaultStyles getInstance(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle baseStyle = defaultTextStyle.style.copyWith(
      fontSize: 16.0,
      height: 1.3,
    );
    Tuple2<double, double> baseSpacing = Tuple2(6.0, 0);
    String fontFamily;
    switch (themeData.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        fontFamily = 'Menlo';
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        fontFamily = 'Roboto Mono';
        break;
      default:
        throw UnimplementedError();
    }

    return DefaultStyles(
        h1: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 34.0,
              color: defaultTextStyle.style.color!.withOpacity(0.70),
              height: 1.15,
              fontWeight: FontWeight.w300,
            ),
            Tuple2(16.0, 0.0),
            Tuple2(0.0, 0.0),
            null),
        h2: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 24.0,
              color: defaultTextStyle.style.color!.withOpacity(0.70),
              height: 1.15,
              fontWeight: FontWeight.normal,
            ),
            Tuple2(8.0, 0.0),
            Tuple2(0.0, 0.0),
            null),
        h3: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 20.0,
              color: defaultTextStyle.style.color!.withOpacity(0.70),
              height: 1.25,
              fontWeight: FontWeight.w500,
            ),
            Tuple2(8.0, 0.0),
            Tuple2(0.0, 0.0),
            null),
        paragraph: DefaultTextBlockStyle(
            baseStyle, Tuple2(0.0, 0.0), Tuple2(0.0, 0.0), null),
        bold: TextStyle(fontWeight: FontWeight.bold),
        italic: TextStyle(fontStyle: FontStyle.italic),
        underline: TextStyle(decoration: TextDecoration.underline),
        strikeThrough: TextStyle(decoration: TextDecoration.lineThrough),
        link: TextStyle(
          color: themeData.accentColor,
          decoration: TextDecoration.underline,
        ),
        placeHolder: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 20.0,
              height: 1.5,
              color: Colors.grey.withOpacity(0.6),
            ),
            Tuple2(0.0, 0.0),
            Tuple2(0.0, 0.0),
            null),
        lists: DefaultTextBlockStyle(
            baseStyle, baseSpacing, Tuple2(0.0, 6.0), null),
        quote: DefaultTextBlockStyle(
            TextStyle(color: baseStyle.color!.withOpacity(0.6)),
            baseSpacing,
            Tuple2(6.0, 2.0),
            BoxDecoration(
              border: Border(
                left: BorderSide(width: 4, color: Colors.grey.shade300),
              ),
            )),
        code: DefaultTextBlockStyle(
            TextStyle(
              color: Colors.blue.shade900.withOpacity(0.9),
              fontFamily: fontFamily,
              fontSize: 13.0,
              height: 1.15,
            ),
            baseSpacing,
            Tuple2(0.0, 0.0),
            BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(2),
            )),
        indent: DefaultTextBlockStyle(
            baseStyle, baseSpacing, Tuple2(0.0, 6.0), null),
        align: DefaultTextBlockStyle(
            baseStyle, Tuple2(0.0, 0.0), Tuple2(0.0, 0.0), null),
        sizeSmall: TextStyle(fontSize: 10.0),
        sizeLarge: TextStyle(fontSize: 18.0),
        sizeHuge: TextStyle(fontSize: 22.0));
  }

  DefaultStyles merge(DefaultStyles other) {
    return DefaultStyles(
        h1: other.h1 ?? this.h1,
        h2: other.h2 ?? this.h2,
        h3: other.h3 ?? this.h3,
        paragraph: other.paragraph ?? this.paragraph,
        bold: other.bold ?? this.bold,
        italic: other.italic ?? this.italic,
        underline: other.underline ?? this.underline,
        strikeThrough: other.strikeThrough ?? this.strikeThrough,
        link: other.link ?? this.link,
        placeHolder: other.placeHolder ?? this.placeHolder,
        lists: other.lists ?? this.lists,
        quote: other.quote ?? this.quote,
        code: other.code ?? this.code,
        indent: other.indent ?? this.indent,
        align: other.align ?? this.align,
        sizeSmall: other.sizeSmall ?? this.sizeSmall,
        sizeLarge: other.sizeLarge ?? this.sizeLarge,
        sizeHuge: other.sizeHuge ?? this.sizeHuge);
  }
}
