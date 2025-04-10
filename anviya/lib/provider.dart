import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class PostProvider extends ChangeNotifier {
  List<dynamic> _posts = [];
  bool _isLoading = false;

  List<dynamic> get posts => _posts;
  bool get isLoading => _isLoading;


  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();

    final response = await http.get(Uri.parse('https://anviya.in/api/users'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      _posts = json['data'];
    } else {
      _posts = [];
    }

    _isLoading = false;
    notifyListeners();


  }



}
