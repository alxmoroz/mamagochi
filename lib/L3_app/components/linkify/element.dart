// Copyright (c) 2024. Alexandr Moroz

extension MamagochiUriExt on Uri {
  bool get isInner => (['mamagochi.ru', 'test.mamagochi.ru', 'localhost', '127.0.0.1'].contains(host));
}

abstract class SpanElement {
  SpanElement(this.text);
  String text;

  @override
  String toString() => text;
}

class TextElement extends SpanElement {
  TextElement(super.text);
}

abstract class UriElement extends SpanElement {
  static final _leadingSlashes = RegExp(r'^/+');
  static final _trailingSlashes = RegExp(r'/+$');

  UriElement(super.text) {
    if (text.startsWith('/')) {
      text = text.replaceFirst(_leadingSlashes, '');
    }
    if (text.endsWith('/')) {
      text = text.replaceFirst(_trailingSlashes, '');
    }
    uri = Uri.tryParse(text);
  }

  Uri? uri;

  bool get hasUri => uri != null;

  @override
  String toString() => uri?.hasAuthority == true ? uri!.host : text;
}
