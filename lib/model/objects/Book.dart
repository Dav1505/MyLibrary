import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mylibrary/model/objects/BookStatus.dart';

import '../Model.dart';

class Book{
  String id;
  String title;
  List<String> authors;
  BookStatus status;
  List<String> genres;

  String? description;
  String? coverUrl;
  DateTime? publicationDate;
  String? details;
  GeoPoint? lastNotePosition;

  Book({required this.id,required this.title,required this.authors,required this.status,required this.genres,
    this.description, this.coverUrl,this.publicationDate,this.details,this.lastNotePosition});

  factory Book.fromMap(Map<String, dynamic> data){
    return Book(
      id: data['id'],
      title: data['titolo'],
      authors: _parse(data['autori']),
      status: Model.sharedInstance.toStatus(data['stato']),
      genres: _parse(data['generi']),
      description: data['descrizione'],
      coverUrl: data['coverUrl'],
      publicationDate: Model.sharedInstance.formatDate(data['dataPubblicazione']),
      details: data['note'],
      lastNotePosition: data['posizioneUltimaNota']
    );
  }
  Map<String, dynamic> toMap(){
    return {
      "id": id,
      "titolo": title,
      "autori": authors.join(', '),
      "stato": status.toString(),
      "generi": genres.join(', '),
      "descrizione": description,
      "coverUrl": coverUrl,
      "dataPubblicazione": publicationDate?.toLocal().toString().split(' ')[0],
      "note": details,
      "posizioneUltimaNota": lastNotePosition
    };
  }

  static List<String> _parse(dynamic raw){ //gestisce i casi in cui autori o generi non sono una lista
    if (raw == null){
      return [];
    }
    if (raw is String){
      return [raw];
    }
    if (raw is List){
      return raw.whereType<String>().toList();
    }
    return [];
  }


}