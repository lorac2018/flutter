import 'package:flutter/material.dart';
import 'package:flutter_app/screens/product_detail_screen.dart';
import 'package:flutter_app/screens/search_screen.dart';
import 'package:flutter_app/widgets/product_item.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import '../providers/products.dart';
import 'auth_screen.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;
  List products = [];
  List filteredProducts = [];
  bool isSearching = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
          products = Provider
              .of<Products>(context)
              .items;
          filteredProducts = products;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider
        .of<Products>(context)
        .items;
    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? Text('All Products')
            : TextField(
          onChanged: (value) {
            setState(() {
              filteredProducts = products
                  .where((p) =>
                  p.title.toLowerCase().contains(value.toLowerCase()))
                  .toList();
            });
          },
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              hintText: "Search Product Here",
              hintStyle: TextStyle(color: Colors.white)),
        ),
        actions: <Widget>[
          isSearching
              ? IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              setState(() {
                this.isSearching = false;
                filteredProducts = products;
              });
            },
          )
              : IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                this.isSearching = true;
              });
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Container(
        padding: EdgeInsets.all(10),
        child: filteredProducts.length > 0
            ? ListView.builder(
            itemCount: filteredProducts.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                      arguments: filteredProducts[index].id);
                },
                child: Card(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 8),
                    child: Text(
                      filteredProducts[index].title,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              );
            })
            : Center(
          child: ProductsGrid(_showOnlyFavorites),
        ),
      ),
    );
  }
}