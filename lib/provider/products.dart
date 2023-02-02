//(PRODUCTS_PROVIDER)

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;   //to avoid name clashing

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {

  List<Product> _items = [ 
    //  Product(
    //   id: 'p1',
    //   title: 'Samsung S22 Ultra',
    //   description: 'Samsung S22 Ultra',
    //   price: 29.99,
    //   imageURL: 'https://www.linkpicture.com/q/s22-ultra.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Pixel 6 Pro',
    //   description: 'Google Pixel 6 Pro',
    //   price: 59.99,
    //   imageURL: 'https://www.linkpicture.com/q/pixel-6-pr0.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'iPhone 14 Pro',
    //   description: 'Apple iPhone 14 Pro Max',
    //   price: 19.99,
    //   imageURL: 'https://www.linkpicture.com/q/download_8.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'Nothing Phone 1',
    //   description: 'Nothing Phone 1',
    //   price: 49.99,
    //   imageURL: 'https://www.linkpicture.com/q/images_198.jpg',
    // ),
  ];

  // var _showFavoritesOnly = false;

  final String authToken;
  final String userId;
  Products(this.authToken, this.userId, this._items);

  List<Product> get items {

    // if(_showFavoritesOnly)
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();

    return [..._items];
  }

  List<Product> get favoriteItems{
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id){

    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly(){
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll(){
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  
  Future<void> fetchAndSetProduct([bool filterByUser = false]) async {

    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse('https://flutter-shopping-app-ccbb3-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken&$filterString');
    
    try{
      final response = await http.get(url);
      //print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if(extractedData == null) {
        return;
      }

      url = Uri.parse('https://flutter-shopping-app-ccbb3-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'], 
          description: prodData['description'], 
          price: prodData['price'], 
          isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false, 
          imageURL: prodData['imageUrl'], 
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    }
    catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {

    //const url = 'https://flutter-shopping-app-ccbb3-default-rtdb.asia-southeast1.firebasedatabase.app/products.json';
    //final url = Uri.https('https://flutter-shopping-app-ccbb3-default-rtdb.asia-southeast1.firebasedatabase.app', '/products.json');
    //JSON = javascript object notation
    final url = Uri.parse('https://flutter-shopping-app-ccbb3-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken');

    try {

      final response = await http.post(url, body: json.encode({    //the body accepts data in JSON format
        'title' : product.title,
        'description' : product.description,
        'imageUrl' : product.imageURL,
        'price' : product.price,
        'creatorId' : userId,
      },),);

      //prints the response given by the firsbase database 
      //i.e., the crptic uniques associated with the added product
      print(json.decode(response.body));

      final newProduct = Product(
        title: product.title, 
        description: product.description, 
        imageURL: product.imageURL, 
        price: product.price,
        id: json.decode(response.body)['name'],
      );

      // _items.insert(0, addProduct);   // at the start of the list
      _items.add(newProduct);
      notifyListeners();
    }

    catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse('https://flutter-shopping-app-ccbb3-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken');
      await http.patch(url, body: json.encode({
        'title' : newProduct.title,
        'description' : newProduct.description, 
        'imageUrl' : newProduct.imageURL, 
        'price' : newProduct.price,
      })); // patch
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
    else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse('https://flutter-shopping-app-ccbb3-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var exisitngProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);   //removes from list but not from memory
    //_items.removeWhere((prod) => prod.id == id);
    notifyListeners();

    final response = await http.delete(url);

    if(response.statusCode >= 400) {
      _items.insert(existingProductIndex, exisitngProduct);
      notifyListeners();
      throw HttpException('Could Not Delete Product');
    }
    exisitngProduct = null; 
  }
}