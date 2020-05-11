import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallyapp/Page/wallpaperViewScreen.dart';
import 'package:wallyapp/config.dart';

class ExploreScreen extends StatefulWidget {

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final Firestore _db = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
                      child: Container(
         child: Column(
             children: <Widget>[
             SizedBox(width: 10,),
             Container(
               alignment: Alignment.topLeft,
               margin: EdgeInsets.only(top: 5,bottom: 20,left: 20),
               child: Text("Explore",style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold ,color: Colors.grey),),
             ),

             StreamBuilder(
               stream: _db.collection("wallpapers").orderBy("date",descending: true).snapshots(),

             builder:(ctx,AsyncSnapshot<QuerySnapshot> snapshot){
               if(snapshot.hasData)
               {
        return StaggeredGridView.countBuilder(crossAxisCount: 2,shrinkWrap: true,physics: NeverScrollableScrollPhysics(), staggeredTileBuilder: (int index)=>StaggeredTile.fit(1),
            itemCount: snapshot.data.documents.length,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            padding: EdgeInsets.symmetric(horizontal:10, ),
            itemBuilder: (ctx,index){
              return InkWell(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => WallpaperViewScreen(data:snapshot.data.documents[index])
                  ));
                },
                child: Hero(child: CachedNetworkImage(
                    imageUrl: snapshot.data.documents[index].data["url"],
                    placeholder: (context,url)=>Image(image:AssetImage("assets/placeholder.jpg")),
                   errorWidget: (context, url, error) => Icon(Icons.error),),
                    tag: snapshot.data.documents[index].data["url"],
                ),
              );

            },);

               }
               return SpinKitChasingDots(color: primaryColor,size: 60,);
               
             } ,),
              SizedBox(height: 50,)
             ],
         ),
      ),
    );
  }
}