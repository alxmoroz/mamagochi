import '../element.dart';
import '../parser.dart';

class PhoneElement extends UriElement {
  static final _sugarRe = RegExp(r'[^+\d]');
  static final _phoneScheme = RegExp(r'tel:');

  PhoneElement(super.text) {
    uri = Uri(scheme: 'tel', path: text.replaceAll(_sugarRe, ''));
    text = text.replaceFirst(_phoneScheme, '');
  }
}

class PhoneParser extends UriParser {
  const PhoneParser();

  static final _phoneRe = RegExp(
    r'^(.*?)(tel:\+[1-9]\d{10,14}|(?:\+?[1-9]{1,4}[ ]?)?(?:\d{1,3}|\(?\d{1,5}\))+(?:-?[ ]?\d){6,14})',
    dotAll: true,
  );

  @override
  RegExp get re => _phoneRe;

  @override
  SpanElement matchedElement(String text) => PhoneElement(text);
}
