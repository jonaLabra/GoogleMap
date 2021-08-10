import 'dart:convert';
import 'dart:typed_data';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:example/src/components/street_view.dart';
import 'package:example/src/custom_schemas/dotted_border_schema.dart';
import 'package:example/src/custom_schemas/google_map_schema.dart';
import 'package:example/src/custom_schemas/svg_schema.dart';
import 'package:example/src/custom_schemas/webView_Street_schema.dart';
import 'package:example/src/dotted_border_builder.dart';
import 'package:example/src/issue_24_page.dart';
import 'package:example/src/map_builder.dart';
import 'package:example/src/provider/maps_data.dart';
import 'package:example/src/street_view_builder.dart';
import 'package:example/src/svg_builder.dart';
import 'package:example/src/webVIew_street_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_theme/json_theme_schemas.dart';
import 'package:logging/logging.dart';
import 'package:screenshot/screenshot.dart';
import 'package:street_view_platform_interface/street_view_platform_interface.dart';

import 'src/components/webView_Street.dart';
import 'src/custom_schemas/street_view_schema.dart';
import 'src/full_widget_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  TestAppSettings.initialize(appIdentifier: 'JSON Dynamic Widget');

  var sc = ScreenshotController();
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      debugPrint('${record.error}');
    }
    if (record.stackTrace != null) {
      debugPrint('${record.stackTrace}');
    }
  });

  var logger = Logger('main');

  var navigatorKey = GlobalKey<NavigatorState>();

  // This is needed to adding custom schema validations
  var schemaCache = SchemaCache();
  schemaCache.addSchema(SvgSchema.id, SvgSchema.schema);
  schemaCache.addSchema(DottedBorderSchema.id, DottedBorderSchema.schema);
  schemaCache.addSchema(GoogleMapSchema.id, GoogleMapSchema.schema);
  schemaCache.addSchema(StreetViewSchema.id, StreetViewSchema.schema);

  var registry = JsonWidgetRegistry.instance;
  registry.registerCustomBuilder(
    DottedBorderBuilder.type,
    JsonWidgetBuilderContainer(
      builder: DottedBorderBuilder.fromDynamic,
      schemaId: DottedBorderSchema.id,
    ),
  );
  registry.registerCustomBuilder(
    SvgBuilder.type,
    JsonWidgetBuilderContainer(
      builder: SvgBuilder.fromDynamic,
      schemaId: SvgSchema.id,
    ),
  );

  registry.registerCustomBuilder(
      GoogleMapBuilder.type,
      JsonWidgetBuilderContainer(
          builder: GoogleMapBuilder.fromDynamic, schemaId: GoogleMapSchema.id));

  registry.registerCustomBuilder(
      StreetViewBuilder.type,
      JsonWidgetBuilderContainer(
          builder: StreetViewBuilder.fromDynamic,
          schemaId: StreetViewSchema.id));

  registry.registerCustomBuilder(
    WebViewStreetBuilder.type,
    JsonWidgetBuilderContainer(
      builder: WebViewStreetBuilder.fromDynamic,
    ),
  );

  StreetViewFlutterPlatform.instance = StreetView(lat: 0.0, lng: 0.0);
  registry.registerFunction('navigatePage', ({args, registry}) async {
    var jsonStr = await rootBundle.loadString('assets/pages/${args[0]}.json');
    var jsonData = json.decode(jsonStr);
    await navigatorKey.currentState.push(
      MaterialPageRoute(
        builder: (BuildContext context) => FullWidgetPage(
          data: JsonWidgetData.fromDynamic(
            jsonData,
            registry: registry,
          ),
        ),
      ),
    );
  });
  ShowCapturedWidget(BuildContext context, Uint8List capturedImage) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text("Captured widget screenshot"),
        ),
        body: Center(
            child: capturedImage != null
                ? Image.memory(capturedImage)
                : Container()),
      ),
    );
  }

  registry.registerFunctions({
    'screenShoot': ({args, registry}) => () async {
          BuildContext context = registry.getValue(args[0]);
          var valid = Form.of(context).validate();
          registry.setValue('form_validation', valid);
          Maps_Data().takeSnapshot(context);
          // ignore: omit_local_variable_types
          /*Uint8List screenshotBytes =
              await Maps_Data().controller.takeScreenshot();
          await ShowCapturedWidget(context, screenshotBytes);
          WebStreetView()
              .createState()
              .screenshotController
              .capture(delay: Duration(milliseconds: 10))
              .then((capturedImage) async {
            print(capturedImage);
            await showDialog(
              useSafeArea: false,
              context: context,
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: Text("Captured widget screenshot"),
                ),
                body: Center(
                    child: capturedImage != null
                        ? Image.memory(capturedImage)
                        : Container(
                            child: Text('Vacio'),
                          )),
              ),
            );
          }).catchError((onError) {
            print(onError);
          });*/
        },
    'getImageAsset': ({args, registry}) => 'assets/images/image${args[0]}.jpg',
    'getImageId': ({args, registry}) => 'image${args[0]}',
    'getImageNavigator': ({args, registry}) => () async {
          registry.setValue('index', args[0]);
          var dataStr =
              await rootBundle.loadString('assets/pages/image_page.json');
          final imagePageJson = Map.unmodifiable(json.decode(dataStr));
          var imgRegistry = JsonWidgetRegistry(
            debugLabel: 'ImagePage',
            values: {
              'imageAsset': 'assets/images/image${args[0]}.jpg',
              'imageTag': 'image${args[0]}',
            },
          );

          await navigatorKey.currentState.push(
            MaterialPageRoute(
              builder: (BuildContext context) => FullWidgetPage(
                data: JsonWidgetData.fromDynamic(
                  imagePageJson,
                  registry: imgRegistry,
                ),
              ),
            ),
          );
        },
    'noop': ({args, registry}) => () {},
    'validateForm': ({args, registry}) => () {
          BuildContext context = registry.getValue(args[0]);

          var valid = Form.of(context).validate();
          registry.setValue('form_validation', valid);
        },
    'updateCustomTextStyle': ({args, registry}) => () {
          registry.setValue(
            'customTextStyle',
            TextStyle(
              color: Colors.black,
            ),
          );
        },
    'getCustomTweenBuilder': ({args, registry}) =>
        (BuildContext context, dynamic size, Widget child) {
          return IconButton(
            icon: child,
            iconSize: size,
            onPressed: () {
              var _current = registry.getValue('customSize');
              var _size = _current == 50.0 ? 100.0 : 50.0;
              registry.setValue('customSize', _size);
            },
          );
        },
    'getCustomTween': ({args, registry}) {
      return Tween<double>(begin: 0, end: args[0]);
    },
    'setWidgetByKey': ({args, registry}) => () {
          var _replace = registry.getValue(args[1]);
          registry.setValue(args[0], _replace);
        },
    'materialCallback': ({args, registry}) => (Set<MaterialState> states) {
          const interactiveStates = <MaterialState>{
            MaterialState.pressed,
            MaterialState.focused,
          };
          if (states.any(interactiveStates.contains)) {
            return Colors.blue;
          }
          return Colors.red;
        },
    'simplePrintMessage': ({args, registry}) => () {
          var message = 'This is a simple print message';
          if (args?.isEmpty == false) {
            for (var arg in args) {
              message += ' $arg';
            }
          }
          // ignore: avoid_print
          print(message);
        },
    'negateBool': ({args, registry}) => () {
          bool value = registry.getValue(args[0]);
          registry.setValue(args[0], !value);
        },
    'buildPopupMenu': ({args, registry}) {
      const choices = ['First', 'Second', 'Third'];
      return (BuildContext context) {
        return choices
            .map(
              (choice) => PopupMenuItem(
                value: choice,
                child: Text(choice),
              ),
            )
            .toList();
      };
    },
  });

  registry.setValue('customRect', Rect.largest);

  try {
    var data = await rootBundle.loadString('secrets/credentials.json');
    if (data != null) {}
  } catch (e) {
    logger.info('');
  }

  runApp(MyApp(
    navigatorKey: navigatorKey,
  ));
}

