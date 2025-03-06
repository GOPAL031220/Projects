import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'modelclass.dart';
import 'repository.dart';

class Taskhome extends StatefulWidget {
  const Taskhome({super.key});
  State<Taskhome> createState() => _TaskhomeState();
}

class _TaskhomeState extends State<Taskhome> {
  TextEditingController _taskNameController = TextEditingController();
  TextEditingController _taskDescriptionController = TextEditingController();
  String? _datetime;
  String _displayDateTime = 'Select Date and Time';
  bool _isSnackbarShowing = false;

  String _currentSortOption = 'date_asc';

  Taskmodel _taskmodel = Taskmodel();
  Repository _repository = Repository();

  _showFormDialogue(BuildContext context, {Taskmodel? task}) {
    if (task != null) {
      _taskNameController.text = task.name ?? _taskNameController.text;
      _taskDescriptionController.text = task.description ?? _taskDescriptionController.text;

      if (task.datetime != null) {
        _displayDateTime = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(task.datetime!));
        _datetime = task.datetime;
      }
    }
    return showDialog(
      context: context,
      builder: (param) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              actions: [
                OutlinedButton(
                  onPressed: () {
                    if (_taskNameController.text.isEmpty && _taskDescriptionController.text.isEmpty) {
                      if (!_isSnackbarShowing) {
                        _isSnackbarShowing = true;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please Enter Title Or Description.'),
                          ),
                        );
                        Future.delayed(Duration(seconds: 4), () {
                          _isSnackbarShowing = false;
                        });
                      }
                      return;
                    }
                    Navigator.pop(context);
                    _taskmodel.name = _taskNameController.text;
                    _taskmodel.description = _taskDescriptionController.text;
                    _taskmodel.datetime = _datetime;

                    if (task == null) {
                      _repository.insertData('Tasks', _taskmodel.TaskMap());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Task Added Successfully')),
                      );
                    } else {
                      _taskmodel.id  = task.id;
                      _taskmodel.is_complete = task.is_complete;
                      _repository.updateData('Tasks',_taskmodel.TaskMap());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Task Updated Successfully')),
                      );
                    }

