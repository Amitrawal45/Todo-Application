import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddToPage extends StatefulWidget {
  final Map<String, dynamic>? todo;

  const AddToPage({Key? key, this.todo}) : super(key: key);

  @override
  State<AddToPage> createState() => _AddToPageState();
}

class _AddToPageState extends State<AddToPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isEdit = false;

  @override
  void initState() {
    if (widget.todo != null) {
      isEdit = true;
      titleController.text = widget.todo!['title'] ?? '';
      descriptionController.text = widget.todo!['description'] ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(isEdit ? "Edit Todo" : "Add Todo"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: "Title"),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(hintText: "Description"),
              minLines: 5,
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  submitData();
                },
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submitData() async {
    final title = titleController.text;
    final description = descriptionController.text;

    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    final url = isEdit
        ? 'https://api.nstack.in/v1/todos/${widget.todo!['_id']}'
        : 'https://api.nstack.in/v1/todos';

    final uri = Uri.parse(url);

    final response = isEdit
        ? await http.put(
            uri,
            body: jsonEncode(body),
            headers: {'Content-Type': 'application/json'},
          )
        : await http.post(
            uri,
            body: jsonEncode(body),
            headers: {'Content-Type': 'application/json'},
          );

    if (response.statusCode == 200 || response.statusCode == 201) {
      titleController.text = '';
      descriptionController.text = '';
      ShowSuccessMessage(isEdit ? "Update Success" : "Creation Success");
    } else {
      ShowErrorMessage(isEdit ? "Update Failed" : "Creation Failed");
    }
  }

  void ShowSuccessMessage(String message) {
    final snackBar =
        SnackBar(backgroundColor: Colors.green, content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void ShowErrorMessage(String message) {
    final snackBar =
        SnackBar(backgroundColor: Colors.red, content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
