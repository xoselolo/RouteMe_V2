import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_route_me/pages/page_filters.dart';
import 'package:flutter_route_me/pages/page_forgotpassword.dart';
import 'package:flutter_route_me/pages/page_main.dart';
import 'package:flutter_route_me/pages/page_signup.dart';
import 'package:flutter_route_me/widgets/widget_routeme_appbar.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}


class _WelcomePageState extends State<WelcomePage> {
  String _email, _password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool passwordNotVisible;

  @override
  void initState() {
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
            stops: [0.5, 1.0],// 10% of the width, so there are ten blinds.
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
                      return 'Please type an email';
                    }
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
              SizedBox(
                height: 0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: TextFormField(
                  validator: (input){
                    if(input.length < 6){
                      return 'Your password needs to be at least 6 characters';
                    }
                  },
                  onSaved: (input){
                    _password = input;
                  },
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
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
                    )
                  ),
                  cursorColor: Colors.white,
                  obscureText: passwordNotVisible,
                ),
              ),
              SizedBox(
                height: 8,
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
                    onPressed: (){
                      signIn();
                    },
                    child: Text("Sign In")
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: GestureDetector(
                  child: Text(
                    "I forgot my password",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline
                    ),
                  ),
                  onTap: (){
                    goToForgotpasswordPage();
                  },
                ),
              ),
              SizedBox(
                height: 20,
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
                    onPressed: goToSignUpPage,
                    child: Text("Sign Up")
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 2
                ),
                child: Divider(
                  thickness: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 2
                ),
                child: SignInButton(
                  Buttons.Google,
                  onPressed: (){
                    // ToDO: SignIn with google account
                    Fluttertoast.showToast(msg: "Log in con Google");
                  },
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 2
                ),
                child: SignInButton(
                  Buttons.Facebook,
                  onPressed: (){
                    // ToDO: SignIn with facebook account
                    Fluttertoast.showToast(msg: "Log in con Google");
                  },
                ),
              )
            ],
          ),
        ),
      )
    );
  }

  Future<void> signIn() async{
    final formState = _formKey.currentState;
    if(formState.validate()){
      formState.save();
      try{
        AuthResult authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage()));
      }catch(e){
        Fluttertoast.showToast(
          msg: "Email or password incorrect! Please try again.",
        );
        print("Firebase auth error!");
        print(e.message);
      }
    }

  }

  void goToSignUpPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
  }

  void goToForgotpasswordPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
  }
}
