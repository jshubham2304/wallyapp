import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class WallpaperViewScreen extends StatefulWidget {
  final DocumentSnapshot data;
  WallpaperViewScreen({this.data});
  @override
  _WallpaperViewScreenState createState() => _WallpaperViewScreenState();
}

class _WallpaperViewScreenState extends State<WallpaperViewScreen> {
 Firestore _db =  Firestore.instance;
 FirebaseAuth auth = FirebaseAuth.instance;

 bool  _fav;
@override
  void initState() {
  checkExist(widget.data.documentID);
    print("After checkExist "+_fav.toString());
    _checkFav(widget.data.documentID);
        super.initState();
      }
    @override
      Widget build(BuildContext context) {
   
        List<dynamic> tags = widget.data["tag"].toList();
        return Scaffold(  appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade400,
        title: Text("Wallpaper Viewer"),
      ),
          body:SingleChildScrollView(child: Container(
            width: MediaQuery.of(context).size.width,
          child: SafeArea(
                  child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  child:Hero(
                    tag: widget.data["url"],
                                child: CachedNetworkImage(
                        imageUrl: widget.data["url"],
                        placeholder: (context,url)=>Image(image:AssetImage("assets/placeholder.jpg")),
                       errorWidget: (context, url, error) => Icon(Icons.error),),
                  )
                ),
                Container(
                  margin: EdgeInsets.only(top:20 ),
                  child:Wrap(
                    runSpacing: 5,
                    spacing: 5,
                    
                    children: tags.map((x){
                      return Chip(label: Text(x),backgroundColor:ColorScheme.dark().background,);
                    }).toList(),
                  )
    
                ),
                Container(
                  margin: EdgeInsets.only(top:20 ),
                  child:Wrap(
                    alignment: WrapAlignment.center,
                    runSpacing: 5,
                    spacing: 5,
                    children: <Widget>[
                      RaisedButton.icon(onPressed:lauchUrl ,label:Text("Get  Wallpaper"),icon:Icon(Icons.file_download)),
                      
                      RaisedButton.icon(onPressed: shareLinkUrl,label:Text("Share"),icon:Icon(Icons.share)),
                      if(_fav == false)...[
                        RaisedButton.icon(onPressed:(){
                          _addToFavorite();
                          setState(() {
                            _fav = true;
                          });
                        },label:Text("Favorites"),icon:Icon(Icons.favorite))
                      ],
                      if(_fav == true)...[
                        RaisedButton.icon(onPressed:(){
                        _removeToFavorite();
                       // Navigator.of(context).pop();
                         setState(() {
                           _fav= false;
                           
                         });
                      },label:Text("UnFavorites"),icon:Icon(Icons.favorite_border))
                      
                      ],
                      
                  ],
                    
                  )
    
                )
                 
              ],
            ),
          ),
          ),),
    
          
          
        );
      }
       lauchUrl() async{
        try{
          
          if(await canLaunch(widget.data["url"]))
           {  
             launch(widget.data["url"]);
        }
        }catch(e)
        {
    
        }
    
      }
      void _addToFavorite() async{
        FirebaseUser user = await auth.currentUser();
        String uid = user.uid;
        _db.collection("users").document(uid).collection("favorites").document(widget.data.documentID).setData(widget.data.data);
          //Navigator.of(context).pop();
      }
      void _removeToFavorite() async{
        FirebaseUser user = await auth.currentUser();
        String uid = user.uid;
        _db.collection("users").document(uid).collection("favorites").document(widget.data.documentID).delete();
        }
      void shareLinkUrl()async
      {
        try{
          DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://mywallyapp.page.link',
      link: Uri.parse(widget.data["url"]),
      androidParameters: AndroidParameters(
          packageName: 'com.example.wallyapp',
          minimumVersion: 10,
      ),
      iosParameters: IosParameters(
          bundleId: 'com.example.wallyapp',
          minimumVersion: '10',
          appStoreId: '123456789',
      ),
      
      socialMetaTagParameters:  SocialMetaTagParameters(
        title: 'Wally App',
        description: 'Shared link of cool wallpaper. Grap it !!',
        imageUrl: Uri.parse(widget.data["url"])
      ),
    );
    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri shortUrl = shortDynamicLink.shortUrl;
    // final Uri dynamicUrl = await parameters.buildUrl();
    // String urlImage =  dynamicUrl.toString();
    print(shortUrl.toString());
    Share.share(shortUrl.toString());
    
        }catch(e){}
      }
  checkExist(String docID) async {
    bool exists = false;
    try {
      
        FirebaseUser user = await auth.currentUser();
        String uid = user.uid;
      await Firestore.instance.document("users/$uid/favorites/$docID").get().then((doc) {
        if (doc.exists)
      {
        setState(() {
      _fav = true;   
      });
      }
        else
      {
        setState(() {
      _fav = false;   
      });
      }     });
      
     
    } catch (e) {
      return false;
    }
  }  
      void _checkFav(String document) async {
          try{
            
        FirebaseUser user = await auth.currentUser();
        String uid = user.uid;
      QuerySnapshot qs = await Firestore.instance.collection("users").document(uid).collection("favorites").getDocuments();
  qs.documents.forEach((DocumentSnapshot snap) {
           print(snap.data[0] +"== "+document+"::::::::::::::"+snap.documentID == document);
  });
          }catch(e){

          }

      }
}