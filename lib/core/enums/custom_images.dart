import 'package:flutter/material.dart';

enum CustomImages {
  inner_bg_4,
  dad_daughter,
  img_1;

  String get imagePath => 'assets/images/$name.png';

  AssetImage get buildImage => AssetImage(imagePath);
}
