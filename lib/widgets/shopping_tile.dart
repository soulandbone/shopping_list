import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';

class ShoppingTile extends StatelessWidget {
  const ShoppingTile(this.groceryItem, {super.key});

  final GroceryItem groceryItem;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.square, color: groceryItem.category.color),
      title: Text(groceryItem.name),
      trailing: Text(
        groceryItem.quantity.toString(),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
