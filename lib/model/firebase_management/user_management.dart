import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagement{
  Future<bool> storeNewMailUser(user, context) async{

    await Firestore.instance.collection('/users').add({
      'uid' : user.uid,
      'name' : user.displayName,
      'email' : user.email,
      'photoUrl' : user.photoUrl,
      'role' : 'normal',
      'accountType' : 'mail',
      'lastTime' : DateTime.now()
    }).catchError((e){
      print(e);
      return false;
    });

    return true;
  }
}