import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  final String token;
  final String userId;
  var _showFavoritesOnly;

  Products(this.token, this.userId, this._items);

List<Product> get items {
    // if (_showFavoritesOnly) {
    //  return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  void showFavoritesOnly() {
    _showFavoritesOnly = true;
    notifyListeners();
  }

  void showAll() {
    _showFavoritesOnly = false;
    notifyListeners();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Product findByName(String name) {
    return _items.firstWhere((prod) => prod.title == name);
  }

  Future<void> fetchAndSetProducts() async {
    var url =
        'https://flutter-update-4378b.firebaseio.com/product.json?auth=$token&orderBy="userId"&equalTo="$userId"';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      print(extractedData);
      if (extractedData == null) {
        return;
      }
      url =
          'https://flutter-update-4378b.firebaseio.com/userFavorites/$userId.json?auth=$token';
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          //id: prodData['prodId'].toString(),
          title: prodData['title'],
          brand: prodData['brand'],
          price: prodData['price'],
          quantity: prodData['quantity'],
          date: prodData['date'],
          numberofdays: prodData['numberofdays'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
          barcode: prodData['barcode'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
  Future<void> fetchAndSetProductsGoogleSign() async {
    var url =
        'https://flutter-update-4378b.firebaseio.com/product.json?auth=$token&orderBy="userId"&equalTo="$userId"';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      print(extractedData);
      if (extractedData == null) {
        return;
      }
      url =
      'https://flutter-update-4378b.firebaseio.com/userFavorites/$userId.json?auth=$token';
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: [prodData.indexOf(prodId)].toString(),
          //id: prodData['id'].toString(),
          //id: prodData['prodId'].toString(),
          title: prodData['title'],
          brand: prodData['brand'],
          price: prodData['price'],
          quantity: prodData['quantity'],
          date: prodData['date'],
          numberofdays: prodData['numberofdays'],
          isFavorite:
          favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
          barcode: prodData['barcode'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://flutter-update-4378b.firebaseio.com/product.json?auth=$token';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'brand': product.brand,
          'quantity': product.quantity,
          'date': product.date,
          'numberofdays': product.numberofdays,
          'imageUrl': product.imageUrl,
          'barcode': product.barcode,
          'price': product.price,
          'userId': userId
        }),
      );
      final newProduct = Product(
        title: product.title,
        brand: product.brand,
        price: product.price,
        quantity: product.quantity,
        date: product.date,
        numberofdays: product.numberofdays,
        imageUrl: product.imageUrl,
        barcode: product.barcode,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-update-4378b.firebaseio.com/product/$id.json?auth=$token';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'brand': newProduct.brand,
            'imageUrl': newProduct.imageUrl,
            'barcode': newProduct.barcode,
            'price': newProduct.price,
            'quantity': newProduct.quantity,
            'date': newProduct.date,
            'numberofdays': newProduct.numberofdays,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-update-4378b.firebaseio.com/product/$id.json?auth=$token';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
