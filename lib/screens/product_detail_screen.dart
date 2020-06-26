import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);
    return Scaffold(
      appBar: AppBar(
        title:
            Text(loadedProduct.title, style: Theme.of(context).textTheme.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Divider(),
            Container(
              height: 300,
              width: double.infinity,
              child: Image.network(
                loadedProduct.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            Text(
              'Price: ' + '\$${loadedProduct.price}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.display1,
            ),
            Divider(),
            Text(
              'Quantity: ' + '${loadedProduct.quantity}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.display1,
            ),
            Divider(),
            Text(
              'Brand: ' + loadedProduct.brand,
              textAlign: TextAlign.center,
              softWrap: true,
              style: Theme.of(context).textTheme.display1,
            ),
            Divider(),
            Text(
              'Validation Date: ' + '${loadedProduct.date}',
              textAlign: TextAlign.center,
              softWrap: true,
              style: Theme.of(context).textTheme.display1,
            ),
            Divider(),
            Text(
              'Days left to consume: ' + loadedProduct.numberofdays,
              textAlign: TextAlign.center,
              softWrap: true,
              style: Theme.of(context).textTheme.display1,
            ),
            Divider(),
            Text(
              'Barcode: ' + loadedProduct.barcode,
              textAlign: TextAlign.center,
              softWrap: true,
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
    );
  }
}
