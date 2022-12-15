import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:language_picker/languages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

import 'Translate.dart';
import 'variables.dart';
import 'dart:async';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
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
  ScrollController _scrollController = ScrollController();
  bool _translationInProgress = false;
  Timer _translationTimer = Timer(Duration.zero, () {});

  // Most variables are defined in variables.dart to make this page readable.
  // Functions

  // Language Switch
  void invertLanguages() async {
    setState(() {
      Language language1 = fromLanguage;
      Language language2 = toLanguage;
      toLanguage = language1;
      fromLanguage = language2;
      //
      if (inputText != '') {
        String _input = inputText;
        String _output = translatedText;
        translatedText = _input;
        inputText = _output;
        myController.text = _output;
        _translateText(inputText);
      }
    });
  }

  // Translation function, sending requests to the API
  void _translateText(String inputText) async {
    // Don't translate if translate is in progress.
    if (_translationTimer != null && _translationTimer.isActive) {
      _translationTimer.cancel();
    }
    // Lets make 0.5s throttling timer. Don't translate if timer is active.
    _translationTimer = Timer(Duration(milliseconds: 500), () async {
      try {
        var translation = await translator.translate(inputText,
            from: fromLanguage.isoCode, to: toLanguage.isoCode);
        print("API REQUEST TRANSLATE");
        setState(() {
          translatedText = translation.text;
          if (!autoTranslate) {
            translations.add(Translate(fromLanguage.name,
                toLanguage.name, inputText, translatedText, false));
            save();
          }
        });
      } catch (error) {
        // If there is error and auto-translate is off, show Snack bar.

        !autoTranslate ?
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(
          //Usually because language pair is not supported by the API, or Input field is empty.
          content: Text('Language combination not supported yet / Empty Input.'), duration: Duration(milliseconds: 1200),
        )) : print("not supported or empty input");
      }
    });
  }

  // Reset Live Translation Widget State.
  void resetLive() {
    setState(() {
      inputText = '';
      translatedText = '';
    });
  }

  // Update inputText variable.
  void _updateInputText() {
    setState(() {
      inputText = myController.text;
    });
  }

  // Add to translationHistory.
  void addToFavourite(Translate translation) {
    translations.add(translation);
    save();
  }
  // Remove from translationHistory.
  void removeFromFavourite(Translate translation) {
    translations.remove(translation);
    save();
  }

  // Save / Update SharedPrefs.
  save() async {
    print("Saving to SharedPrefs.");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonTranslations =
    translations.map((translation) => translation.toJson()).toList();
    String jsonString = json.encode(jsonTranslations);
    prefs.setString('savedTranslations', jsonString);
  }

  // Load translationHistory from SharedPrefs.
  Future<void> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonTranslations = prefs.getString('savedTranslations');
    if (jsonTranslations != null) {
      print("Loading from sharedprefs");
      List<dynamic> jsonList = await json.decode(jsonTranslations);
      List<Translate> loadedTranslations = jsonList.map((json) => Translate.fromJson(json)).toList();
      translations = loadedTranslations;
    }
  }

    // Check if that translation is in history and favourite?
    bool existsAsFavourite(Translate currentTranslation) {
    if (translations.any((translation) => translation.translated == currentTranslation.translated && translation.isFavourite == true)) {
      return true;
    } else {
      return false;
    }
  }
 // Check if that translation is in history.
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
    // Load from SharedPrefs.
    load();
  }



  @override
  Widget build(BuildContext context) {
    // Lets get define Screen Width and Height if we need them later.
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    /* Unlike having each widget in separate file like before,
    they are now defined here. It is most due to coding issues I have encountered.
     */
    // Widgets:

    // LanguageBar Widget:
    Widget languageBar() {return Padding(
      padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // FROM LANGUAGE
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
              onChanged: (Language? value) async {
                setState(() {
                  fromLanguage = value!;
                });
                // Translate on language change if input not empty.
                if (inputText != '') {
                  _translateText(inputText);
                }
              },
            ),
          ),
          // SWITCH LANGUAGE BUTTON
          IconButton(
            icon: Icon(Icons.autorenew, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
            onPressed: () {
              invertLanguages();
            },
          ),
          // TO LANGUAGE
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
              onChanged: (Language? value) async {
                setState(() {
                  toLanguage = value!;
                });
                // Translate on language change if input not empty.
                if (inputText != '') {
                  _translateText(inputText);
                }
              },
            ),
          ),
        ],
      ),
    );}
    // InputField Widget:
    Widget inputField() {return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 15),
      child: !autoTranslate
          ? TextField(
        autocorrect: false,
        textInputAction: TextInputAction.done,
        minLines: MediaQuery.of(context).orientation == Orientation.landscape ? 4 : 7,
        maxLines: null,
        controller: myController,
        onEditingComplete: () async {
          _translateText(inputText);
          FocusManager.instance.primaryFocus?.unfocus();
        },
        onChanged: (value) {
          if ( inputText == '') {
            resetLive();
          }
        },
        decoration:  InputDecoration(
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black45 : Colors.white,
            hintText: 'Write something to translate.'),
      )
          : TextField(
        autocorrect: false,
        textInputAction: TextInputAction.done,
        minLines: MediaQuery.of(context).orientation == Orientation.landscape ? 4 : 7,
        maxLines: null,
        controller: myController,
        onChanged: (value) {
          if (value == '') {
            translatedText = '';
          } else {
            // Translate if text is changed
            Future.delayed(const Duration(milliseconds: 500), () {
              if (value != inputText) {
                _translateText(inputText);
              }
            });
          }
        },
        onEditingComplete: () {
          var currentTranslation = Translate(
              fromLanguage.name,
              toLanguage.name,
              inputText,
              translatedText,
              true);
          addToFavourite(currentTranslation);
          FocusManager.instance.primaryFocus?.unfocus();
        },
        decoration:  InputDecoration(
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black45 : Colors.white,
            hintText: 'Write something, will translate on the go.', labelStyle: TextStyle(fontSize: 20)),
      ),
    );}
    // LiveTranslation Card Widget:
    Widget  liveTranslation() {return Card(
      child: Container(
        // Dark mode color will be black45
        color: Theme.of(context).brightness == Brightness.dark ? Colors.black45 : Colors.blueAccent,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(toLanguage.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
                            content: Text('Already in the history / favorites.',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), duration: Duration(milliseconds: 1200),
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
                style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold)),
            Text(inputText,
                style: TextStyle(fontSize: 18, color: Colors.white)),
          ],
        ),
      ),
    );}
    // Card Widget for each item shown in translationHistory:
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
                        '${translations[index].fromLanguage} -> ${translations[index].toLanguage}',style: TextStyle(fontSize: 18)),
                    Text(translations[index].translated,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(translations[index].text,
                        style: TextStyle(fontSize: 17)),
                  ],
                )),
            IconButton(
                onPressed: () {
                  setState(() {
                    translations[index].isFavourite
                        ? translations[index].isFavourite = false
                        : translations[index].isFavourite = true;

                  });
                  save();
                },
                icon: Icon(Icons.star),
                color: translations[index].isFavourite == true
                    ? Colors.blue
                    : Colors.grey),
          ],
        ),
      );
    };
    // TranslationHistory Widget:
