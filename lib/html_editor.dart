library html_editor;

export 'package:html_editor_enhanced/utils/callbacks.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html_editor_enhanced/html_editor_widget.dart';
import 'package:html_editor_enhanced/utils/callbacks.dart';

/// Global variable used to get the [InAppWebViewController] of the Html editor
InAppWebViewController controller;

/// Global variable used to get the text from the Html editor
String text = "";

class HtmlEditor extends StatelessWidget with WidgetsBindingObserver {
  HtmlEditor({
    Key key,
    this.initialText,
    this.height = 380,
    this.decoration,
    this.useBottomSheet = true,
    this.imageWidth = 100,
    this.showBottomToolbar = true,
    this.hint,
    this.callbacks,
  }) :  assert(imageWidth > 0 && imageWidth <= 100),
        super(key: key);

  /// The initial text that is be supplied to the Html editor.
  final String initialText;

  /// Sets the height of the Html editor. If you decide to show the bottom toolbar,
  /// this height will be inclusive of the space the toolbar takes up.
  ///
  /// The default value is 380.
  final double height;

  /// The BoxDecoration to use around the Html editor. By default, the widget
  /// uses a thin, dark, rounded rectangle border around the widget.
  final BoxDecoration decoration;

  /// Specifies whether the widget should use a bottom sheet or a dialog to provide the image
  /// picking options. The dialog is similar to an Android intent dialog.
  ///
  /// The default value is true.
  final bool useBottomSheet;

  /// Specifies the width of an image when it is inserted into the Html editor
  /// as a percentage (between 0 and 100).
  ///
  /// The default value is 100.
  final double imageWidth;

  /// Specifies whether the bottom toolbar for picking an image or copy/pasting
  /// is shown on the widget.
  ///
  /// The default value is true.
  final bool showBottomToolbar;

  /// Sets the Html editor's hint (text displayed when there is no text in the
  /// editor).
  final String hint;

  final Callbacks callbacks;

  /// Allows the [InAppWebViewController] for the Html editor to be accessed
  /// outside of the package itself for endless control and customization.
  static InAppWebViewController get editorController => controller;

  /// Gets the text from the editor and returns it as a [String].
  static Future<String> getText() async {
    await evaluateJavascript(source: "var str = \$('#summernote').summernote('code'); console.log(str);");
    return text;
  }

  /// Sets the text of the editor. Some pre-processing is applied to convert
  /// [String] elements like "\n" to HTML elements.
  static void setText(String text) {
    String txtIsi = text
        .replaceAll("'", '\\"')
        .replaceAll('"', '\\"')
        .replaceAll("[", "\\[")
        .replaceAll("]", "\\]")
        .replaceAll("\n", "<br/>")
        .replaceAll("\n\n", "<br/>")
        .replaceAll("\r", " ")
        .replaceAll('\r\n', " ");
    evaluateJavascript(source: "\$('#summernote').summernote('code', '$txtIsi');");
  }

  /// Sets the editor to full-screen mode.
  static void setFullScreen() {
    evaluateJavascript(source: '\$("#summernote").summernote("fullscreen.toggle");');
  }

  /// Sets the focus to the editor.
  static void setFocus() {
    evaluateJavascript(source: "\$('#summernote').summernote('focus');");
  }

  /// Clears the editor of any text.
  static void clear() {
    evaluateJavascript(source: "\$('#summernote').summernote('reset');");
  }

  /// Sets the hint for the editor.
  static void setHint(String text) {
    String hint = '\$(".note-placeholder").html("$text");';
    evaluateJavascript(source: hint);
  }

  /// toggles the codeview in the Html editor
  static void toggleCodeView() {
    evaluateJavascript(source: "\$('#summernote').summernote('codeview.toggle');");
  }

  /// disables the Html editor
  static void disable() {
    evaluateJavascript(source: "\$('#summernote').summernote('disable');");
  }

  /// enables the Html editor
  static void enable() {
    evaluateJavascript(source: "\$('#summernote').summernote('enable');");
  }

  /// Undoes the last action
  static void undo() {
    evaluateJavascript(source: "\$('#summernote').summernote('undo');");
  }

  /// Redoes the last action
  static void redo() {
    evaluateJavascript(source: "\$('#summernote').summernote('redo');");
  }
  
  /// Insert text at the end of the current HTML content in the editor
  /// Note: This method should only be used for plaintext strings
  static void insertText(String text) {
    evaluateJavascript(source: "\$('#summernote').summernote('insertText', '$text');");
  }
  
  /// Insert HTML at the position of the cursor in the editor
  /// Note: This method should not be used for plaintext strings
  static void insertHtml(String html) {
    evaluateJavascript(source: "\$('#summernote').summernote('pasteHTML', '$html');");
  }

  /// Insert a network image at the position of the cursor in the editor
  static void insertNetworkImage(String url, {String filename = ""}) {
    evaluateJavascript(source: "\$('#summernote').summernote('insertImage', '$url', '$filename');");
  }

  static void insertLink(String text, String url, bool isNewWindow) {
    evaluateJavascript(source: """
    \$('#summernote').summernote('createLink', {
        text: "$text",
        url: '$url',
        isNewWindow: $isNewWindow
      });
    """);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: decoration ??
          BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            border: Border.all(color: Color(0xffececec), width: 1),
          ),
      child: HtmlEditorWidget(
        key: key,
        value: initialText,
        height: height,
        useBottomSheet: useBottomSheet,
        imageWidth: imageWidth,
        showBottomToolbar: showBottomToolbar,
        hint: hint,
        callbacks: callbacks,
      ),
    );
  }

  static Future evaluateJavascript({@required source}) async {
    if (controller == null || await controller.isLoading())
      throw Exception("HTML editor is still loading, please wait before evaluating this JS: $source!");
    await controller.evaluateJavascript(source: source);
  }
}