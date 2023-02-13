import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Image Processing"),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            IconButton(icon: const Icon(Icons.camera_alt), onPressed: () => {}),
            IconButton(
                icon: const Icon(Icons.account_circle), onPressed: () => {})
          ],
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {},
            // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
            style: ElevatedButton.styleFrom(
                elevation: 12.0,
                textStyle: const TextStyle(color: Colors.white)),
            child: const Text('Process Image'),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          onPressed: () => {},
          child: const Icon(Icons.add),
        ),
        /*floatingActionButton:FloatingActionButton.extended(
        onPressed: () {},
        icon: Icon(Icons.save),
        label: Text("Save"),
      ), */
      ),
    );
  }
}
