import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserManagement{
  Future<bool> storeNewMailUser(user, context) async{

    await Firestore.instance.collection('/users').add({
      'uid' : user.uid,
      'name' : user.displayName,
      'email' : user.email,
      'photoUrl' : user.photoUrl,
      'role' : 'normal',
      'accountType' : 'mail'
    }).catchError((e){
      print(e);
      return false;
    });

    return true;
  }
}