import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';
import './provider/products.dart';
import './provider/cart.dart'; 
import './provider/orders.dart';
import './provider/auth.dart';
import './helpers/custom_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),

        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, auth, previousProducts) =>        //builder in flutter provider v(<4.0.0) 
          Products(
            auth.token, 
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),  
        
        //ChangeNotifierProvider.value(value: Cart()),
        ChangeNotifierProvider(create: (ctx) => Cart(),),
        
        //ChangeNotifierProvider.value(value: Orders()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previousOrders) => 
          Orders(
            auth.token,
            previousOrders == null ? [] : previousOrders.orders,
            auth.userId,
          ),
        ),
      ],
      child: Consumer<Auth>(builder: (ctx, auth, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyShop',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          accentColor: Color.fromARGB(255, 255, 132, 0),
          fontFamily: 'Lato',
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android : CustomPageTransitionBuilder(),
          })
        ),
        home: auth.isAuth ? ProductsOverviewScreen() : FutureBuilder(
          future: auth.tryAutoLogin(),
          builder: (ctx, authResultSnapshot) =>
          authResultSnapshot.connectionState == ConnectionState.waiting ? SplashScreen() : AuthScreen(),
        ),
        routes: {
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          CartScreen.routeName: (ctx) => CartScreen(),
          OrdersScreen.routeName: (ctx) => OrdersScreen(),
          UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
          EditProductScreen.routeName: (ctx) => EditProductScreen(),
        },
      ),),
    );
  }
}