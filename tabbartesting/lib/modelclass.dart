class Taskmodel {
  int? id;
  String? name;
  String? description;
  String? datetime;
  int? is_complete = 0;

  TaskMap(){
    Map mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['name'] = name;
    mapping['description'] = description;
    mapping['datetime'] = datetime;
    mapping['is_complete'] = is_complete;  // Make sure to include this field

    return mapping;
  }
}