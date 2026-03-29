import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mylibrary/model/objects/BookFilters.dart';
import 'package:mylibrary/ui/behaviors/AppLocalizations.dart';
import '../objects/Book.dart';
import '../objects/MyUser.dart';

class DatabaseManager{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  String? get currenUid => currentUser?.uid;


  Future<MyUser> getUser() async{
    final uid = currentUser!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();

    return MyUser.fromMap(uid,doc.data()!);
  }

  Future<void> addBook(Book book) async{
    final doc = await _firestore.collection('users').doc(currenUid).collection('books').add(book.toMap());
    await doc.update({'id': doc.id});
  }

  Stream<QuerySnapshot<Map<String,dynamic>>> getBooks(BookFilters filter) {
    final books = _firestore.collection('users').doc(currenUid).collection('books');

    switch(filter){
      case BookFilters.all:
        return books.snapshots();
      case BookFilters.notStarted:
        return books.where('stato',isEqualTo: "Non iniziato").snapshots();
      case BookFilters.reading:
        return books.where('stato',isEqualTo: "In corso").snapshots();
      case BookFilters.finished:
        return books.where('stato',isEqualTo: "Terminato").snapshots();
    }
  }

  Future<Book> getBookDetails(String bookId) async{
    final snapshot = await _firestore.collection('users').doc(currenUid).collection('books').doc(bookId).get();

    if (!snapshot.exists){
      throw Exception("book not found");
    }
    return Book.fromMap(snapshot.data()!);
  }

  Future<void> updateBookStatus(String bookId,String status) async{
    await _firestore.collection('users').doc(currenUid).collection('books').doc(bookId).update({'stato': status});
  }

  Future<void> saveNotes(String bookId,String notes,GeoPoint lastNotePosition) async{
    await _firestore.collection('users').doc(currenUid).collection('books').doc(bookId).update(
      {
       'note': notes,
        'posizioneUltimaNota': lastNotePosition
      });
  }

  Future<void> signIn(String email, String password) async{
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp(BuildContext context,String nome, String cognome, DateTime dataNascita,
  String genere, String email, String password) async{

    try{
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      final uid = _auth.currentUser!.uid;

      await _firestore.collection('users').doc(uid).set({
        'nome': nome,
        'cognome': cognome,
        'dataNascita': dataNascita.toLocal().toString().split(" ")[0],
        'sesso': genere,
        'email': email,
      });
    } on FirebaseAuthException catch(e){
      if (e.code == 'email-already-in-use'){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.translate("emailAlreadyInUse"))));
      }
      if (e.code == 'invalid-email'){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.translate("invalidEmail"))));
      }
      if (e.code == 'weak-password'){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.translate("weakPassword"))));
      }
    }
  }

  Future<void> signOut() async{
    await _auth.signOut();
  }

  Future<void> deleteBook(String bookId) async{
    await _firestore.collection('users').doc(currenUid).collection('books').doc(bookId).delete();
  }

  Future<void> _deleteUserData(String uid) async{
    final books = await _firestore.collection('users').doc(currenUid).collection('books').get();

    for (final doc in books.docs){
      await doc.reference.delete();
    }
    await _firestore.collection('users').doc(currenUid).delete();
  }

  Future<void> deleteUserAccount(BuildContext context) async{
    try{
      await _deleteUserData(currentUser!.uid);
      await currentUser!.delete();
      Navigator.of(context).pushNamedAndRemoveUntil('/LogInPage', (route)=>false);
    } on FirebaseAuthException catch(e){
      if (e.code == 'requires-recent-login'){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.translate("loginRequired")))
        );
      }
    }
  }
}