import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier{

  final String id;
  final String title;
  final String description;
  final double price;
  final String imageURL;
  bool isFavorite;     //is not 'final' because this will be changeable after the product has been created
                       //and this allows us to track whether the user of this application has this
                       //product as a favorite product or not
                       //so we will be able to change the state of this favorite

  Product({
    @required this.id, 
    @required this.title, 
    @required this.description, 
    @required this.price, 
    @required this.imageURL, 
    this.isFavorite = false,           //false is a default value
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners(); //notifying the widgets that isFavorite has changes (inverted)

    final url = Uri.parse('https://flutter-shopping-app-ccbb3-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$token');
    try {
      final response = await http.put(url, body: json.encode(
        isFavorite,
      ));
      if(response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    }
    catch (error) {
      _setFavValue(oldStatus);
    }
  }
}