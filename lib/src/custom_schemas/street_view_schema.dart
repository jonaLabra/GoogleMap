import 'package:json_theme/json_theme_schemas.dart';

class StreetViewSchema {
  static const id = 'https://your-url-here.com/schemas/streetView';

  static final schema = {
    r'$schema': 'http://json-schema.org/draft-06/schema#',
    r'$id': '$id',
    'title': 'StreetViewBuilder',
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'lat': SchemaHelper.numberSchema,
      'lng': SchemaHelper.numberSchema
    },
  };
}
