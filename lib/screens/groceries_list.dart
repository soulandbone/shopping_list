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
  var isLoading = true;
  String? _error;

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  void _loadItems() async {
    final url = Uri.https(
      'shopping-list-app-b58bb-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    http.Response response;

    try {
      response = await http.get(url);

      if (response.statusCode >= 400) {
        throw Error();
      }
    } catch (err) {
      setState(() {
        _error = 'Failed to fetch data, please try again later';
      });
      return;
    }

    if (response.body == 'null') {
      setState(() {
        isLoading = false;
      });
      return;
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

    setState(() {
      _groceryItems = loadedItems;
      isLoading = false;
    });
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
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
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

    if (isLoading) {
      content = Center(child: CircularProgressIndicator());
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
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
      );
    }

    if (_error != null) {
      content = Center(child: Text(_error!, style: TextStyle(fontSize: 16)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),

      body: content,
    );
  }
}
