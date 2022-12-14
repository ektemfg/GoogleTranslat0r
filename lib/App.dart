import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:language_picker/languages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

import 'Translate.dart';
import 'variables.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: MyHomePage(title: 'Google Translator'),
        debugShowCheckedModeBanner: false);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  // variables are defines in variables.dart to make this page readable.
  // Functions
  void invertLanguages() {
    setState(() {
      Language language1 = fromLanguage;
      Language language2 = toLanguage;
      toLanguage = language1;
      fromLanguage = language2;
    });
  }

  void _translateText(String inputText) async {
    await translator
        .translate(inputText,
        from: fromLanguage.isoCode, to: toLanguage.isoCode)
        .then((value) {
      setState(() {
        translatedText = value.text;
        if (!autoTranslate) {
          translations.add(Translate(fromLanguage.name,
              toLanguage.name, inputText, translatedText, false));
        }
      });
    });
  }

  void _updateInputText() {
    setState(() {
      inputText = myController.text;
    });
  }

  void addToFavourite(Translate translation) {
    translations.add(translation);
    save();
  }

  void removeFromFavourite(Translate translation) {
    translations.remove(translation);
    save();
  }

  save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonTranslations =
    translations.map((translation) => translation.toJson()).toList();
    String jsonString = json.encode(jsonTranslations);
    prefs.setString('savedTranslations', jsonString);
  }

  Future<void> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonTranslations = prefs.getString('savedTranslations');
    if (jsonTranslations != null) {
      print("Loading from sharedprefs");
      List<dynamic> jsonList = await json.decode(jsonTranslations);
      List<Translate> loadedTranslations = jsonList.map((json) => Translate.fromJson(json)).toList();
      translations = loadedTranslations;
      print(translations);
    }
  }


    bool existsAsFavourite(Translate currentTranslation) {
    if (translations.any((translation) => translation.translated == currentTranslation.translated && translation.isFavourite == true)) {
      return true;
    } else {
      return false;
    }
  }

  bool existsInHistory(Translate currentTranslation) {
    if (translations.any((translation) => translation.translated == currentTranslation.translated)) {
      return true;
    } else {
      return false;
    }
  }

  // Overrides
  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    myController.addListener(_updateInputText);
    load();
  }



  @override
  Widget build(BuildContext context) {
    //Widgets
    Widget languageBar() {return Padding(
      padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: DropdownButton(
              itemHeight: 80,
              value: fromLanguage,
              icon: const Flexible(child: Icon(Icons.arrow_drop_down)),
              items: languages.map((language) {
                return DropdownMenuItem(
                  value: language,
                  child: Text(language.name),
                );
              }).toList(),
              onChanged: (Language? value) {
                setState(() {
                  fromLanguage = value!;
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.autorenew, color: Colors.black),
            onPressed: () {
              invertLanguages();
            },
          ),
          Flexible(
            child: DropdownButton(
              itemHeight: 80,
              value: toLanguage,
              icon: const Flexible(child: Icon(Icons.arrow_drop_down)),
              items: languages.map((language) {
                return DropdownMenuItem(
                  value: language,
                  child: Text(language.name),
                );
              }).toList(),
              onChanged: (Language? value) {
                setState(() {
                  toLanguage = value!;
                });
              },
            ),
          ),
        ],
      ),
    );}
    Widget inputField() {return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 15),
      child: !autoTranslate
          ? TextField(
        autocorrect: false,
        textInputAction: TextInputAction.done,
        minLines: 10,
        maxLines: null,
        controller: myController,
        // I wanted to use onEditingCompleted because on changed sent many requests to api.
        onEditingComplete: () async {
          _translateText(inputText);
          FocusManager.instance.primaryFocus?.unfocus();
        },
        decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Write something to translate.'),
      )
          : TextField(
        autocorrect: false,
        textInputAction: TextInputAction.done,
        minLines: 10,
        maxLines: null,
        controller: myController,
        // I wanted to use onChanged to have an autotranslate option in the app.
        onChanged: (value) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (value != inputText) {
              _translateText(inputText);
            } else if (value == '') {
              translatedText = '';
            }
          });
        },
        decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Write something, will translate on the go.'),
      ),
    );}
    Widget liveTranslation() {return Card(
      child: Container(
        color: Colors.blueAccent,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(toLanguage.name, style: TextStyle(color: Colors.white)),
                IconButton(
                    onPressed: () {
                      var currentTranslation = Translate(
                          fromLanguage.name,
                          toLanguage.name,
                          inputText,
                          translatedText,
                          true);
                      setState(() {
                        !existsAsFavourite(currentTranslation) && !existsInHistory(currentTranslation) ?
                        addToFavourite(currentTranslation) :  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Already in the history / favorites.'), duration: Duration(milliseconds: 1200),
                       ));
                      });
                    },
                    icon: existsAsFavourite(Translate(
                        fromLanguage.name,
                        toLanguage.name,
                        inputText,
                        translatedText,
                        true)) ? Icon(Icons.star, color: Colors.white) : Icon(Icons.star_border, color: Colors.white)
                )],
            ),
            Text(translatedText,
                style: TextStyle(fontSize: 25, color: Colors.white)),
            Text(inputText,
                style: TextStyle(fontSize: 15, color: Colors.white)),
          ],
        ),
      ),
    );}
    Widget displayTranslationItem(int index) {
      return Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        '${translations[index].fromLanguage} -> ${translations[index].toLanguage}'),
                    Text(translations[index].text,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(translations[index].translated,
                        style: TextStyle(fontSize: 15)),
                  ],
                )),
            IconButton(
                onPressed: () {
                  setState(() {
                    translations[index].isFavourite
                        ? translations[index].isFavourite = false
                        : translations[index].isFavourite = true;
                  });
                },
                icon: Icon(Icons.star),
                color: translations[index].isFavourite == true
                    ? Colors.blue
                    : Colors.grey),
          ],
        ),
      );
    };
Widget translationHistory() {return Expanded(
  child: ListView.builder(
      itemCount: translations.length,
      itemBuilder:
          (BuildContext translationContext, int translationItemIndex) {
        final item = translations[translationItemIndex];
        return Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              setState(() {
                removeFromFavourite(item);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Translation deleted'),
                    action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          setState(() {
                            addToFavourite(item);
                          });
                        })));
              });
            },
            background: Container(
                color: Colors.red,
                child: const Center(
                    child: Text("Delete",
                        style: TextStyle(fontSize: 25, color: Colors.white),
                        maxLines: 1))),
            child: displayTranslationItem(translationItemIndex));
      }
  ),
);}

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Auto Translate', style: TextStyle(fontSize: 15)),
                  Switch(
                      activeColor: Colors.white,
                      value: autoTranslate,
                      onChanged: (value) {
                        setState(() {
                          autoTranslate = value;
                        });
                      })
                ],
              ),
            ),
            body: Column(
              children: [
                languageBar(),
                inputField(),
                inputText != '' ? liveTranslation() : Container(),
                translationHistory(),
              ],
            ),
        ));
  }
}
