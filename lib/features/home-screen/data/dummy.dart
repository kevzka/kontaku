class DummyData {
  static final List<NumberModel> contacts = [
    NumberModel(
      profilePath: null,
      name: "Abgan osis gadungan",
      number: "622234567890",
    ),
    NumberModel(
      profilePath: null,
      name: "Epri peri pulu pulu",
      number: "6281234567890",
    ),
    NumberModel(
      profilePath: null,
      name: "Elo sapa halo",
      number: "6281234567890",
    ),
    NumberModel(
      profilePath: null,
      name: "Faizh bibi jamurre",
      number: "6281234567890",
    ),
    NumberModel(
      profilePath: null,
      name: "Farrel fufufafa",
      number: "6281234567890",
    ),
    NumberModel(profilePath: null, name: "Haekal", number: "6281234567890"),
    NumberModel(
      profilePath: null,
      name: "Hazmi icibos",
      number: "6281234567890",
    ),
    NumberModel(
      profilePath: null,
      name: "Kevin sigma",
      number: "6281234567890",
    ),
    NumberModel(
      profilePath: null,
      name: "zevin sigma",
      number: "6281234567890",
    ),
    NumberModel(
      profilePath: null,
      name: "kevin1",
      number: "6281234567890",
    ),
    NumberModel(
      profilePath: null,
      name: "kevin2",
      number: "6282234567890",
    ),
  ];
}

class NumberModel {
  final String name;
  final String number;
  final String? profilePath;
  final String? uid;
  final String? uidNumber;

  const NumberModel({
    required this.name,
    required this.number,
    this.profilePath,
    this.uid,
    this.uidNumber,
  });
}
