import '../element.dart';
import '../parser.dart';

class UserTagElement extends UriElement {
  UserTagElement(super.text) {
    uri = Uri(userInfo: text);
  }
}

class UserTagParser extends UriParser {
  const UserTagParser();

  static final _userTagRe = RegExp(r'^(.*?)@([\w\d]*?)', caseSensitive: false, dotAll: true);

  @override
  RegExp get re => _userTagRe;

  @override
  SpanElement matchedElement(String text) => UserTagElement(text);
}
