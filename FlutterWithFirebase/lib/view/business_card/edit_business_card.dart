import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:mlkit/mlkit.dart';
import 'package:flutfire/utils/acc_app_constants.dart' as AppConstants;
import 'package:flutfire/utils/widget_utility.dart';
import 'package:flutfire/data/business_card/acc_businesscard_data_helper.dart';

class EditBusinessCard extends StatefulWidget {
  static const int MODE_EDIT = 1;
  static const int MODE_SCAN_NEW = 2;
  final File _file;
  int _mode;
  String _bcString;
  String _key;

  EditBusinessCard(this._file, this._mode, this._bcString, this._key);

  @override
  State<StatefulWidget> createState() {
    return _AccScanDetailState();
  }
}

class _AccScanDetailState extends State<EditBusinessCard> {
  static const String LABEL_SAVE = "SAVE";
  static const String LABEL_UPDATE = "UPDATE";
  final saveTFieldController = TextEditingController();
  final bcTFieldController = TextEditingController();

  FirebaseVisionTextDetector textDetector = FirebaseVisionTextDetector.instance;

  bool _showProgress = false;
  String _multilineBc = "";
  String _bcTitle = "";

  Stream sub;
  StreamSubscription<dynamic> subscription;

  @override
  void initState() {
    super.initState();
    sub = new Stream.empty();
    subscription = sub.listen((_) => _getImageSize)..onDone(analyzeLabels);
  }

  void analyzeLabels() async {
    if (widget._mode == EditBusinessCard.MODE_SCAN_NEW) {
      try {
        List<VisionText> currentLabels;
        currentLabels = await textDetector.detectFromPath(widget._file.path);
        if (this.mounted) {
          setState(() {
            _multilineBc = visionTextToMultilineBC(currentLabels);
          });
        }
      } catch (e) {
        print("MyEx: " + e.toString());
      }
    } else {
      setState(() {
        _multilineBc = widget._bcString;
        _bcTitle = widget._key;
      });
    }
  }

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
          title: new Text((widget._mode == EditBusinessCard.MODE_EDIT
                  ? LABEL_UPDATE
                  : LABEL_SAVE) +
              " Business Card"),
        ),
        body: WidgetUtility.getStackWithProgressbar(
            Container(
                color: WidgetUtility.getGlobalScreenBgColor(),
                child: WidgetUtility.buildPadding(
                    buildBodyContainer(),
                    AppConstants.GLOBAL_SCREEN_LEFT_PADDING,
                    AppConstants.GLOBAL_SCREEN_RIGHT_PADDING,
                    5,
                    5)),
            _showProgress));
  }

  Widget buildBodyContainer() {
    saveTFieldController.text = _bcTitle;
    return Column(
      children: <Widget>[
        WidgetUtility.buildPadding(buildSaveTextField(), 0, 0, 15, 15),
        buildBody(),
        buildSaveButton()
      ],
    );
  }

  Widget buildSaveButton() {
    return RaisedButton(
        onPressed: () => onSaveTapped(),
        color: Colors.green,
        textColor: Colors.white,
        shape: WidgetUtility.getShape(5.0),
        child: new Text(widget._mode == EditBusinessCard.MODE_EDIT
            ? LABEL_UPDATE
            : LABEL_SAVE));
  }

  Widget buildSaveTextField() {
    return TextField(
      controller: saveTFieldController,
      decoration: InputDecoration(
        labelText: "Save as",
        hintText: 'Please enter a name to save the business card',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
    );
  }

  void onSaveTapped() async {
    if (bcTFieldController.text == null || bcTFieldController.text.isEmpty) {
      WidgetUtility.showFlutterToast("Nothing to save!");
      return;
    }
    if (saveTFieldController.text == null ||
        saveTFieldController.text.isEmpty) {
      WidgetUtility.showFlutterToast(
          "Enter valid name to save this Business card!!");
      return;
    }
    _multilineBc =
        bcTFieldController.text; // copy updated text in the text field
    _bcTitle = saveTFieldController.text; // copy updated text in the text field
    setState(() {
      _showProgress = true;
    });
    bool saveSuccessful = await AccBusinessCardDataHelper.saveBusinessCard(
        saveTFieldController.text, bcTFieldController.text.split("\n"));
    setState(() {
      _showProgress = false;
    });
    String statusMessage =
        saveSuccessful ? "Save successful" : "Save failed. Try later!!";
    WidgetUtility.showFlutterToast(statusMessage);
    Navigator.of(context).pop(true); //return the value true to the caller..
  }

  Widget buildBody() {
    if (_multilineBc.isEmpty) {
      return Expanded(
          flex: 1,
          child: Center(
            child: Text('No text detected',
                style: Theme.of(context).textTheme.subhead),
          ));
    }
    bcTFieldController.text = _multilineBc;
    return Expanded(
        flex: 1,
        child: Container(
            child: TextField(
          maxLines: 10,
          controller: bcTFieldController,
          decoration: InputDecoration(
            labelText: "Edit",
            hintText: 'Business Card text goes here',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        )));
  }

  String visionTextToMultilineBC(List<VisionText> texts) {
    StringBuffer multiline = StringBuffer();
    for (int i = 0; i < texts.length; i++) {
      multiline.write(texts[i].text);

      if (i != (texts.length - 1)) multiline.write("\n");
    }
    return multiline.toString();
  }

  Future<Size> _getImageSize(Image image) {
    Completer<Size> completer = Completer<Size>();
    image.image.resolve(ImageConfiguration()).addListener(
        (ImageInfo info, bool _) => completer.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble())));
    return completer.future;
  }
}
