import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> groceries = [];
  final textController = TextEditingController();
  int? groceryIndex;
  IconData addIcon = Icons.add;

  @override
  void initState() {
    super.initState();
    _loadGroceries();
  }

  void _loadGroceries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      groceries = prefs.getStringList('groceries') ?? [];
    });
  }

  void _saveGroceries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('groceries', groceries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            const Text('Add Items to Grocery List:'),
            Expanded(
                child: TextField(
              controller: textController,
            )),
            ElevatedButton(
                child: Icon(addIcon),
                onPressed: () {
                  setState(() {
                    if (groceryIndex != null) {
                      groceries[groceryIndex!] = textController.text;
                      groceryIndex = null;
                      addIcon = Icons.add;
                    } else {
                      groceries.add(textController.text);
                    }
                    textController.clear();
                    _saveGroceries();
                  });
                }),
          ],
        ),
      ),
      body: ListView.builder(
          itemCount: groceries.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
                child: ListTile(
              title: Text(groceries[index]),
              onTap: () {
                groceryIndex = index;
                setState(() {
                  textController.text = groceries[index];
                  addIcon = Icons.save;
                });
              },
              onLongPress: () {
                setState(() {
                  groceries.removeAt(index);
                  _saveGroceries();
                });
              },
            ));
          }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Note* Long press item to remove from list. Click item to edit then save."),
      ),
    );
  }
}
