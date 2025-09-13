import 'package:flutter/material.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => MaterialApp(
        title: 'Flutter Demo',
        initialRoute: Routes.root,
        onGenerateRoute: RoutesGenerator.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
