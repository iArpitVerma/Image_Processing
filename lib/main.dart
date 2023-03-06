import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Identifier',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'Plant Identifier'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final picker = ImagePicker();
  File? _imageFile;
  String _result = '';

  Future _getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future _getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  Future _identifyPlant() async {
    final apiUrl = Uri.parse(
        'https://my-api.plantnet.org/v2/identify/all/species?api-key=2b10M0iqMG6ZsVaRtP6yhgF8u&organs=leaf&lang=en');

    if (_imageFile == null) {
      setState(() {
        _result = 'Please take a picture first.';
      });
      return;
    }

    final imageBytes = await _imageFile!.readAsBytes();

    final response = await http.post(apiUrl,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'api-key 2b10M0iqMG6ZsVaRtP6yhgF8u'
        },
        body: jsonEncode({
          'organs': ['leaf'],
          'images': [
            {'data': base64Encode(imageBytes)}
          ]
        }));

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final result = responseBody['suggestions'][0]['plant_name'];

      setState(() {
        _result = 'The plant is a $result.';
      });
    } else {
      setState(() {
        _result = 'Identification failed. Error code: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Center(child: Text(widget.title)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _imageFile != null
                  ? Image.file(
                      _imageFile!,
                      height: 300,
                    )
                  : Text('No image selected.'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getImageFromCamera,
                child: Text('Take picture'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getImageFromGallery,
                child: Text('Upload picture'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _identifyPlant,
                child: Text('Identify Plant'),
              ),
              SizedBox(height: 20),
              Text(
                _result,
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// void main() {
//   runApp(const PlantIdentificationScreen());
// }
//
// class PlantIdentificationScreen extends StatefulWidget {
//   const PlantIdentificationScreen({super.key});
//
//   @override
//   _PlantIdentificationScreenState createState() =>
//       _PlantIdentificationScreenState();
// }
//
// class _PlantIdentificationScreenState extends State<PlantIdentificationScreen> {
//   final String _apiKey = 2b10M0iqMG6ZsVaRtP6yhgF8u;
//   final picker = ImagePicker();
//   File? _imageFile;
//   String? _identificationResult;
//
//   Future<void> _takePhoto() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//     setState(() {
//       if (pickedFile != null) {
//         _imageFile = File(pickedFile.path);
//         _identificationResult = null;
//       } else {
//         print('No image selected.');
//       }
//     });
//   }
//
//   void _identifyPlant() async {
//     const String apiUrl = 'https://my-api.plantnet.org/v2/projects/all/';
//     final bytes = _imageFile?.readAsBytesSync();
//     final base64Image = base64Encode(bytes as List<int>);
//
//     if (_imageFile == null) {
//       print('not');
//     }
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: {'api-key': _apiKey},
//       body: {'organs': 'leaf', 'images': base64Image},
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final candidates = data['results'][0]['candidates'];
//       if (candidates.isNotEmpty) {
//         setState(() {
//           _identificationResult = candidates[0]['species']['commonName'];
//         });
//       } else {
//         setState(() {
//           _identificationResult = 'No matches found.';
//         });
//       }
//     } else {
//       print('Identification failed: ${response.statusCode}');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Plant Identification'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               if (_imageFile != null) ...[
//                 Image.file(
//                   _imageFile!,
//                   height: 200.0,
//                   width: 200.0,
//                 ),
//                 SizedBox(height: 16.0),
//                 ElevatedButton(
//                   onPressed: _identifyPlant,
//                   child: Text('Identify Plant'),
//                 ),
//                 if (_identificationResult != null) ...[
//                   SizedBox(height: 16.0),
//                   Text('Identification result: $_identificationResult'),
//                 ],
//               ] else ...[
//                 Icon(Icons.image, size: 100.0),
//                 SizedBox(height: 16.0),
//                 ElevatedButton(
//                   onPressed: _takePhoto,
//                   child: Text('Take Photo'),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
//
// void main() {
//   runApp(PlantIdentification());
// }
//
// class PlantIdentification extends StatefulWidget {
//   @override
//   _PlantIdentificationState createState() => _PlantIdentificationState();
// }
//
// class _PlantIdentificationState extends State<PlantIdentification> {
//   final String _apiKey =
//       '2b10M0iqMG6ZsVaRtP6yhgF8u'; // Replace <your-api-key> with your actual API key
//   File? _imageFile;
//   String _plantName = '';
//
//   Future<void> _takePicture() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }
//
//   Future<void> _identifyPlant() async {
//     if (_imageFile == null) {
//       return;
//     }
//
//     final url = Uri.parse('https://my-api.plantnet.org/v2/identify/all');
//
//     final request = http.MultipartRequest('POST', url);
//
//     request.headers['Api-Key'] = _apiKey;
//
//     final imageBytes = await _imageFile!.readAsBytes();
//     final image = http.MultipartFile.fromBytes('images[]', imageBytes,
//         filename: 'plant_image.jpg');
//     request.files.add(image);
//
//     final response = await request.send();
//     print(response.statusCode);
//     print(response.reasonPhrase);
//     print(await response.stream.bytesToString());
//
//     if (response.statusCode == 200) {
//       final decodedData = json.decode(await response.stream.bytesToString());
//
//       if (decodedData != null &&
//           decodedData['suggestions'] != null &&
//           decodedData['suggestions'].length > 0) {
//         setState(() {
//           _plantName = decodedData['suggestions'][0]['plant_name'];
//         });
//       } else {
//         setState(() {
//           _plantName = 'Plant not found.';
//         });
//       }
//     } else {
//       setState(() {
//         _plantName = 'Error: ${response.reasonPhrase}';
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Plant Identification'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               if (_imageFile != null)
//                 Image.file(
//                   _imageFile!,
//                   height: 300,
//                   width: 300,
//                 ),
//               ElevatedButton(
//                 onPressed: _takePicture,
//                 child: Text('Take Picture'),
//               ),
//               ElevatedButton(
//                 onPressed: _identifyPlant,
//                 child: Text('Identify Plant'),
//               ),
//               Text(
//                 _plantName,
//                 style: TextStyle(fontSize: 20),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// void main() {
//   runApp(CameraExample());
// }
//
// class CameraExample extends StatefulWidget {
//   @override
//   _CameraExampleState createState() => _CameraExampleState();
// }
//
// class _CameraExampleState extends State<CameraExample> {
//   File? _imageFile;
//   String _plantName = '';
//
//   Future<void> _getImage(ImageSource source) async {
//     final pickedFile = await ImagePicker().pickImage(source: source);
//
//     setState(() {
//       if (pickedFile != null) {
//         _imageFile = File(pickedFile.path);
//         _plantName = '';
//         _identifyPlant(_imageFile!);
//       } else {
//         print('No image selected.');
//       }
//     });
//   }
//
//   Future<void> _identifyPlant(File image) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('https://my-api.plantnet.org/v2/identify'),
//     );
//     request.headers['Content-Type'] = 'multipart/form-data';
//     request.headers['Api-Key'] = '2b10Zpe2CnppnWK4JHXpmIZS';
//     request.fields['organs'] = 'leaf';
//     request.files.add(
//       await http.MultipartFile.fromPath(
//         'images',
//         image.path,
//         filename: 'plant_image.jpg',
//       ),
//     );
//
//     final response = await request.send();
//
//     final data = await response.stream.transform(utf8.decoder).join();
//     final decodedData = jsonDecode(data);
//     if (decodedData != null &&
//         decodedData['suggestions'] != null &&
//         decodedData['suggestions'].length > 0) {
//       setState(() {
//         _plantName = decodedData['suggestions'][0]['plant_name'];
//       });
//     } else {
//       setState(() {
//         _plantName = 'Plant not found.';
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plant Identification'),
//         ),
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _imageFile == null
//                 ? const Text('No image selected.')
//                 : Image.file(_imageFile!),
//             SizedBox(height: 16),
//             Text(
//               _plantName,
//               style: TextStyle(fontSize: 24),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//         floatingActionButton: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             FloatingActionButton(
//               onPressed: () => _getImage(ImageSource.camera),
//               tooltip: 'Take a photo',
//               child: Icon(Icons.camera),
//             ),
//             SizedBox(height: 16),
//             FloatingActionButton(
//               onPressed: () => _getImage(ImageSource.gallery),
//               tooltip: 'Select a photo',
//               child: Icon(Icons.photo_library),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
//

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text("Image Processing"),
//           backgroundColor: Colors.blue,
//           actions: <Widget>[
//             IconButton(icon: const Icon(Icons.camera_alt), onPressed: () => {}),
//             IconButton(
//                 icon: const Icon(Icons.account_circle), onPressed: () => {})
//           ],
//         ),
//         body: Center(
//           child: ElevatedButton(
//             onPressed: () {},
//             // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
//             style: ElevatedButton.styleFrom(
//                 elevation: 12.0,
//                 textStyle: const TextStyle(color: Colors.white)),
//             child: const Text('Process Image'),
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           backgroundColor: Colors.blue,
//           foregroundColor: Colors.white,
//           onPressed: () => {},
//           child: const Icon(Icons.add),
//         ),
//         /*floatingActionButton:FloatingActionButton.extended(
//         onPressed: () {},
//         icon: Icon(Icons.save),
//         label: Text("Save"),
//       ), */
//       ),
//     );
//   }
// }
