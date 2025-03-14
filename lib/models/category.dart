import 'package:flutter/material.dart';

enum Categories {
  vegetables,
  dairy,
  fruit,
  meat,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other,
}

class Category {
  const Category(this.name, this.color);

  final String name;
  final Color color;
}
