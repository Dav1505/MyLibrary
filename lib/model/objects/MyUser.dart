import 'package:mylibrary/model/objects/UserGenres.dart';

import '../Model.dart';

class MyUser {
  final String uid;
  final String name;
  final String surname;
  final String email;
  final DateTime birth;
  final Usergenres genre;

  MyUser({required this.uid,required this.name,required this.surname,required this.email,required this.birth,
  required this.genre});

  static MyUser fromMap(String uid,Map<String,dynamic> map){
    return MyUser(
      uid: uid,
      name: map['nome'] ?? '',
      surname: map['cognome'] ?? '',
      email: map['email'] ?? '',
      birth: DateTime.parse(map['dataNascita']),
      genre: Model.sharedInstance.toUserGenre(map['sesso'])
    );
  }
}