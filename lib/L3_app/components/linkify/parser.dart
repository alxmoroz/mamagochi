import 'element.dart';
import 'parsers/email.dart';
import 'parsers/http.dart';
import 'parsers/phone.dart';

abstract class UriParser {
  const UriParser();

  SpanElement _elFromText(String text) => (text.isNotEmpty) ? matchedElement(text) : TextElement('');
  List<SpanElement> _parseMatch(RegExpMatch match) => [TextElement(match.group(1) ?? ''), _elFromText(match.group(2) ?? '')];

  RegExp get re;
  SpanElement matchedElement(String text);

  List<SpanElement> parse(List<SpanElement> elements) {
    final parsedElements = <SpanElement>[];

    for (final el in elements) {
      if (el is TextElement) {
        final match = re.firstMatch(el.text);

        if (match != null) {
          parsedElements.addAll(_parseMatch(match));

          final lastText = el.text.replaceAll(match[0]!, '');
          if (lastText.isNotEmpty) {
            parsedElements.addAll(parse([TextElement(lastText)]));
          }
        } else {
          parsedElements.add(el);
        }
      } else {
        parsedElements.add(el);
      }
    }

    return parsedElements;
  }
}

List<SpanElement> parse(
  String text, {
  bool looseUrl = true,
  List<UriParser> parsers = const [EmailParser(), HttpParser(), PhoneParser()],
}) {
  List<SpanElement> spans = [];

  if (text.isNotEmpty) {
    spans.add(TextElement(text));
    for (final p in parsers) {
      spans = p.parse(spans);
    }
  }

  return spans;
}
