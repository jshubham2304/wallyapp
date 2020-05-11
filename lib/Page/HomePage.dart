import 'package:flutter/material.dart';
import 'package:wallyapp/Page/AccountScreen.dart';
import 'package:wallyapp/Page/ExploreScreen.dart';
import 'package:wallyapp/Page/FavScreen.dart';

class HomePageScreen extends StatefulWidget {

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  var _page =[
    ExploreScreen(),
    FavScreen(),
    AccountScreen()
  ];
  int _selected = 0; 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.blueGrey.shade400,
        title: Text("Wally App"),
      ),
      body: _page[_selected],
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon: Icon(Icons.search),title: Text("Explore")),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border),title: Text("Favorites")),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline),title: Text("Account"))

      ],onTap: (index){
        setState(() {
          _selected = index;
        });

      },currentIndex: _selected,),
    );
  }
}
