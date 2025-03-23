import '../element.dart';
import '../parser.dart';

class EmailElement extends UriElement {
  EmailElement(super.text) {
    if (hasUri) uri = uri!.replace(scheme: 'mailto');
  }
}

class EmailParser extends UriParser {
  const EmailParser();

  static final _emailRe = RegExp(
    r'^(.*?)((mailto:)?[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z][A-Z]+)',
    caseSensitive: false,
    dotAll: true,
  );

  @override
  RegExp get re => _emailRe;

  @override
  SpanElement matchedElement(String text) => EmailElement(text);
}
