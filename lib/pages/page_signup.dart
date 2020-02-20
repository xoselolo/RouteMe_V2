import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_route_me/model/firebase_management/user_management.dart';
import 'package:flutter_route_me/pages/page_main.dart';
import 'package:flutter_route_me/widgets/widget_routeme_appbar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}


class _SignUpPageState extends State<SignUpPage> {
  String _email, _password, _name, _repeatPassword;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool repeatPasswordNotVisible, passwordNotVisible;

  @override
  void initState() {
    repeatPasswordNotVisible = true;
    passwordNotVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: RouteMeAppBar(
        pageIndex: -1
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const FractionalOffset(0.5, 0.0),
            end: const FractionalOffset(0.0, 0.5), //
            stops: [0.5, 1.0], // 10% of the width, so there are ten blinds.
            colors: [Colors.redAccent[200], Colors.red[300]],
            //colors: [Colors.red[300], Colors.orange[200]],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: TextFormField(
                  validator: (input){
                    if(input.isEmpty){
                      return 'Please type a name';
                    }
                  },
                  onChanged: (input){
                    _name = input;
                  },
                  onSaved: (input){
                    _name = input;
                  },
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(
                        color: Colors.white
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        )
                    ),
                    enabledBorder:  UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        )
                    ),
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        )
                    ),
                  ),
                  cursorColor: Colors.white,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: TextFormField(
                  validator: (input){
                    if(input.isEmpty){
                      return 'Please type an email';
                    }
                  },
                  onChanged: (input){
                    _email = input;
                  },
                  onSaved: (input){
                    _email = input;
                  },
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                        color: Colors.white
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        )
                    ),
                    enabledBorder:  UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        )
                    ),
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        )
                    ),
                  ),
                  cursorColor: Colors.white,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: TextFormField(
                  validator: (input){
                    if(input.isEmpty){
                      return 'Please type a password';
                    }
                  },
                  onChanged: (input){
                    _password = input;
                  },
                  onSaved: (input){
                    _password = input;
                  },
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordNotVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: (){
                        setState(() {
                          passwordNotVisible = !passwordNotVisible;
                        });
                      },
                    ),
                    labelText: 'Password',
                    labelStyle: TextStyle(
                        color: Colors.white
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        )
                    ),
                    enabledBorder:  UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        )
                    ),
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        )
                    ),
                  ),
                  cursorColor: Colors.white,
                  obscureText: passwordNotVisible,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: TextFormField(
                  validator: (input){
                    if(input.isEmpty){
                      return 'Please type the password again';
                    }
                  },
                  onChanged: (input){
                    _repeatPassword = input;
                  },
                  onSaved: (input){
                    _repeatPassword = input;
                  },
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  obscureText: repeatPasswordNotVisible,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        repeatPasswordNotVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: (){
                        setState(() {
                          repeatPasswordNotVisible = !repeatPasswordNotVisible;
                        });
                      },
                    ),
                    labelText: 'Repeat password',
                    labelStyle: TextStyle(
                        color: Colors.white
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        )
                    ),
                    enabledBorder:  UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        )
                    ),
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        )
                    ),
                  ),
                  cursorColor: Colors.white,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 2
                ),
                child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    elevation: 3,
                    color: Colors.white,
                    onPressed: signUp,
                    child: Text("Sign Up")
                ),
              )
            ],
          ),
        ),
      )
    );
  }


  Future<void> signUp() async{
    final formState = _formKey.currentState;
    if(_password == _repeatPassword){
      if(formState.validate()){
        formState.save();
        try{
          AuthResult authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password);

          UserUpdateInfo newInfoUpdate = UserUpdateInfo();
          newInfoUpdate.photoUrl = null;
          newInfoUpdate.displayName = _name;

          await authResult.user.updateProfile(newInfoUpdate);
          FirebaseUser user = await FirebaseAuth.instance.currentUser();

          DocumentReference doc = await UserManagement().storeNewMailUser(user, _password, context);

          if (doc != null){

            // Create storage
            final storage = new FlutterSecureStorage();

            // Write value
            await storage.write(
                key: 'routeMeJWT',
                value: doc.documentID,
            );

            authResult.user.sendEmailVerification();

            Fluttertoast.showToast(msg: "Please verify your email");

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage()));
          }else{
            await authResult.user.delete();
            Fluttertoast.showToast(msg: "Error on create new user");
          }

        }catch(e){
          Fluttertoast.showToast(
            msg: e.message,
          );
          print("Firebase auth error!");
          print(e.message);
        }
      }
    }
  }
}
