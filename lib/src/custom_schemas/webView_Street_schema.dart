import 'package:json_theme/json_theme_schemas.dart';

class WebViewStreetSchema {
  static const id = 'https://your-url-here.com/schemas/streetView';

  static final schema = {
    r'$schema': 'http://json-schema.org/draft-06/schema#',
    r'$id': '$id',
    'title': 'WebViewStreetBuilder',
    'type': 'object',
    'additionalProperties': false,
  };
}
