import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turathi/core/data_layer.dart';
import 'package:turathi/view/view_layer.dart';

//page to view all places based on location -selected or user location
class BodyPlaces extends StatefulWidget {
  final String tab;
  final int dis_num;
  var dataList;

  BodyPlaces(
      {Key? key,
      required this.tab,
      required this.dis_num,
      required this.dataList})
      : super(key: key);

  @override
  State<BodyPlaces> createState() => _BodyPlacesState();
}

class _BodyPlacesState extends State<BodyPlaces> {
  bool get isNearestPlaceTab => widget.tab == "Nearest Place";
  bool get isMyLocationTab => widget.tab == "My Location";
  PlaceList? placesList;
  String case2NoSelectedPlace = "You Have To Choose";
  String case22NoSelectedPlace = "The Location You Want";

  String case2NoPlaceNearestUserLoacation= "There IS No Places";
  String case22NoPlaceNearestUserLoacation=  "Nearest Your Location";

  @override
  Widget build(BuildContext context) {
    double cardWidth = 150;
    double spacingWidth = 10;
    double totalWidth = cardWidth + spacingWidth;

    int crossAxisCount =
        MediaQuery.of(context).size.width ~/ totalWidth; //number of col
    final PlaceProvider placesProvider = Provider.of<PlaceProvider>(context);

    // --- Modern Header ---
    Widget header = Stack(
      children: [
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2196F3), // TourismColors.primary
                Color(0xFF43A047).withOpacity(0.8), // TourismColors.accent
              ],
            ),
            image: DecorationImage(
              image: AssetImage('assets/images/img_png/img_1.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.18),
                BlendMode.darken,
              ),
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Places',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Find your next adventure!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Optional: Add a search/filter button
        Positioned(
          right: 24,
          top: 32,
          child: Material(
            color: Colors.white.withOpacity(0.85),
            shape: CircleBorder(),
            elevation: 2,
            child: IconButton(
              icon: Icon(Icons.filter_alt_rounded, color: Color(0xFF2196F3)),
              onPressed: () {},
              tooltip: 'Filter',
            ),
          ),
        ),
      ],
    );

    // --- Filter Chips ---
    final List<String> categories = [
      'All', 'Nature', 'Historical', 'Popular', 'Family', 'Adventure', 'Relax', 'Culture'
    ];
    int selectedCategory = 0;
    Widget filterChips = Container(
      height: 48,
      margin: EdgeInsets.only(top: 12, bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ChoiceChip(
            label: Text(categories[index]),
            selected: selectedCategory == index,
            onSelected: (_) {}, // Add filter logic if needed
            selectedColor: Color(0xFF2196F3),
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: selectedCategory == index ? Colors.white : Color(0xFF2196F3),
              fontWeight: FontWeight.bold,
            ),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          );
        },
      ),
    );

    if (isMyLocationTab) {
      widget.dataList.addAll([sharedUser.latitude, sharedUser.longitude]);
    } else {
      widget.dataList.addAll([selectedNearestLat, selectedNearestLog]);
    }

    if (widget.dataList.first == 0.0 || widget.dataList.last == 0.0) {
      return Column(
        children: [
          header,
          filterChips,
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(
                    top: LayoutManager.widthNHeight0(context, 1) * 0.25),
                child: Column(
                  children: [
                    SizedBox(height: LayoutManager.widthNHeight0(context, 1) * 0.02),
                    Text(
                      case2NoSelectedPlace,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontFamily: ThemeManager.fontFamily,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: LayoutManager.widthNHeight0(context, 1) * 0.025),
                    Text(
                      case22NoSelectedPlace,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: ThemeManager.fontFamily,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return FutureBuilder(
      future: placesProvider.getNearestPlaceList(
          widget.dataList.first, widget.dataList.last, widget.dis_num),
      builder: (context, snapshot) {
        var data = snapshot.data;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        placesList = data;
        if (placesList!.places.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              filterChips,
              Expanded(
                child: Container(
                  color: Color(0xFFF7FAFC), // TourismColors.background
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: LayoutManager.widthNHeight0(context, 1) * 0.04,
                        left: LayoutManager.widthNHeight0(context, 1) * 0.035,
                        right: LayoutManager.widthNHeight0(context, 1) * 0.035),
                    child: GridView.builder(
                      itemCount: placesList!.places.length,
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: cardWidth / (cardWidth + 65),
                        mainAxisSpacing: 16, // more space
                        crossAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        final placeModel = placesList!.places[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {}); // Ensure AdminCheck is up-to-date
                            if (AdminCheck) {
                              Navigator.of(context).pushNamed(
                                editPlacesAdminRoute,
                                arguments: placeModel,
                              );
                            } else {
                              Navigator.of(context).pushNamed(
                                placeDetailsRoute,
                                arguments: placeModel,
                              );
                            }
                          },
                          child: SizedBox(
                            width: cardWidth,
                            child: PlaceCard(
                              placeModel: placeModel,
                              onPress: () {
                                setState(() {}); // Ensure AdminCheck is up-to-date
                                if (AdminCheck) {
                                  Navigator.of(context).pushNamed(
                                    editPlacesAdminRoute,
                                    arguments: placeModel,
                                  );
                                } else {
                                  Navigator.of(context).pushNamed(
                                    placeDetailsRoute,
                                    arguments: placeModel,
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Center(
          child: Padding(
            padding: EdgeInsets.only(
                top: LayoutManager.widthNHeight0(context, 1) * 0.45),
            child: Column(
              children: [
                SizedBox(
                    height: LayoutManager.widthNHeight0(context, 1) * 0.02),
                Text(
                 case2NoPlaceNearestUserLoacation,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ThemeManager.primary,
                    fontFamily:ThemeManager.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                SizedBox(
                    height: LayoutManager.widthNHeight0(context, 1) * 0.025),
                 Text(
                 case22NoPlaceNearestUserLoacation,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: ThemeManager.fontFamily,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
