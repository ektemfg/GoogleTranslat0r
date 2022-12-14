class Translate {
  String? fromLanguage;
  String? toLanguage;
  String text;
  String translated;
  bool isFavourite;

  Translate(this.fromLanguage, this.toLanguage, this.text, this.translated,
      this.isFavourite);

  Map toJson() =>
      {
        'fromLanguage': fromLanguage,
        'toLanguage': toLanguage,
        'text': text,
        'translated': translated,
        'isFavourite': isFavourite,
      };

}