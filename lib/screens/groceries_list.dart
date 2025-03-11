import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/shopping_tile.dart';

class GroceriesList extends StatelessWidget {
  const GroceriesList({super.key});

  @override
  Widget build(BuildContext context) {
    final groceries = groceryItems;

    return Scaffold(
      appBar: AppBar(title: Text('Your Groceries')),
      body: SingleChildScrollView(
        child: Column(
          children:
              groceries
                  .map(
                    (element) => ShoppingTile(
                      GroceryItem(
                        id: element.id,
                        name: element.name,
                        quantity: element.quantity,
                        category: element.category,
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
