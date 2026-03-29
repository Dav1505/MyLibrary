import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mylibrary/model/managers/DatabaseManager.dart';
import 'package:mylibrary/model/managers/LocationManager.dart';
import 'package:mylibrary/model/managers/SearchManager.dart';
import 'package:mylibrary/model/objects/Book.dart';
import 'package:mylibrary/model/objects/GoogleBook.dart';
import 'package:mylibrary/model/objects/MyUser.dart';
import 'package:mylibrary/model/objects/UserGenres.dart';

import '../ui/behaviors/AppLocalizations.dart';
import 'objects/BookFilters.dart';
import 'objects/BookStatus.dart';


class Model{
  static Model sharedInstance = Model();
  final DatabaseManager _dbManager = DatabaseManager();
  final SearchManager _searchManager = SearchManager();
  final LocationManager _locationManager = LocationManager();

  Stream<QuerySnapshot<Map<String, dynamic>>> getBooks(BookFilters filter) {
    return _dbManager.getBooks(filter);
  }

  Future<MyUser> getUser(){
    return _dbManager.getUser();
  }

  Future<void> addBook(Book book) async{
    await _dbManager.addBook(book);
  }

  Future<void> getDetails(Book book) async{
    await _dbManager.getBookDetails(book.id);
  }

  Future<void> changeStatus(Book book, String newStatus) async{
    await _dbManager.updateBookStatus(book.id, newStatus);
  }

  Future<void> saveNotes(Book book, String notes, GeoPoint lastNotePosition) async{
    await _dbManager.saveNotes(book.id, notes, lastNotePosition);
  }

  Future<void> signIn(String email, String password) async{
    await _dbManager.signIn(email, password);
  }

  Future<void> signUp(BuildContext context,String nome, String cognome, DateTime dataNascita, String genere,
      String email, String password) async{
    await _dbManager.signUp(context,nome,cognome,dataNascita,genere,email,password);
  }

  Future<void> signOut() async{
    await _dbManager.signOut();
  }

  Future<void> deleteAccount(BuildContext context) async{
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate("deleteAccount?")),
        content: Text(AppLocalizations.of(context)!.translate("permanentOperation")),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.translate("cancel")),
          ),
          TextButton(
            onPressed: () async{
              Navigator.of(context).pop();
              await _dbManager.deleteUserAccount(context);
            },
            child: Text(AppLocalizations.of(context)!.translate("confirm")),
          )
        ],
      ),
    );
  }


  String getFilterLabel(BuildContext context,BookFilters filter) {
    switch(filter){
      case BookFilters.all:
        return AppLocalizations.of(context)!.translate("filter_all");
      case BookFilters.notStarted:
        return AppLocalizations.of(context)!.translate("filter_notStarted");
      case BookFilters.reading:
        return AppLocalizations.of(context)!.translate("filter_reading");
      case BookFilters.finished:
        return AppLocalizations.of(context)!.translate("filter_finished");
    }
  }

  String getStatus(BuildContext context,BookStatus status) {
    switch (status){
      case BookStatus.notStarted:
        return AppLocalizations.of(context)!.translate("status_notStarted");
      case BookStatus.reading:
        return AppLocalizations.of(context)!.translate("status_reading");
      case BookStatus.finished:
        return AppLocalizations.of(context)!.translate("status_finished");
    }
  }

  String getGenreLabel(BuildContext context,Usergenres genre) {
    switch(genre){
      case Usergenres.male:
        return AppLocalizations.of(context)!.translate('male');
      case Usergenres.female:
        return AppLocalizations.of(context)!.translate('female');
      case Usergenres.other:
        return AppLocalizations.of(context)!.translate('other');
    }
  }

  Usergenres toUserGenre(String genre){
    switch(genre){
      case('Maschio' || 'Male'):
        return Usergenres.male;
      case('Femmina' || 'Female'):
        return Usergenres.female;
      case('Altro' || 'Other'):
        return Usergenres.other;
    }
    throw Exception('Genere non corretto');
  }

  BookStatus toStatus(String status){
    switch(status){
      case('Not started' || 'Non iniziato'):
        return BookStatus.notStarted;
      case('Reading' || 'In corso'):
        return BookStatus.reading;
      case('Finished' || 'Terminato'):
        return BookStatus.finished;
    }
    throw Exception('Stato non corretto');
  }

  Future<List<GoogleBook>> searchBooks(String query) async{
    return _searchManager.searchBooks(query);
  }

  DateTime? formatDate(String? date){ //la data restituita da Google Books non sempre era del formato corretto
    if (date == null || date.isEmpty) return null;

    try{
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
        return DateTime.parse(date);
      }
      if (RegExp(r'^\d{4}-\d{2}$').hasMatch(date)){
        final parts = date.split('-');
        return DateTime(int.parse(parts[0]),int.parse(parts[1]),1);
      }
      if (RegExp(r'^\d{4}$').hasMatch(date)){
        return DateTime(int.parse(date),1,1);
      }
    }catch(_){

    }
    return null;
  }

  Future<void> deleteBook(String bookId) async{
    await _dbManager.deleteBook(bookId);
  }

  String? favouriteGenre(List<Book> books){
    final Map<String,int> counter = {};
    for (final book in books){
      if (book.status == BookStatus.finished){
        for (final genre in book.genres){
          counter[genre] = (counter[genre] ?? 0)+1;
        }
            }
    }
    if (counter.isEmpty) return null;

    return counter.entries.reduce((a,b) => a.value > b.value ? a : b).key;
  }

  List<Book> sortByFavouriteGenre(List<Book> books, String? favouriteGenre){
     if (favouriteGenre == null) return books;

     books.sort((a,b){
       final aMatch = a.genres.contains(favouriteGenre);
       final bMatch = b.genres.contains(favouriteGenre);

       if (aMatch && !bMatch) return -1;
       if (!aMatch && bMatch) return 1;
       return 0;
     });

     return books;
  }

  Future<bool> handleLocationPermission(BuildContext context) async{
    return await _locationManager.handleLocationPermission(context);
  }

  Future<String?> getLocation(double latitude, double longitude) async{
    return await _locationManager.getLocation(latitude, longitude);
  }

}