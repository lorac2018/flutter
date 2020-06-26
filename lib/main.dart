import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/providers/auth.dart';
import 'package:flutter_app/screens/auth_screen.dart';
import 'package:flutter_app/screens/notification_alert_screen.dart';
import 'package:flutter_app/screens/notification_alert_screen.dart';
import 'package:flutter_app/screens/search_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          builder: (ctx, auth, previousProducts) => Products(auth.token, auth.userId, previousProducts == null ? [] : previousProducts.items),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth,_) => MaterialApp(
            title: 'Groceries',
            theme: ThemeData(
              primarySwatch: Colors.blueGrey,
              accentColor: Colors.black,
              errorColor: Colors.red,
              fontFamily: 'Quicksand',
              textTheme: ThemeData.light().textTheme.copyWith(
                    title: TextStyle(
                        fontFamily: 'Quicksand',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    display1: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 17,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                    display2: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
            ),
            home: auth.isAuth  ? ProductsOverviewScreen() : AuthScreen(),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
              LocalNotificationScreen.routeName: (ctx) => LocalNotificationScreen(),
              SearchScreen.routeName: (ctx) => SearchScreen(),
            }),
      ),
    );

  }
}