class MyApp extends StatelessWidget {
  MyApp({
    Key key,
    @required this.navigatorKey,
  })  : assert(navigatorKey != null),
        super(key: key);

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RootPage(),
      navigatorKey: navigatorKey,
      theme: ThemeData.light(),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({
    Key key,
  }) : super(key: key);

  static final _pages = {
    'align': _onPageSelected,
    'animated_align': _onPageSelected,
    'animated_container': _onPageSelected,
    'animated_cross_fade': _onPageSelected,
    'animated_default_text_style': _onPageSelected,
    'animated_opacity': _onPageSelected,
    'animated_padding': _onPageSelected,
    'animated_physical_model': _onPageSelected,
    'animated_positioned': _onPageSelected,
    'animated_positioned_directional': _onPageSelected,
    'animated_size': _onPageSelected,
    'animated_switcher': _onPageSelected,
    'animated_theme': _onPageSelected,
    'aspect_ratio': _onPageSelected,
    'asset_images': _onPageSelected,
    'bank_example': _onPageSelected,
    'baseline': _onPageSelected,
    'buttons': _onPageSelected,
    'card': _onPageSelected,
    'center': _onPageSelected,
    'checkbox': _onPageSelected,
    'circular_progress_indicator': _onPageSelected,
    'clips': _onPageSelected,
    'conditional': _onPageSelected,
    'cupertino_switch': _onPageSelected,
    'decorated_box': _onPageSelected,
    'directionality': _onPageSelected,
    'fitted_box': _onPageSelected,
    'form': _onPageSelected,
    'fractional_translation': _onPageSelected,
    'fractionally_sized_box': _onPageSelected,
    'gestures': _onPageSelected,
    'images': _onPageSelected,
    'indexed_stack': _onPageSelected,
    'input_error': _onPageSelected,
    'interactive_viewer': _onPageSelected,
    'intrinsic_height': _onPageSelected,
    'intrinsic_width': _onPageSelected,
    'issue_10': _onPageSelected,
    'issue_11': _onPageSelected,
    'issue_12': _onPageSelected,
    'issue_20_list': _onPageSelected,
    'issue_20_single': _onPageSelected,
    'issue_24': (context, _) async => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => Issue24Page(),
          ),
        ),
    'limited_box': _onPageSelected,
    'linear_progress_indicator': _onPageSelected,
    'list_view': _onPageSelected,
    'offstage': _onPageSelected,
    'opacity': _onPageSelected,
    'overflow_box': _onPageSelected,
    'placeholder': _onPageSelected,
    'popup_menu_button': _onPageSelected,
    'simple_page': _onPageSelected,
    'switch': _onPageSelected,
    'theme': _onPageSelected,
    'tween_animation': _onPageSelected,
    'googleMap': _onPageSelected,
    'streetView': _onPageSelected,
    'webView': _onPageSelected
  };

  static Future<void> _onPageSelected(
    BuildContext context,
    String themeId,
  ) async {
    JsonWidgetRegistry.instance.clearValues();
    var pageStr = await rootBundle.loadString('assets/pages/$themeId.json');
    var dataJson = json.decode(pageStr);

    // This is put in to give credit for when designs from online were used in
    // example files.  It's not actually a valid attribute to exist in the JSON
    // so it needs to be removed before we create the widget.
    dataJson.remove('_designCredit');

    var data = JsonWidgetData.fromDynamic(dataJson);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => FullWidgetPage(
          data: data,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var names = _pages.keys.toList();
    names.sort();

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Widget / Page'),
      ),
      body: ListView.builder(
        itemCount: _pages.length,
        itemBuilder: (BuildContext context, int index) => ListTile(
          title: Text(names[index]),
          onTap: () => _pages[names[index]](context, names[index]),
        ),
      ),
    );
  }
}
