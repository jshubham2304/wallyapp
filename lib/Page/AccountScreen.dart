import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallyapp/Page/add_wallpaper_screen.dart';
import 'package:wallyapp/Page/wallpaperViewScreen.dart';

import '../config.dart';
class AccountScreen extends StatefulWidget {
  AccountScreen({Key key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  
 FirebaseAuth auth = FirebaseAuth.instance;
 FirebaseUser user ;
 Firestore  _db = Firestore.instance;
  @override
  void initState() {
    fetchData();
    super.initState();
  }
  void fetchData() async{
FirebaseUser u  = await auth.currentUser();
setState(() {
  user=u;

});
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
         child: user!= null ?Column(
           children: <Widget>[
             SizedBox(
               height: 20,
             ),
             ClipRRect(
               borderRadius: BorderRadius.circular(100),
                            child: FadeInImage(
                 width: 150,
                 height:150,
                 fit: BoxFit.cover,
                 image: NetworkImage(user.photoUrl),
               placeholder: AssetImage("assets/placeholder.jpg"),),
             ),
             SizedBox(
               height: 20,
             ),
             Text("${user.displayName}"),
             SizedBox(
               height: 20,
             ),
             RaisedButton(
                color: Colors.blue,
               onPressed: (){
                 auth.signOut();
               }, child: Text("Log out",style: TextStyle(color:Colors.white),)),
                SizedBox(
               height: 10,
             ),
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: <Widget>[
                 Text("My Wallpaper",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold ,color: Colors.grey),),
                 IconButton(onPressed:(){
                    Navigator.of(context).push(MaterialPageRoute
                    (builder: (context)=> Add_Wallpaper_Screen(),fullscreenDialog: true)
                    );
                 },icon: Icon(Icons.add,),),
               
               ],),

             ),
     
             StreamBuilder(
               stream: _db.collection("wallpapers").orderBy("date",descending: true).where("uploaded_by",isEqualTo: user.uid).snapshots(),

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
                              child: Stack(
                                children: <Widget>[
                                  Hero(
                  
                                    child: CachedNetworkImage(
                    imageUrl: snapshot.data.documents[index].data["url"],
                    placeholder: (context,url)=>Image(image:AssetImage("assets/placeholder.jpg")),
                   errorWidget: (context, url, error) => Icon(Icons.error),), tag: snapshot.data.documents[index].data["url"],
                ),
                IconButton(onPressed: (){
                  showDialog(context: context,builder: (ctx){
                  return AlertDialog(
                    shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Text("Confirmation"),
                    content: Text("Are you sure to delete the wallpaper"),
                    actions: <Widget>[
                      RaisedButton(onPressed: (){
                        Navigator.of(ctx).pop();
                      },child: Text("Cancel"), ),
                      
                      RaisedButton(onPressed: (){
                        
                  _db.collection("wallpapers").document(snapshot.data.documents[index].documentID).delete();
                                          Navigator.of(ctx).pop();
                      },child: Text("Okay"), ),
                    ],
                  );
                  });
                },icon:Icon(Icons.delete,color: Colors.redAccent,))
                                ],
                              ),
              );

            },);

               }
               return SpinKitChasingDots(color: primaryColor,size: 50,);
               
             } ,)
            ],
         ):LinearProgressIndicator(),
      ),
    );
  }
}