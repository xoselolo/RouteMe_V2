import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/framework.dart';

class UserManagement{
  Future<DocumentReference> storeNewMailUser(user, password, context) async{

    DocumentReference doc = await Firestore.instance.collection('/users').add({
      'uid' : user.uid,
      'name' : user.displayName,
      'email' : user.email,
      'password' : password,
      'photoUrl' : user.photoUrl,
      'role' : 'normal',
      'accountType' : 'mail',
      'lastTime' : DateTime.now()
    }).catchError((e){
      print(e);
      return null;
    });

    return doc;
  }
}