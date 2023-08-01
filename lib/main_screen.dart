import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_example/constants.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_example/tflite_magager/classifier.dart';

class MainScreen extends StatefulWidget
{
  const MainScreen({super.key});

  @override
  State<StatefulWidget> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen>
{
  XFile? _myImage;
  String _detectedImage = "Undefined!";
  late Classifier _classifier;
  bool _isDetecting = false;

  @override
  void initState()
  {
    super.initState();
    _loadClassifier();
  }

  Future<void> _loadClassifier() async {
    debugPrint(
      'Start loading of Classifier with '
          'labels at $tfLiteLabel, '
          'model at $tfLiteModel',
    );

    final classifier = await Classifier.loadWith(
      labelsFileName: tfLiteLabel,
      modelFileName: tfLiteModel,
    );

    setState(() {
      _classifier = classifier!;
    });
  }

  Future<void> _pickImage() async
  {
    final ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (file != null) _myImage = file;
    });
  }

  Future<void> _detectImage() async
  {
    _setDetecting(true);

    File image =  File(_myImage!.path);

    final imageInput = img.decodeImage(image.readAsBytesSync())!;

    final resultCategory = _classifier.predict(imageInput);

    final result = resultCategory.score >= 0.8
        ? setLabel("Image Found!")
        : setLabel("Image Not Found!");
    final plantLabel = resultCategory.label;
    // final accuracy = resultCategory.score;

    setLabel(plantLabel);
    _setDetecting(false);
  }

  void setLabel(String label)
  {
    setState(() {
      _detectedImage = label;
    });
  }

  void _setDetecting(bool status)
  {
    setState(() {
      _isDetecting = status;
    });
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TFLite Example"),
        backgroundColor: Colors.black,
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          fit: StackFit.passthrough,
          children: [

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                (_myImage != null) ?
                Image.file(File(_myImage!.path), width: 200) :
                const SizedBox(),

                const SizedBox(height: 40),

                ElevatedButton(
                    onPressed: (){
                      _pickImage();
                    },
                    child: const Text("Pick Image",
                        style: TextStyle(fontSize: 18))
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                    onPressed: (){
                      _detectImage();
                    },
                    child: const Text("Detect Image",
                        style: TextStyle(fontSize: 18))
                ),

                const SizedBox(height: 40),

                Text(_detectedImage,
                    style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600)),

              ],
            ),

            (_isDetecting) ? const Center(
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator()
              ),
            ) : const SizedBox(),

          ],
        ),
      ),
    );
  }
}