import 'package:flutter/material.dart';
import 'package:turathi/view/view_layer.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeManager.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ThemeManager.background,
        title: Text(
          'About Us',
          style: ThemeManager.textStyle.copyWith(
            fontSize: LayoutManager.widthNHeight0(context, 1) * 0.05,
            fontWeight: FontWeight.bold,
            fontFamily: ThemeManager.fontFamily,
            color: ThemeManager.primary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize:
              Size.fromHeight(LayoutManager.widthNHeight0(context, 1) * 0.01),
          child: Divider(
            height: LayoutManager.widthNHeight0(context, 1) * 0.01,
            color: Colors.grey[300],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
           
            Padding(
              padding: EdgeInsets.only(
                  top: LayoutManager.widthNHeight0(context, 1) * 0.1),
              child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: ThemeManager.primary,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: LayoutManager.widthNHeight0(context, 1) * 0.03,
                      ),
                      Text(
                        'Welcome to SriWay, your ultimate travel companion in Sri Lanka! '
                            'Designed especially for tourists, SriWay is a smart mobile app that connects you with everything you need '
                            'for a memorable journey through the island’s breathtaking landscapes, rich history, and vibrant culture.\n\n'
                            'Whether you\'re exploring the ancient ruins of Anuradhapura, relaxing on the golden beaches of Mirissa, '
                            'or hiking through the misty hills of Ella, SriWay helps you plan your trip with ease. '
                            'From finding trusted local guides and booking comfortable transport to discovering hidden gems and cultural experiences – '
                            'SriWay is here to simplify your adventure.\n\n'
                            'We are passionate about promoting responsible, authentic tourism while supporting local communities. '
                            'With user-friendly features, real-time updates, and handpicked recommendations, '
                            'SriWay is your reliable travel assistant throughout your Sri Lankan journey.\n\n'
                            'Travel smart. Travel local. Travel with SriWay.',
                        style: TextStyle(
                          color: ThemeManager.second,
                          fontWeight: FontWeight.bold,
                          fontFamily: ThemeManager.fontFamily,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )),
            ),
            SizedBox(
              height: LayoutManager.widthNHeight0(context, 1) * 0.1,
            ),
            SizedBox(
              height: LayoutManager.widthNHeight0(context, 1) * 0.1,
            ),
          ],
        ),
      ),
    );
  }
}
