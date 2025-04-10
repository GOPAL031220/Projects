import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tabbartesting/repository.dart';
import 'Appbody.dart';
import '../modelclass.dart';
import 'package:tabbartesting/Screens/SearchScreen.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

  late TabController _tabController;
  String Category = 'Loading';
  String CurrentSortOption = 'date_asc';
  int TaskaddCounter = 0;

  Repository _repository = Repository();

  @override
  void initState() {
    super.initState();
    getAllCategory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> tabNames = [];
  getAllCategory() async {
    tabNames.clear();
    List categories = await _repository.readData('Category');
    setState(() {
      tabNames.addAll(categories.map((category) => category['name'] as String));
      _tabController = TabController(length: tabNames.length+1, vsync: this);
      Category = tabNames[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
        backgroundColor: Colors.blueAccent.shade200,

        actions: [
          IconButton(icon: Icon(Icons.search),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Searchscreen()));
          }),

          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(100, 70, 0, 0),
                items: [
                  PopupMenuItem(
                    value: 'date_asc',
                    child: Row(
                      children: [
                        Text('Date (Ascending)'),
                        if (CurrentSortOption == 'date_asc') Icon(Icons.check, color: Colors.green),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'date_desc',
                    child: Row(
                      children: [
                        Text('Date (Descending)'),
                        if (CurrentSortOption == 'date_desc') Icon(Icons.check, color: Colors.green),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'name_asc',
                    child: Row(
                      children: [
                        Text('Name (A to Z)'),
                        if (CurrentSortOption == 'name_asc') Icon(Icons.check, color: Colors.green),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'name_desc',
                    child: Row(
                      children: [
                        Text('Name (Z to A)'),
                        if (CurrentSortOption == 'name_desc') Icon(Icons.check, color: Colors.green),
                      ],
                    ),
                  ),
                ],
              ).then((value) {
               setState(() {
                 if (value != null) {
                   CurrentSortOption = value;
                 }
               });
              });
            },
          ),

          IconButton(icon: Icon(Icons.more_vert),
              onPressed: (){

          }),
        ],

        bottom: tabNames.isEmpty ? null
            : TabBar(
          tabAlignment: TabAlignment.start,
          isScrollable: true,
          controller: _tabController,
          labelColor: Colors.white,
          onTap: (index) {
            if (index == tabNames.length) {
              TextEditingController _addcategory = TextEditingController();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Add New Category"),
                    content: TextField(
                      controller: _addcategory,
                      decoration: InputDecoration(hintText: "Enter Category Name"),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                         if(_addcategory.text.isNotEmpty){
                           _repository.insertData('Category', {'name': _addcategory.text});
                           _repository.createTable('${_addcategory.text}');
                           Navigator.pop(context);
                           getAllCategory();
                         }
                        },
                        child: Text("Add"),
                      ),
                    ],
                  );
                },
              );
            } else {
              setState(() {
                Category = tabNames[index];
              });
            }
          },
          tabs: [
            ...tabNames.map((tabName) {
              return GestureDetector(
                onLongPress: () {

                }, child: Tab(text: tabName),
              );
            }),
            Tab(icon: Icon(Icons.add)),
          ],
        ),
      ),

      body: Category == 'Loading'
          ? Center(child: CircularProgressIndicator())
          :AppBody(
        categoryName: Category,
        sortingOption: CurrentSortOption,
        key: ValueKey('$Category$CurrentSortOption$TaskaddCounter'),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addtaskDialogue(context);
        },
        backgroundColor: Colors.blueAccent.shade200,
        child: Icon(Icons.add),
      ),
    );
  }

  _addtaskDialogue(BuildContext context) {
    TextEditingController _taskNameController = TextEditingController();
    TextEditingController _taskDescriptionController = TextEditingController();
    String _displayDateTime = 'Select Date and Time';
    String? _datetime;

    return showDialog(
      context: context,
      builder: (param) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Add Task'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _taskNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter Title',
                      ),
                    ),
                    TextField(
                      controller: _taskDescriptionController,
                      decoration: InputDecoration(
                        hintText: 'Enter Description',
                      ),
                      maxLines: 5,
                      minLines: 3,
                    ),
                    ListTile(
                      title: Text(_displayDateTime),
                      trailing: Icon(Icons.access_time),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(3000),
                        );

                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (pickedDate != null && pickedTime != null) {
                          DateTime combinedDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );

                          setDialogState(() {
                            _displayDateTime = DateFormat('yyyy-MM-dd HH:mm')
                                .format(combinedDateTime);
                            _datetime = combinedDateTime.toIso8601String();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    if (_taskNameController.text.isEmpty && _taskDescriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please Enter Title Or Description.'),
                        ),
                      );
                      return;
                    }
                    Taskmodel _taskmodel = Taskmodel();
                    _taskmodel.name = _taskNameController.text;
                    _taskmodel.description = _taskDescriptionController.text;
                    _taskmodel.datetime = _datetime;

                    _repository.insertData(Category, _taskmodel.TaskMap());

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Task Added Successfully')),
                    );

                    Navigator.pop(context);
                    _taskNameController.clear();
                    _taskDescriptionController.clear();
                    _datetime = null;
                    _displayDateTime = 'Select Date and Time';

                    setState(() {
                      TaskaddCounter++;
                    });
                  },
                  child: Text('Add', style: TextStyle(color: Colors.white)),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _taskNameController.clear();
                    _taskDescriptionController.clear();
                    _datetime = null;
                    _displayDateTime = 'Select Date and Time';
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.white)),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}