                    getAllTasks();
                    _taskNameController.clear();
                    _taskDescriptionController.clear();
                    _datetime = null;
                    _displayDateTime = 'Select Date and Time';

                  },
                  child: Text(task == null ? 'Add' : 'Update', style: TextStyle(color: Colors.white)),                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green)),
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
                      backgroundColor: MaterialStateProperty.all(Colors.red)),
                ),
              ],
              title: Text('Task Details'),
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

                        DateTime combinedDateTime = DateTime(
                          pickedDate!.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime!.hour,
                          pickedTime.minute,
                        );

                        setDialogState(() {
                          _displayDateTime = DateFormat('yyyy-MM-dd HH:mm').format(combinedDateTime);
                          _datetime = combinedDateTime.toIso8601String();
                        });

                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  void initState(){
    super.initState();
    getAllTasks();
  }
  List<Taskmodel> _taskList = [];
  getAllTasks() async {
    _taskList.clear();
    List categories = await _repository.readData('Tasks');
    categories.forEach((cat){
      setState(() {
        var c = Taskmodel();
        c.id = cat['id'];
        c.name = cat['name'];
        c.description = cat['description'];
        c.datetime = cat['datetime'];
        c.is_complete = cat['is_complete'];
        _taskList.add(c);

        _sortTasks(criteria: _currentSortOption);
      });
    });
  }

  void _sortTasks({String? criteria}) {
    setState(() {

      switch (criteria) {
        case 'name_asc':
          _taskList.sort((a, b) => a.name!.compareTo(b.name!));
          break;
        case 'name_desc':
          _taskList.sort((a, b) => b.name!.compareTo(a.name!));
          break;
        case 'date_asc':
          _taskList.sort((a, b) {
            if (a.datetime == null && b.datetime == null) return 0;
            if (a.datetime == null) return 1;
            if (b.datetime == null) return -1;
            DateTime dateA = DateTime.parse(a.datetime!);
            DateTime dateB = DateTime.parse(b.datetime!);
            return dateA.compareTo(dateB);
          });
          break;
        case 'date_desc':
          _taskList.sort((a, b) {
            if (a.datetime == null && b.datetime == null) return 0;
            if (a.datetime == null) return 1; 
            if (b.datetime == null) return -1;
            DateTime dateA = DateTime.parse(a.datetime!);
            DateTime dateB = DateTime.parse(b.datetime!);
            return dateB.compareTo(dateA);
          });
          break;
      }
      _taskList.sort((a, b) {
        return (a.is_complete == b.is_complete) ? 0 : (a.is_complete == 1 ? 1 : -1);
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
        backgroundColor: Colors.blueAccent.shade200,
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(100, 50, 0, 0),
                items: [
                  PopupMenuItem(
                    value: 'date_asc',
                    child: Row(
                      children: [
                        Text('Date (Ascending)'),
                        if (_currentSortOption == 'date_asc') Icon(Icons.check, color: Colors.green),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'date_desc',
                    child: Row(
                      children: [
                        Text('Date (Descending)'),
                        if (_currentSortOption == 'date_desc') Icon(Icons.check, color: Colors.green),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'name_asc',
                    child: Row(
                      children: [
                        Text('Name (A to Z)'),
                        if (_currentSortOption == 'name_asc') Icon(Icons.check, color: Colors.green),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'name_desc',
                    child: Row(
                      children: [
                        Text('Name (Z to A)'),
                        if (_currentSortOption == 'name_desc') Icon(Icons.check, color: Colors.green),
                      ],
                    ),
                  ),
                ],
              ).then((value) {
                if (value != null) {
                  _currentSortOption = value;
                  _sortTasks(criteria: _currentSortOption);
                }
              });
            },
          ),
        ],
      ),
      body:_taskList.isEmpty ? Center(child: Text('No Tasks Available'),)
          : ListView.builder(itemBuilder: (context, index) {

        Color tileColor;
        if (_taskList[index].is_complete == 1) {
          tileColor = Colors.white;
        } else {
          if (_taskList[index].datetime != null) {
            DateTime taskDateTime = DateTime.parse(_taskList[index].datetime!);
            Duration difference = taskDateTime.difference(DateTime.now());

            if (difference.isNegative) {
              tileColor = Colors.red.shade600;
            } else if (difference.inHours <= 24) {
              tileColor = Colors.red.shade400;
            } else if (difference.inHours <= 72) {
              tileColor = Colors.yellow.shade600;
            } else {
              tileColor = Colors.green.shade500;
            }
          } else {
            tileColor = Colors.grey.shade500;
          }
        }
        return Padding(
          padding: EdgeInsets.only(top: 11.0,left: 15.0,right: 15.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Material(
              child: Opacity(
                opacity: _taskList[index].is_complete == 1 ? 0.3 : 1.0,
                child: ListTile(
                  tileColor: tileColor,
                  leading: Checkbox(
                    value: _taskList[index].is_complete == 1,
                    onChanged: (bool? value) {
                      setState(() {
                        _taskList[index].is_complete = value! ? 1 : 0;

                        _repository.updateData('Tasks', _taskList[index].TaskMap());
                        getAllTasks();
                      });
                    },
                  ),
                  title: Text(_taskList[index].name.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_taskList[index].description.toString(),
                        style: TextStyle(fontSize: 18),),
                    ],
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showFormDialogue(context, task: _taskList[index]);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Delete Task'),
                                content: Text('You Want To Delete This Task?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      _repository.deleteData('Tasks', _taskList[index].id);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Task Deleted Successfully')),
                                      );
                                      getAllTasks();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Delete',style: TextStyle(color: Colors.red),),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: Text('Cancel'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
        itemCount: _taskList.length,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFormDialogue(context);
        },
        backgroundColor: Colors.blueAccent.shade200,
        child: Icon(Icons.add),
      ),
    );
  }
}



