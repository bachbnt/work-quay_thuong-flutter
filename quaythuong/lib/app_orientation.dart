import 'package:flutter/material.dart';

class AppOrientation extends StatefulWidget {
  final List<Widget> children;

  const AppOrientation({Key? key, required this.children}) : super(key: key);

  @override
  _AppOrientationState createState() => _AppOrientationState();
}

class _AppOrientationState extends State<AppOrientation> {
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.portrait) {
      return Column(
        children: widget.children,
      );
    }
    return Row(
      children: widget.children,
    );
  }
}
