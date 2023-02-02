import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/cart.dart';
import '../provider/product.dart';
import '../provider/auth.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {

  // final String id;
  // final String title;
  // final String imageURL;

  // ProductItem(this.id, this.title, this.imageURL);

  @override
  Widget build(BuildContext context) {
    
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName, arguments: product.id);
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/loading.jpg'), 
              image: NetworkImage(product.imageURL),
              fit: BoxFit.cover,
            ),
          )
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (ctx, product, child) => IconButton(
              icon: Icon(product.isFavorite ? Icons.favorite : Icons.favorite_border), 
              color: Theme.of(context).accentColor, 
              onPressed: () {
                product.toggleFavoriteStatus(authData.token, authData.userId);
              },
            ),
            child: Text('Never Changes!!!'),
          ),
          title: Text(product.title, textAlign: TextAlign.center,),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart), 
            color: Theme.of(context).accentColor, 
            onPressed: () {
              cart.addItem(product.id, product.price,product.title);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('Item Added To Cart'),
                duration: Duration(seconds: 2),
                action: SnackBarAction(label: 'UNDO', onPressed: () {
                  cart.removeSingleItem(product.id);
                },),
              ),);
            },
          ),
        ),
      ),
    );
  }
}