import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallyapp/Page/wallpaperViewScreen.dart';
import 'package:wallyapp/config.dart';
class FavScreen extends StatefulWidget {

  @override
  _FavScreenState createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen> {
final Firestore _db = Firestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
FirebaseUser user;
@override
  void initState() {
    _getUser();
    super.initState();
  }
  void _getUser() async
  {
    FirebaseUser users = await auth.currentUser();
    setState(() {
      user =users;
    });
       
  }
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
               child: Text("Favorites",style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold ,color: Colors.grey,),),
             ),
              if(user!= null)...[
  StreamBuilder(
               stream: _db.collection("users").document(user.uid).collection("favorites").orderBy("date",descending: true).snapshots(),
               builder:(ctx,AsyncSnapshot<QuerySnapshot> snapshot){
               if(snapshot.hasData)
               {
        return StaggeredGridView.countBuilder(crossAxisCount: 2,shrinkWrap: true,physics: NeverScrollableScrollPhysics(), staggeredTileBuilder: (int index)=>StaggeredTile.fit(1),
            itemCount: snapshot.data.documents.length,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            padding: EdgeInsets.symmetric(horizontal:15, ),
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
               return SpinKitChasingDots(color: primaryColor,size: 50,);
               
             } ,)
            

              ],
                    
                        

         
             
             ],
         ),
      ),
    );
  }
}