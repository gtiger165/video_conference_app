import 'dart:math';

import 'package:flutter/material.dart';

void toPage(BuildContext context, Widget widget) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
}

int generateRandomNumber() {
  var randomNumber = Random();
  var nextNumber = randomNumber.nextDouble() * 10000;
  while (nextNumber < 10000) {
    nextNumber *= 10;
  }
  return nextNumber.toInt();
}
