enum BookStatus{
  notStarted,
  reading,
  finished;

  @override
  String toString(){ //mi serve per il toMap() di Book dove non ho il context
    switch(this){
      case notStarted:
        return 'Non iniziato';
      case reading:
        return 'In corso';
      case finished:
        return 'Terminato';
    }
  }
}