Widget translationHistory() {
  return Expanded(
  child: ListView.builder(
shrinkWrap: true,
    scrollDirection: Axis.vertical,
      itemCount: translations.length,
      itemBuilder:
          (BuildContext translationContext, int translationItemIndex) {
        final item = translations[translationItemIndex];
        // Translations in history list can be swiped left/right to get deleted.
        return Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              setState(() {
                removeFromFavourite(item);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Translation deleted', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    duration: Duration(milliseconds: 700),
                    // Fast fingers can get their translation back if they click Undo button ;-)
                    action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          setState(() {
                            addToFavourite(item);
                          });
                        })));
              });
            },
            // Red delete behind the translation when swiping it away.
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

        // App Scaffold Widget / Main Widget combining all the widgets to create UI.
        return Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  // Auto Translate Switch - Changes between manual / auto translation.
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
            // ListView with all widgets combines.
            body: ListView(
            shrinkWrap: true,
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children:[
                Container(
                  width:screenWidth,
                  // Need different height of container if in landscape to be able to scroll through history.
                  height: MediaQuery.of(context).orientation == Orientation.landscape ? screenHeight+100 : screenHeight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      languageBar(),
                      inputField(),
                      // LiveTranslation hidden if no input.
                      inputText != '' ? liveTranslation() : Container(),
                      translationHistory(),
                    ],
                  ),
                ),
    ],
              ),
            );
  }
}
