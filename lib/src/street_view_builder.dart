import 'package:example/src/components/street_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:child_builder/src/child_widget_builder.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_class/json_class.dart';

class StreetViewBuilder extends JsonWidgetBuilder {
  StreetViewBuilder({this.lat, this.lng})
      : assert(lat != 0.0),
        super(numSupportedChildren: kNumSupportedChildren);

  static const kNumSupportedChildren = 1;
  static const type = 'StreetView';
  final double lat;
  final double lng;

  static StreetViewBuilder fromDynamic(dynamic map,
      {JsonWidgetRegistry registry}) {
    StreetViewBuilder result;

    if (map != null) {
      result = StreetViewBuilder(
          lat: JsonClass.parseDouble(map['lat']),
          lng: JsonClass.parseDouble(map['lng']));
    }

    return result;
  }

  @override
  Widget buildCustom(
      {ChildWidgetBuilder childBuilder,
      BuildContext context,
      JsonWidgetData data,
      Key key}) {
    assert(
      data.children?.isNotEmpty != true,
      '[StreetViewBuilder] does not support children.',
    );
    // ignore: prefer_collection_literals
    return StreetView(lat: lat, lng: lng).build(context);
    ;
  }
}
