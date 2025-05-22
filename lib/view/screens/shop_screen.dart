import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  final List<String> categories = [
    'All', 'Supplements', 'Gear', 'Apparel', 'Accessories', 'Drinks'
  ];

  final List<Map<String, String>> products = [
    {
      'name': 'Whey Protein',
      'image': 'assets/images/img_png/shop_protein.png',
      'price': '29.99',
    },
    {
      'name': 'Fitness Gloves',
      'image': 'assets/images/img_png/shop_protein.png',
      'price': '29.99',
    },
    {
      'name': 'Shaker Bottle',
      'image': 'assets/images/img_png/shop_protein.png',
      'price': '29.99',
    },
    {
      'name': 'Gym T-shirt',
      'image': 'assets/images/img_png/shop_protein.png',
      'price': '29.99',
    },
    {
      'name': 'Energy Drink',
      'image': 'assets/images/img_png/shop_protein.png',
      'price': '29.99',
    },
    {
      'name': 'Resistance Band',
      'image': 'assets/images/img_png/shop_protein.png',
      'price': '29.99',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Shop',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFB71C1C),
        child: Icon(Icons.shopping_bag, color: Colors.white),
        onPressed: () {},
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured Carousel
          SizedBox(
            height: 180,
            child: PageView(
              children: [
                _featuredCard('assets/images/img_png/shop_banner1.png', '20% OFF on all Supplements!'),
                _featuredCard('assets/images/img_png/shop_banner2.png', 'New Arrivals: Gym Gear'),
                _featuredCard('assets/images/img_png/shop_banner3.png', 'Stay Hydrated: Bottles & Drinks'),
              ],
            ),
          ),
          SizedBox(height: 18),
          // Categories
          Container(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => SizedBox(width: 10),
              itemBuilder: (context, i) {
                return Chip(
                  label: Text(categories[i], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: i == 0 ? Color(0xFFB71C1C) : Color(0xFF181818),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                );
              },
            ),
          ),
          SizedBox(height: 18),
          // Product Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: products.length,
              itemBuilder: (context, i) {
                return _productCard(products[i]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuredCard(String image, String text) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                shadows: [Shadow(blurRadius: 8, color: Colors.black)],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _productCard(Map<String, String> product) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF181818),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              product['image']!,
              height: 90,
              width: 90,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 12),
          Text(
            product['name']!,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            '20% OFF',
            style: TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.bold, fontSize: 13),
          ),
          SizedBox(height: 6),
          Text(
            '20% OFF',
            style: TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.bold, fontSize: 13),
          ),
          SizedBox(height: 6),
          Text(
            '20% OFF',
            style: TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.bold, fontSize: 13),
          ),
          SizedBox(height: 6),
          Text(
            product['price']!,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: 110,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFB71C1C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text('Buy Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
} 