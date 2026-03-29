import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mylibrary/ui/pages/LogInPage.dart';

import '../../model/utils/Constants.dart';
import '../pages/Layout.dart';

class Authgate extends StatelessWidget{
  const Authgate({super.key,required this.changeLanguage,required this.changeThemeMode});

  final void Function(Locale) changeLanguage;
  final void Function() changeThemeMode;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context,snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(),),
          );
        }
        if (snapshot.hasData){
          return Layout(title: Constants.appName,changeLanguage: changeLanguage,changeThemeMode: changeThemeMode,);
        }
        return LoginPage(title: Constants.appName, changeLanguage: changeLanguage,changeThemeMode: changeThemeMode,);
      },
    );
  }
}