import 'package:flutter/material.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/new_item.dart';
import 'package:shopping_list/widgets/shopping_tile.dart';

class GroceriesList extends StatefulWidget {
  const GroceriesList({super.key});

  @override
  State<GroceriesList> createState() => _GroceriesListState();
}

class _GroceriesListState extends State<GroceriesList> {
  final List<GroceryItem> _groceryItems = [];

  void _addItem() async {
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (context) => NewItem()));

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void deleteItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final groceries = _groceryItems;
    Widget content = const Center(
      child: Text(
        'There are currently no items on your list',
        style: TextStyle(fontSize: 16),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),

      body:
          _groceryItems.isEmpty
              ? content
              : ListView.builder(
                itemCount: groceries.length,
                itemBuilder:
                    (context, index) => Dismissible(
                      onDismissed: (direction) {
                        deleteItem(groceries[index]);
                      },
                      key: ValueKey(groceries[index].id),
                      child: ShoppingTile(
                        GroceryItem(
                          id: groceries[index].id,
                          name: groceries[index].name,
                          quantity: groceries[index].quantity,
                          category: groceries[index].category,
                        ),
                      ),
                    ),
              ),
    );
  }
}
