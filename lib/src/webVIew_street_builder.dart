import 'package:example/src/components/street_view.dart';
import 'package:example/src/components/webView_Street.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:child_builder/src/child_widget_builder.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_class/json_class.dart';

class WebViewStreetBuilder extends JsonWidgetBuilder {
  WebViewStreetBuilder() : super(numSupportedChildren: kNumSupportedChildren);

  static const kNumSupportedChildren = 1;
  static const type = 'WebViewStreet';

  static WebViewStreetBuilder fromDynamic(dynamic map,
      {JsonWidgetRegistry registry}) {
    WebViewStreetBuilder result;

    if (map != null) {
      result = WebViewStreetBuilder();
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
    return WebStreetView();
  }
}
