import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/add_page.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? todo;

  const HomeScreen({Key? key, this.todo}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    fetchTodo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Todo App"),
      ),
      body: RefreshIndicator(
        onRefresh: fetchTodo,
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final id = item['_id'] as String;
            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    navigateToEditPage(item);
                  } else if (value == 'delete') {
                    // delete and remove the item
                    deleteById(id);
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(value: 'edit', child: Text("Edit")),
                    PopupMenuItem(value: 'delete', child: Text("Delete")),
                  ];
                },
              ),
              title: Text(item['title'] ?? 'No Title'),
              subtitle: Text(item['description'] ?? 'No Description'),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Add Page"),
        onPressed: () async {
          await navigateToAdd();
        },
      ),
    );
  }

  void navigateToEditPage(Map<String, dynamic> item) {
    final route =
        MaterialPageRoute(builder: (context) => AddToPage(todo: item));
    Navigator.push(context, route);
  }

  Future<void> navigateToAdd() async {
    final route = MaterialPageRoute(builder: (context) => AddToPage());
    final result = await Navigator.push(context, route);
    if (result != null && result) {
      setState(() {
        isLoading = true;
      });
      fetchTodo();
    }
  }

  Future<void> deleteById(String id) async {
    // Delete the item
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    
    if (response.statusCode == 200) {
      // Remove the item from the list
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      // ShowErrorMessage('Unable to Delete');
    }
  }

  Future<void> fetchTodo() async {
    setState(() {
      isLoading = true; // Set isLoading to true before making the request
    });

    try {
      const url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final result = json['items'] as List<dynamic>;
        setState(() {
          items = List<Map<String, dynamic>>.from(result);
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    } finally {
      setState(() {
        isLoading =
            false; // Set isLoading to false after the request is complete
      });
    }
  }

  // void ShowErrorMessage(String message) {
  //   final snackBar =
  //       SnackBar(backgroundColor: Colors.red, content: Text(message));
  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // }
}
