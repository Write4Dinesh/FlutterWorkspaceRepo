import 'package:flutfire/mlkit/acc_detail.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutfire/utils/acc_app_constants.dart' as AppConstants;

class AccBarcodeScanner extends StatefulWidget {
  final String title;

  AccBarcodeScanner({Key key, this.title: 'Barcode Scan'}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AccBarcodeScannerState(title);
}

class _AccBarcodeScannerState extends State<AccBarcodeScanner> {
  static const String CAMERA_SOURCE = 'CAMERA_SOURCE';
  static const String GALLERY_SOURCE = 'GALLERY_SOURCE';
  String title;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _AccBarcodeScannerState(String title) {
    this.title = title;
  }

  File _file;
  String _selectedScanner = AppConstants.TEXT_SCANNER;

  @override
  Widget build(BuildContext context) {
    final columns = List<Widget>();

    //choose the ML feature
    columns.add(buildRowTitle(context, title));
    columns.add(buildSelectScannerRowWidget(context));

    columns.add(buildRowTitle(context, 'Pick Image'));
    columns.add(buildSelectImageRowWidget(context));

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text('HelloMLFire'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: columns,
          ),
        ));
  }

  Widget buildRowTitle(BuildContext context, String title) {
    return Center(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 26.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headline,
      ),
    ));
  }

  Widget buildSelectImageRowWidget(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: RaisedButton(
              color: Colors.green,
              textColor: Colors.white,
              splashColor: Colors.blueGrey,
              onPressed: () {
                onPickImageSelected(CAMERA_SOURCE);
              },
              child: const Text('Camera')),
        )),
        Expanded(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: RaisedButton(
              color: Colors.green,
              textColor: Colors.white,
              splashColor: Colors.blueGrey,
              onPressed: () {
                onPickImageSelected(GALLERY_SOURCE);
              },
              child: const Text('Gallery')),
        ))
      ],
    );
  }

  Widget buildSelectScannerRowWidget(BuildContext context) {
    return Wrap(
      children: <Widget>[
        RadioListTile<String>(
          title: Text('Text Recognition'),
          groupValue: _selectedScanner,
          value: AppConstants.TEXT_SCANNER,
          onChanged: onScannerSelected,
        ),
        RadioListTile<String>(
          title: Text('Barcode Scanner'),
          groupValue: _selectedScanner,
          value: AppConstants.BARCODE_SCANNER,
          onChanged: onScannerSelected,
        ),
        RadioListTile<String>(
          title: Text('Label Scanner'),
          groupValue: _selectedScanner,
          value: AppConstants.LABEL_SCANNER,
          onChanged: onScannerSelected,
        ),
        RadioListTile<String>(
          title: Text('Face Scanner'),
          groupValue: _selectedScanner,
          value: AppConstants.FACE_SCANNER,
          onChanged: onScannerSelected,
        )
      ],
    );
  }

  Widget buildImageRow(BuildContext context, File file) {
    return SizedBox(
        height: 500.0,
        child: Image.file(
          file,
          fit: BoxFit.fitWidth,
        ));
  }

  Widget buildDeleteRow(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: RaisedButton(
            color: Colors.red,
            textColor: Colors.white,
            splashColor: Colors.blueGrey,
            onPressed: () {
              setState(() {
                _file = null;
              });
              ;
            },
            child: const Text('Delete Image')),
      ),
    );
  }

  void onScannerSelected(String scanner) {
    setState(() {
      _selectedScanner = scanner;
    });
  }

  void onPickImageSelected(String source) async {
    var imageSource;
    if (source == CAMERA_SOURCE) {
      imageSource = ImageSource.camera;
    } else {
      imageSource = ImageSource.gallery;
    }

    final scaffold = _scaffoldKey.currentState;

    try {
      final file = await ImagePicker.pickImage(source: imageSource);
      if (file == null) {
        throw Exception('File is not available');
      }

      Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => AccScanDetail(file, _selectedScanner)),
      );
    } catch (e) {
      scaffold.showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }
}
