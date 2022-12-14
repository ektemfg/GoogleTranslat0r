class Translate {
  String? fromLanguage;
  String? toLanguage;
  String text;
  String translated;
  bool isFavourite;

  Translate(this.fromLanguage, this.toLanguage, this.text, this.translated,
      this.isFavourite);

  Map<String, dynamic> toJson() => {
    'fromLanguage': fromLanguage,
    'toLanguage': toLanguage,
    'text': text,
    'translated': translated,
    'isFavourite': isFavourite,
  };

  factory Translate.fromJson(Map<String, dynamic> json) {
    return Translate(
      json['fromLanguage'],
      json['toLanguage'],
      json['text'],
      json['translated'],
      json['isFavourite'],
    );
  }
}