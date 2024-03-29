import 'package:flutter/material.dart';
import 'package:language_picker/languages.dart';
import 'package:translator/translator.dart';
import 'Translate.dart';


// Variables accessible globally.

// Default language list
var languages = Languages.defaultLanguages;
// Custom Language List
List<Language> customLanguages = [
  Languages.afrikaans,
  Languages.albanian,
  Languages.amharic,
  Languages.arabic,
  Languages.armenian,
  Languages.assamese,
  Languages.aymara,
  Languages.azerbaijani,
  Languages.bambara,
  Languages.basque,
  Languages.belarusian,
  Languages.bengali,
  Languages.bosnian,
  Languages.bulgarian,
  Languages.catalan,
  Languages.chineseSimplified,
  Languages.chineseTraditional,
  Languages.corsican,
  Languages.croatian,
  Languages.czech,
  Languages.danish,
  Languages.dhivehi,
  Languages.dutch,
  Languages.english,
  Languages.esperanto,
  Languages.estonian,
  Languages.ewe,
  Languages.finnish,
  Languages.french,
  Languages.westernFrisian,
  Languages.galician,
  Languages.georgian,
  Languages.german,
  Languages.greek,
  Languages.guarani,
  Languages.gujarati,
  Languages.haitian,
  Languages.hausa,
  Languages.hebrew,
  Languages.hindi,
  Languages.hungarian,
  Languages.icelandic,
  Languages.igbo,
  Languages.indonesian,
  Languages.irish,
  Languages.italian,
  Languages.japanese,
  Languages.javanese,
  Languages.kannada,
  Languages.kazakh,
  Languages.centralKhmer,
  Languages.kinyarwanda,
  Languages.korean,
  Languages.kurdish,
  Languages.kirghiz,
  Languages.lao,
  Languages.latin,
  Languages.latvian,
  Languages.lingala,
  Languages.lithuanian,
  Languages.ganda,
  Languages.luxembourgish,
  Languages.macedonian,
  Languages.malagasy,
  Languages.malay,
  Languages.malayalam,
  Languages.maltese,
  Languages.maori,
  Languages.marathi,
  Languages.mongolian,
  Languages.burmese,
  Languages.nepali,
  Languages.norwegian,
  Languages.chewaNyanja,
  Languages.oriya,
  Languages.oromo,
  Languages.pushto,
  Languages.persian,
  Languages.polish,
  Languages.portuguese,
  Languages.panjabi,
  Languages.quechua,
  Languages.romanian,
  Languages.russian,
  Languages.samoan,
  Languages.sanskrit,
  Languages.gaelic,
  Languages.serbian,
  Languages.shona,
  Languages.sindhi,
  Languages.sinhala,
  Languages.slovak,
  Languages.slovenian,
  Languages.somali,
  Languages.spanish,
  Languages.sundanese,
  Languages.swahili,
  Languages.swedish,
  Languages.tajik,
  Languages.tamil,
  Languages.tagalog,
  Languages.tatar,
  Languages.telugu,
  Languages.thai,
  Languages.tigrinya,
  Languages.tsonga,
  Languages.turkish,
  Languages.turkmen,
  Languages.twi,
  Languages.ukrainian,
  Languages.urdu,
  Languages.uighur,
  Languages.uzbek,
  Languages.vietnamese,
  Languages.welsh,
  Languages.xhosa,
  Languages.yiddish,
  Languages.yoruba,
  Languages.zulu
];
// To and From language variables.
Language fromLanguage = Language('en', 'English');
Language toLanguage = Language('no', 'Norwegian');
// Translation List
List<Translate> translations = [];
// Auto translate state
bool autoTranslate = false;
// Input text and translated text variables.
String inputText = '';
String translatedText = '';
// Controllers and implementations
final myController = TextEditingController();
final GoogleTranslator translator = GoogleTranslator();


