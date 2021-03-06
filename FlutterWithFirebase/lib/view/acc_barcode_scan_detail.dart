import 'package:flutfire/view/acc_choose_image_source.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:mlkit/mlkit.dart';
import 'package:flutfire/utils/acc_app_constants.dart' as AppConstants;
import 'package:flutfire/utils/widget_utility.dart';
import 'package:url_launcher/url_launcher.dart';

class AccBarcodeScanDetail extends StatefulWidget {
  final File _file;

  AccBarcodeScanDetail(this._file);

  @override
  State<StatefulWidget> createState() {
    return _AccScanDetailState();
  }
}

class _AccScanDetailState extends State<AccBarcodeScanDetail> {
  FirebaseVisionBarcodeDetector barcodeDetector =
      FirebaseVisionBarcodeDetector.instance;
  List<VisionBarcode> _currentBarcodeLabels = <VisionBarcode>[];
  String _scannedBarcode;
  Stream sub;
  StreamSubscription<dynamic>
      subscription; // Subscribe for Stream of events that come into app asynchronously

  /* called soon after the current widget is inserted into the widget tree*/
  @override
  void initState() {
    super.initState();
    sub = new Stream
        .empty(); // a Stream is a source of events.it emits events one after the other which will be handled by  StreamSubscription
    subscription = sub.listen((_) => _getImageSize)
      ..onDone(
          analyzeLabels); //onDone is called when events finish. the handler method passed as argument
  }

  void analyzeLabels() async {
    try {
      var currentLabels;
      String imageFilePath = widget._file.path;
      currentLabels = await barcodeDetector.detectFromPath(imageFilePath);
      if (this.mounted) {
        // mounted tells whether the current object is inserted into tree. it will be true until dispose is called(mounted=false)
        setState(() {
          _currentBarcodeLabels = currentLabels;
        });
      }
    } catch (e) {
      print("MyEx: " + e.toString());
    }
  }

/* removed this object/stateObject/widgetObject from the view tree..hence, mounted=false*/
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(AppConstants.BARCODE_SCANNER_SCREEN_TITLE),
        ),
        body: WidgetUtility.buildPadding(
            Container(
              color: WidgetUtility.getGlobalScreenBgColor(),
              child: getCard<VisionBarcode>(_currentBarcodeLabels, context),
            ),
            AppConstants.GLOBAL_SCREEN_LEFT_PADDING,
            AppConstants.GLOBAL_SCREEN_RIGHT_PADDING,
            10,
            1));
  }

  void onPressed(BuildContext context, String searchQuery) async {
    final String url = "http://www.google.com/#q=$searchQuery";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Couldn\'t launch the url $url';
    }
  }

  Future<Size> _getImageSize(Image image) {
    Completer<Size> completer = Completer<Size>();
    image.image.resolve(ImageConfiguration()).addListener(
        (ImageInfo info, bool _) => completer.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble())));
    return completer.future;
  }

  Widget getCard<T>(List<T> barcodes, BuildContext context) {
    if (barcodes.length == 0) {
      return Center(
        child: Text('Nothing detected',
            style: Theme.of(context).textTheme.subhead),
      );
    }

    final barcode = barcodes[0];
    VisionBarcode res = barcode as VisionBarcode;
    _scannedBarcode = res.rawValue;
    return Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      ListTile(
          title: Text("The Scanned barcode",
              style: WidgetUtility.getTitleStyle(context)),
          subtitle: Text(
            _scannedBarcode,
            style: WidgetUtility.getSubTitleStyle(context),
          )),
      ButtonTheme.bar(
          child: ButtonBar(children: <Widget>[
        FlatButton(
          child: Text("Search web",style: WidgetUtility.getButtonLabelStyle(context)),
          onPressed: () {
            onPressed(context, _scannedBarcode);
          },
        )
      ]))
    ]));
  }
}
