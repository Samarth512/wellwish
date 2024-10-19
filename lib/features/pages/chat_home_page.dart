import 'dart:convert';
import 'dart:math';
import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wellwiz/features/bot/bot_screen.dart';
import 'package:wellwiz/features/emergency/emergency_service.dart';
import 'package:wellwiz/secrets.dart';

class ChatHomePage extends StatefulWidget {
  String uname = "";
  ChatHomePage({super.key, required this.uname});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  int randomImageIndex = 1;
  String thought = "To be, or not to be, that is the question";
  bool thoughtGenerated = false;
  late final ChatSession _chat;
  static const _apiKey = geminikey;
  late final GenerativeModel _model;
  bool falldone = false;
  List contacts = [];

  void generateThought() async {
    print("e");
    String prompt =
        "Generate a deep philosophical Shakespearean thought for a mental health application that is purely for demonstration purposes and no commercial use. The thought has to be unique and should be positive. Respond with only the thought without formatting and nothing else. Keep the thought limited to 30 words.";
    var response = await _chat.sendMessage(Content.text(prompt));
    setState(() {
      thought = response.text!;
      thoughtGenerated = true;
    });
  }

  @override
  void initState() {
    
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
    _chat = _model.startChat();
    randomImageIndex = (Random().nextInt(7));
    generateThought();
  }

  Future<void> _sendEmergencyMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final encodedContacts = prefs.getString('contacts');

    
    final decodedContacts = jsonDecode(encodedContacts!) as List;
    contacts
        .addAll(decodedContacts.map((c) => ContactData.fromJson(c)).toList());
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    double lat = position.latitude;
    double lng = position.longitude;
    for (var i = 0; i < contacts.length; i++) {
      
      var result = await BackgroundSms.sendMessage(
          phoneNumber: "+91${contacts[i].phone}",
          message:
              "I am facing some critical medical condition. Please call an ambulance or arrive here: https://www.google.com/maps/place/$lat+$lng",
          simSlot: 1);
      // print(
      //     """Need help! My location is https://www.google.com/maps/place/$lat+$lng""");
      if (result == SmsStatus.sent) {
        print("Sent");
        Fluttertoast.showToast(msg: "SOS ALERT SENT TO ${contacts[i].name}");
      } else {
        print("Failed");
      }
      launchUrl(Uri.parse("tel:108"));
    }
  }

  _sosprotocol() async {
    bool popped = false;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Are you okay?"),
            content: Text(
              "You just pressed the SOS button. This button is used to trigger emergency. Please tell us if you're fine. Or else the emergency contacts will be informed.",
              textAlign: TextAlign.justify,
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color.fromARGB(255, 106, 172, 67)),
                onPressed: () {
                  falldone = false;
                  setState(() {
                    falldone = false;
                    popped = true;
                    Navigator.pop(context);
                  });
                  print("falldone val $falldone");
                  return;
                },
                child: Text(
                  "I'm fine",
                  style: TextStyle(
                      fontFamily: 'Mulish',
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          );
        });
    await Future.delayed(Duration(seconds: 10));
    // print("poppedvalue : $popped");
    if (popped == false) {
      _sendEmergencyMessage();
      // print("didnt respond");
      Navigator.pop(context);
    }
    // print("Wait complete");
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero, // Optional: removes any default padding
      children: <Widget>[
        Container(
          height: 50,
          // color: Colors.grey.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Hi, ",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Mulish',
                    fontSize: 40,
                    color: Color.fromARGB(255, 106, 172, 67)),
              ),
              Text(
                widget.uname,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Mulish',
                    fontSize: 40,
                    color: const Color.fromRGBO(97, 97, 97, 1)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return BotScreen();
            }));
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12))),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/logo.jpeg',
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align text to start
                    children: [
                      Text(
                        'Chat with Wisher',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Mulish',
                          color: Color.fromARGB(255, 106, 172, 67),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        height: 2.0,
                        width: 180.0,
                        color: Colors.grey.shade800,
                      ),
                      Text(
                        'Your personal medical assistant',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                          fontFamily: 'Mulish',
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        GestureDetector(
          onTap: () {
            _sosprotocol();
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: Container(
              padding: EdgeInsets.all(20),
              height: 80,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              child: Center(
                child: Row(
                  children: [
                    Icon(
                      Icons.alarm,
                      size: 40,
                      color: Colors.red.shade400,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Row(
                      children: [
                        Text(
                          'Send ',
                          style: TextStyle(
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        Text('Alerts',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                                fontSize: 18)),
                      ],
                    ),
                    Spacer(),
                    Icon(
                      Icons.navigate_next_rounded,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return EmergencyScreen();
            }));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Container(
              padding: EdgeInsets.all(20),
              height: 80,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              child: Center(
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      size: 40,
                      color: Colors.grey.shade700,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Row(
                      children: [
                        Text(
                          'SOS ',
                          style: TextStyle(
                              color: Color.fromARGB(255, 106, 172, 67),
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        Text('Contacts',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                                fontSize: 18)),
                      ],
                    ),
                    Spacer(),
                    Icon(
                      Icons.navigate_next_rounded,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Dismissible(
            key: UniqueKey(), // Unique key for each dismissible widget
            direction: DismissDirection.horizontal, // Enables left-right swipe
            onDismissed: (direction) {
              setState(() {
                // Generate a new random image index
                randomImageIndex = (Random().nextInt(7));

                // Generate a new thought by calling your function
                generateThought();
              });
            },
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9, // 16:9 aspect ratio
                    child: Image.asset(
                      'assets/thought/$randomImageIndex.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(42),
                      bottomRight: Radius.circular(42),
                    ),
                    color: Colors.grey.shade800,
                  ),
                  padding:
                      EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 20),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text(
                        thoughtGenerated
                            ? "“" + thought.replaceAll('\n', '') + "”"
                            : thought,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Mulish',
                            fontSize: 16),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          thoughtGenerated ? "- Wisher   " : "-Shakespeare",
                          style: TextStyle(
                              fontFamily: 'Mulish',
                              color: Colors.green.shade300,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }
}
