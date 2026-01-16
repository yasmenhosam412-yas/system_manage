import 'dart:ui';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:system_manage/core/utils/app_colors.dart';

class Toasts {
  static displayToast(String text, [Color? color]) {
    Fluttertoast.showToast(
      msg: text,
      backgroundColor: color ?? AppColors.primaryColor,
    );
  }
}
