import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:quaythuongadmin/config.dart';
import 'package:quaythuongadmin/home_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeApp(
      apiKey: apiKey,
      authDomain: authDomain,
      databaseURL: databaseURL,
      projectId: projectId,
      storageBucket: storageBucket,
      messagingSenderId: messagingSenderId,
      appId: appId,
      measurementId: measurementId);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeView(),
    );
  }
}
