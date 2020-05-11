const functions = require('firebase-functions');

const admin =require('firebase-admin');
admin.initializeApp();
const fsm = admin.messaging();
exports.sendNewWallpaper = functions.firestore
.document("wallpapers/{wallpaperId}").onCreate(snapshot=>{
    const data =  snapshot.data();
    var payload ={
        notification:{
            title:"WallyApp",
            body:"New Wallpapaer is here.",
            icon:"https://firebasestorage.googleapis.com/v0/b/wallyapp-2d2d3.appspot.com/o/logo_circle.png?alt=media&token=75b31d13-af50-4666-9af0-3da6ee7fe5b8",
            image:data.url
        }
        
    };
    const topic ="promotions";
   return  fsm.sendToTopic(topic,payload);
})
