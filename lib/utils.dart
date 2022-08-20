import 'package:flutter/material.dart';

class Utils {
  BuildContext context;
  Utils(this.context);

  EdgeInsets get padding => MediaQuery.of(context).padding;

  double height(double num) {
    return MediaQuery.of(context).size.height * (num / 100);
  }

  double width(double num) {
    return MediaQuery.of(context).size.width * (num / 100);
  }
}
