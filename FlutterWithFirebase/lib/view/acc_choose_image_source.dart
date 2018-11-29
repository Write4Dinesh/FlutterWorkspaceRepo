import 'package:flutfire/view/business_card/edit_business_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutfire/utils/acc_app_constants.dart' as AppConstants;
import 'package:flutfire/business_logic/models/scanner_model.dart';
import 'package:flutfire/view/acc_barcode_scan_detail.dart';
import 'package:flutfire/view/acc_face_scan_detail.dart';
import 'package:flutfire/view/acc_label_scan_detail.dart';
import 'package:flutfire/utils/widget_utility.dart';

const String PICK_IMAGE_LABEL_CAMERA = 'Camera';
const String PICK_IMAGE_LABEL_GALLERY = 'Gallery';

/* ************************WIDGET class **************************/
class ACCChooseImageSource extends StatefulWidget {
  final String title;
  final ScannerModel scannerModel;

  ACCChooseImageSource(this.scannerModel,
      {Key key, this.title: 'Pick an image from'})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _ACCChooseImageSourceState(scannerModel);
}
/* ************************STATE class **************************/

class _ACCChooseImageSourceState extends State<ACCChooseImageSource> {
  static const String CAMERA_SOURCE = 'CAMERA_SOURCE';
  static const String GALLERY_SOURCE = 'GALLERY_SOURCE';
  ScannerModel scannerModel;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _ACCChooseImageSourceState(this.scannerModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.scannerModel.screenTitle),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              buildTitleWidget(context, widget.title),
              buildRaisedButton(
                  context, PICK_IMAGE_LABEL_CAMERA, CAMERA_SOURCE),
              buildRaisedButton(
                  context, PICK_IMAGE_LABEL_GALLERY, GALLERY_SOURCE)
            ],
          ),
        ));
  }

  Widget buildTitleWidget(BuildContext context, String title) {
    return Center(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 26.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headline,
      ),
    ));
  }

  /* ++++++++++++++++++++++ build Raised Buttons to pick image form either Gallery or Camera +++++++++++++++++++ */
  Widget buildRaisedButton(
      BuildContext context, String label, String scanType) {
    return RaisedButton(
        padding: EdgeInsets.only(left: 50.0, right: 50.0),
        color: Colors.green,
        textColor: Colors.white,
        splashColor: Colors.blueGrey,
        onPressed: () {
          onPickImageSelected(scanType);
        },
        shape: WidgetUtility.getShape(5.0),
        child: Text(label));
  }

  /* ++++++++++++++ pick an image from either gallery or camera ++++++++++++++ */
  void onPickImageSelected(String source) async {
    var imageSource =
        (source == CAMERA_SOURCE) ? ImageSource.camera : ImageSource.gallery;
    final scaffold = _scaffoldKey.currentState;

    try {
      final pickedImageFile = await ImagePicker.pickImage(source: imageSource);
      if (pickedImageFile == null) {
        throw Exception('File is not available');
      }
      // Image file is fetched successfully. pass this to next screen for processing
      goToNextScreen(context, pickedImageFile);
    } catch (e) {
      scaffold.showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  void goToNextScreen(BuildContext context, File pickedImageFile) {
    var detailObj;
    switch (this.scannerModel.type) {
      case AppConstants.TEXT_SCANNER:
        detailObj = EditBusinessCard(
            pickedImageFile, EditBusinessCard.MODE_SCAN_NEW, null,null);

        break;
      case AppConstants.BARCODE_SCANNER:
        detailObj = AccBarcodeScanDetail(pickedImageFile);

        break;
      case AppConstants.FACE_SCANNER:
        detailObj = AccFaceScanDetail(pickedImageFile);

        break;
      case AppConstants.LABEL_SCANNER:
        detailObj = AccLabelScanDetail(pickedImageFile);

        break;
    }
    Navigator.push(
        context, new MaterialPageRoute(builder: (context) => detailObj));
  }
}