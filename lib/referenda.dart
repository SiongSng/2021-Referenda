class ReferendaItem {
  final String title;
  final String description;
  final String image;
  final int agreeVotes;

  String get agreeVotesPercentage {
    return ((agreeVotes / totalVotes) * 100).toStringAsFixed(2);
  }

  final int disagreeVotes;

  String get disagreeVotesPercentage {
    return ((disagreeVotes / totalVotes) * 100).toStringAsFixed(2);
  }

  final int totalVotes;
  final String pollingPlace;

  String get _pollingPlace {
    String str = pollingPlace;
    str = str.replaceAll("投開票所數 已送/應送:", "");
    str = str.trim();
    return str;
  }

  int get donePollingPlaces {
    return int.parse(_pollingPlace.split("/")[0].replaceAll(",", ""));
  }

  int get totalPollingPlaces {
    return int.parse(_pollingPlace.split("/")[1].replaceAll(",", ""));
  }

  ReferendaItem({
    required this.title,
    required this.description,
    required this.image,
    required this.agreeVotes,
    required this.disagreeVotes,
    required this.totalVotes,
    required this.pollingPlace,
  });
}
