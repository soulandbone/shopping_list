import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screens/new_item.dart';
import 'package:shopping_list/widgets/shopping_tile.dart';

class GroceriesList extends StatefulWidget {
  const GroceriesList({super.key});

  @override
  State<GroceriesList> createState() => _GroceriesListState();
}

class _GroceriesListState extends State<GroceriesList> {
  List<GroceryItem> _groceryItems = [];
  late Future<List<GroceryItem>> _loadedItems;

  @override
  void initState() {
    _loadedItems = _loadItems();
    super.initState();
  }

  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(
      'shopping-list-app-b58bb-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    http.Response response;

    response = await http.get(url);

    if (response.body == 'null') {
      return [];
    }

    final Map<String, dynamic> listData = json.decode(response.body);

    final List<GroceryItem> loadedItems = [];

    for (final item in listData.entries) {
      final category = categories.entries.firstWhere(
        (catItem) => catItem.value.name == item.value['category'],
      );

      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category.value,
        ),
      );
    }

    return loadedItems;
  }

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

  void deleteItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
      'shopping-list-app-b58bb-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch grocery items, please try again later');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),

      body: FutureBuilder(
        future: _loadedItems,
        builder: (content, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'There are currently no items on your list',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          _groceryItems = snapshot.data!;

          return ListView.builder(
            itemCount: _groceryItems.length,
            itemBuilder:
                (context, index) => Dismissible(
                  onDismissed: (direction) {
                    deleteItem(snapshot.data![index]);
                  },
                  key: ValueKey(snapshot.data![index].id),
                  child: ShoppingTile(
                    GroceryItem(
                      id: _groceryItems[index].id,
                      name: _groceryItems[index].name,
                      quantity: _groceryItems[index].quantity,
                      category: _groceryItems[index].category,
                    ),
                  ),
                ),
          );
        },
      ),
    );
  }
}
