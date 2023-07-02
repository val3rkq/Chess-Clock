import 'dart:async';
import 'package:chess_clock/components/my_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:chess_clock/functions.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../components/main_button.dart';
import 'package:chess_clock/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // formKey for validator
  final _formKey = GlobalKey<FormState>();

  // controllers for settings
  TextEditingController _time1controller = TextEditingController();
  TextEditingController _time2controller = TextEditingController();
  TextEditingController _addSecondsController = TextEditingController();

  // start game or change settings
  bool showStartMenu = true;

  // show pause
  bool pause = false;

  // change player
  bool isPlayer1 = true;

  // add seconds to player
  late bool canAdd1;
  late bool canAdd2;

  // init Hive
  var box = Hive.box('Box');

  // initial time values
  late int initTime1;
  late int initTime2;
  late int timeToAdd;

  // init timer
  late Timer timer;

  // changing time values
  late int time1;
  late int time2;

  // start timer
  void timerGo() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPlayer1) {
        setState(() {
          time1--;
          canAdd1 = true;
          canAdd2 = false;
        });
        // finish game
        if (time1 == 0) {
          gameOver();
        }
      } else {
        setState(() {
          time2--;
          canAdd1 = false;
          canAdd2 = true;
        });
        // finish game
        if (time2 == 0) {
          gameOver();
        }
      }
    });
  }

  void pauseTimer() {
    setState(() {
      canAdd1 = false;
      canAdd2 = false;
    });
    timer.cancel();
  }

  // get Data from Hive
  void getData() {
    setState(() {
      initTime1 = box.get('time1');
      initTime2 = box.get('time2');
      timeToAdd = box.get('timeToAdd');
    });
  }

  // start game
  void startGame() {
    getData();
    setState(() {
      showStartMenu = false;
      time1 = initTime1;
      time2 = initTime2;
      pause = false;
    });
    timerGo();
  }

  // stop game
  void gameOver() {
    // vibration
    HapticFeedback.vibrate();

    setState(() {
      pause = false;
      showStartMenu = true;
      time1 = initTime1;
      time2 = initTime2;
    });
    // stop timer
    timer.cancel();
  }

  @override
  void initState() {
    setState(() {
      // put initial data to DB
      if (box.get('time1') == null) {
        box.put('time1', 180);
        box.put('time2', 180);
        box.put('timeToAdd', 3);
      }
      getData();

      pause = false;

      // get initial data
      time1 = initTime1;
      time2 = initTime2;

      // put data inside controllers
      _time1controller.text = formatMMSS(initTime1);
      _time2controller.text = formatMMSS(initTime2);
      _addSecondsController.text = timeToAdd.toString();
    });
    // this using to hide android status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (showStartMenu) {
                          isPlayer1 = true;
                        } else {
                          if (!pause) {
                            isPlayer1 = true;
                            // add seconds
                            if (isPlayer1 && canAdd1) {
                              if (time1 < initTime1) {
                                time1 += timeToAdd;
                              }
                              canAdd1 = false;
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(isPlayer1 ? 15 : 0),
                      decoration: BoxDecoration(
                          color: isPlayer1 ? Colors.white60 : Colors.white,
                          borderRadius: BorderRadius.circular(25)),
                      child: Center(
                        child: RotationTransition(
                          turns: AlwaysStoppedAnimation(180 / 360),
                          child: Text(
                            formatMMSS(time1),
                            style: textStyle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (showStartMenu) {
                          isPlayer1 = false;
                        } else {
                          if (!pause) {
                            isPlayer1 = false;
                            // add seconds
                            if (!isPlayer1 && canAdd2) {
                              if (time2 < initTime2) {
                                time2 += timeToAdd;
                              }
                              canAdd2 = false;
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(isPlayer1 ? 0 : 15),
                      decoration: BoxDecoration(
                          color: isPlayer1 ? Colors.white : Colors.white60,
                          borderRadius: BorderRadius.circular(25)),
                      child: Center(
                        child: Text(
                          formatMMSS(time2),
                          style: textStyle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: showStartMenu
                  ? Center(
                      child: RotationTransition(
                        turns: AlwaysStoppedAnimation(180 / 360),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (!showStartMenu) {
                                  gameOver();
                                }
                                _showSettingsDialog();
                              },
                              child: MainButton(
                                icon: Icons.settings_rounded,
                                size: 50,
                              ),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            GestureDetector(
                              onTap: startGame,
                              child: MainButton(
                                icon: Icons.restart_alt_rounded,
                                size: 50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: gameOver,
                            child: MainButton(
                              icon: Icons.power_settings_new_rounded,
                              size: 50,
                            ),
                          ),
                          SizedBox(
                            width: 30,
                          ),

                          GestureDetector(
                            onTap: () {
                              setState(() {
                                pause = !pause;
                              });
                              if (pause) {
                                pauseTimer();
                              } else {
                                timerGo();
                              }
                            },
                            child: MainButton(
                              icon: pause ? Icons.play_arrow_rounded : Icons.pause_rounded,
                              size: pause ? 60 : 50,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          // close keyboard when i tap outside it
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 50),
              child: Material(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // top bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // close
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                          ),

                          // title
                          Text(
                            'Settings',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                textBaseline: TextBaseline.alphabetic),
                          ),

                          // confirm
                          IconButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // update settings
                                setState(() {
                                  // put new data to DB
                                  time1 =
                                      formatToSeconds(_time1controller.text);
                                  time2 =
                                      formatToSeconds(_time2controller.text);
                                  timeToAdd =
                                      int.parse(_addSecondsController.text);

                                  box.put('time1', time1);
                                  box.put('time2', time2);
                                  box.put('timeToAdd', timeToAdd);
                                });

                                Navigator.pop(context);

                                // this using to hide android status bar
                                SystemChrome.setEnabledSystemUIMode(
                                    SystemUiMode.manual,
                                    overlays: []);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    duration: Duration(seconds: 2),
                                    content: Text('Data succesfully edited..'),
                                  ),
                                );
                              }
                            },
                            icon: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      // body
                      Form(
                        key: _formKey,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              // time1
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text(
                                      'Initial Time of First Player: ',
                                      style: settingsTextStyle,
                                    ),
                                  ),
                                  Container(
                                    width: 90,
                                    child: MyTextField(
                                      controller: _time1controller,
                                      style: settingsInputTextStyle,
                                    ),
                                  ),
                                ],
                              ),

                              // time2
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text(
                                      'Initial Time of Second Player: ',
                                      style: settingsTextStyle,
                                    ),
                                  ),
                                  Container(
                                    width: 90,
                                    child: MyTextField(
                                      controller: _time2controller,
                                      style: settingsInputTextStyle,
                                    ),
                                  ),
                                ],
                              ),

                              // time to adding
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text(
                                      'How many seconds to add:',
                                      style: settingsTextStyle,
                                    ),
                                  ),
                                  Container(
                                    width: 90,
                                    child: TextFormField(
                                      controller: _addSecondsController,
                                      textAlign: TextAlign.center,
                                      validator: (text) {
                                        if (text == null || text.isEmpty) {
                                          return '';
                                        }

                                        if (int.parse(text) > 10) {
                                          return '';
                                        }

                                        return null;
                                      },
                                      inputFormatters: [
                                        MaskedInputFormatter('##'),
                                      ],
                                      keyboardType: TextInputType.number,
                                      style: settingsInputTextStyle,
                                      decoration: const InputDecoration(
                                        hintText: 's',
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 0,
                                              style: BorderStyle.none),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.transparent,
                                              width: 0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
