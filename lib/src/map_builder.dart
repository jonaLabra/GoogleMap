import 'package:example/src/components/google_maps.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:child_builder/src/child_widget_builder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_class/json_class.dart';

class GoogleMapBuilder extends JsonWidgetBuilder {
  GoogleMapBuilder({this.lat, this.lng})
      : assert(lat != 0.0),
        super(numSupportedChildren: kNumSupportedChildren);

  static const kNumSupportedChildren = 1;
  static const type = 'GoogleMap';
  final double lat;
  final double lng;

  static GoogleMapBuilder fromDynamic(dynamic map,
      {JsonWidgetRegistry registry}) {
    GoogleMapBuilder result;

    if (map != null) {
      result = GoogleMapBuilder(
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
      '[GoogleMapBuilder] does not support children.',
    );
    return GoogleMaps();
  }
}
