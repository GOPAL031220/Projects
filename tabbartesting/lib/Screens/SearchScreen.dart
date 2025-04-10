import 'package:flutter/material.dart';
import 'package:tabbartesting/repository.dart';

class Searchscreen extends StatefulWidget {
  const Searchscreen({super.key});

  @override
  State<Searchscreen> createState() => _SearchscreenState();
}

class _SearchscreenState extends State<Searchscreen> {

  TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  List Filteredtask = [];

  @override
  void initState() {
    super.initState();
    getAllCategory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<String> tabNames = [];
  List Alltasks = [];
  getAllCategory() async {
    Repository _repository = Repository();
    List categories = await _repository.readData('Category');
    setState(() {
      tabNames.addAll(categories.map((category) => category['name'] as String));
    });

    for (var category in tabNames) {
      List tasks = await _repository.readData(category);

      for (var task in tasks) {
        var taskWithCategory = Map.from(task);
        taskWithCategory['Category'] = category;

        setState(() {
          Alltasks.add(taskWithCategory);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:TextField(
          controller: _searchController,
          focusNode: _focusNode,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          onChanged: (query) {
            if (query.isEmpty) {
              setState(() {
                Filteredtask = [];
              });
            } else {
              final filteredtasks = Alltasks.where((task) {
                final searchLower = query.toLowerCase();
                return task['name']!.toLowerCase().contains(searchLower) ||
                    task['description']!.toLowerCase().contains(searchLower);
              }).toList();

              setState(() {
                Filteredtask = filteredtasks;
              });
            }
          },
        ),
        backgroundColor: Colors.blueAccent.shade200,
      ),

      body:ListView.builder(
        itemCount: Filteredtask.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                Filteredtask[index]['name'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  Filteredtask[index]['description'],
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.blueAccent),
              onTap: () {
              },
            ),
          );
        },
      ),
    );
  }
}