import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:quaythuong/app_orientation.dart';
import 'package:quaythuong/config.dart';
import 'package:quaythuong/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController loginUsernameController = TextEditingController();
  TextEditingController registerUsernameController = TextEditingController();
  TextEditingController registerPhoneController = TextEditingController();
  StreamController<int> controller = StreamController<int>();
  final assetsAudioPlayer = AssetsAudioPlayer();

  bool loading = false;
  bool isAuth = false;
  dynamic currentUser;
  Firestore firestore = firebase.firestore();
  Uuid uuid = const Uuid();

  List<dynamic> awards = [];
  List<dynamic> histories = [];

  Future<void> readAwards() async {
    setState(() {
      loading = true;
    });
    CollectionReference ref = firestore.collection('award');
    (await ref.get()).docs.forEach((element) {
      awards.add({
        'id': element.data()['id'],
        'name': element.data()['name'],
        'color': element.data()['color'],
        'turn': element.data()['turn'],
      });
    });
    setState(() {
      loading = false;
    });
  }

  Future<void> updateHistories(String award, int turn) async {
    setState(() {
      currentUser['turn'] += turn;
      histories.add(award);
      currentUser['histories'] = histories;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', jsonEncode(currentUser));
    firestore
        .collection('user')
        .where('username', '==', currentUser['username'])
        .get()
        .then((value) => value.forEach((p0) => p0.ref.update(data: {
              'histories': currentUser['histories'],
              'turn': currentUser['turn']
            })));

    CollectionReference ref2 = firestore.collection('history');
    ref2.doc().set({
      'id': uuid.v4(),
      'username': currentUser['username'],
      'award': award,
      'turn': turn,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
  }

  Future<void> onLogin() async {
    if (loginUsernameController.text.trim().isEmpty) {
      const snackBar = SnackBar(
        content: Text('Không được trống'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      List<DocumentSnapshot> docs = (await firestore
              .collection('user')
              .where('username', '==', loginUsernameController.text.trim())
              .get())
          .docs;
      if (docs.isEmpty) {
        const snackBar = SnackBar(
          content: Text('Sai tên đăng nhập'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        loginUsernameController.clear();
        Navigator.of(context).pop();
        setState(() {
          isAuth = true;
          currentUser = docs[0].data();
          histories = currentUser['histories'];
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuth', true);
        await prefs.setString('currentUser', jsonEncode(currentUser));
        const snackBar = SnackBar(
          content: Text('Đăng nhập thành công'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<void> onRegister() async {
    if (registerUsernameController.text.trim().isEmpty ||
        registerPhoneController.text.trim().isEmpty) {
      const snackBar = SnackBar(
        content: Text('Không được trống'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      CollectionReference ref = firestore.collection('user');
      if ((await firestore
              .collection('user')
              .where('username', '==', registerUsernameController.text.trim())
              .get())
          .docs
          .isEmpty) {
        ref.doc().set({
          'username': registerUsernameController.text.trim(),
          'phone': registerPhoneController.text.trim(),
          'turn': 0,
          'histories': [''],
          'activeAwards': '',
        }).then((_) {
          registerUsernameController.clear();
          registerPhoneController.clear();
          const snackBar = SnackBar(
            content: Text('Đăng ký thành công'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.of(context).pop();
        }).catchError((_) {
          const snackBar = SnackBar(
            content: Text('Đăng ký thất bại'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      } else {
        const snackBar = SnackBar(
          content: Text('Tài khoản tồn tại'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<void> onRotate() async {
    if (isAuth) {
      assetsAudioPlayer.play();
      String activeAwards = currentUser['activeAwards'];
      if (currentUser['turn'] > 0) {
        setState(() {
          currentUser['turn']--;
        });
        Random random = Random();
        int randomNumber = 0;
        if (activeAwards.isEmpty) {
          randomNumber = random.nextInt(awards.length);
        } else {
          do {
            randomNumber = random.nextInt(awards.length);
          } while (!activeAwards.contains('$randomNumber'));
        }
        controller.sink.add(randomNumber);

        String message = awards[randomNumber]['name'];
        int turn = awards[randomNumber]['turn'];
        updateHistories(message, turn);
        await Future.delayed(const Duration(seconds: timeRotate), () {
          showResultDialog(message);
          assetsAudioPlayer.stop();
        });
      } else {
        const snackBar = SnackBar(
          content: Text('Tài khoản hết lượt quay'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      const snackBar = SnackBar(
        content: Text('Vui lòng đăng ký hoặc đăng nhập để nhận thưởng'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> onLogout() async {
    setState(() {
      isAuth = false;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    const snackBar = SnackBar(
      content: Text('Đăng xuất thành công'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    init();
    readAwards();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      showWelcomeDialog();
    });
  }

  Future<void> init() async {
    assetsAudioPlayer.open(
      Audio.file(audioUri),
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool localIsAuth = prefs.getBool('isAuth') ?? false;
    if (prefs.getString('currentUser') != null) {
      dynamic localCurrentUser = jsonDecode(prefs.getString('currentUser')!);
      List<DocumentSnapshot> docs = (await firestore
              .collection('user')
              .where('username', '==', localCurrentUser['username'])
              .get())
          .docs;
      if (docs.isNotEmpty) {
        setState(() {
          isAuth = localIsAuth;
          currentUser = docs[0].data();
          histories = currentUser['histories'];
        });
      } else {
        await prefs.clear();
        setState(() {
          isAuth = false;
          currentUser = null;
          histories.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: AppOrientation(
          children: [
            Expanded(
                child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.height * 0.8,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: loading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : FortuneWheel(
                          duration: const Duration(seconds: timeRotate),
                          selected: controller.stream,
                          indicators: const <FortuneIndicator>[
                            FortuneIndicator(
                              alignment: Alignment.topCenter,
                              child: TriangleIndicator(
                                color: Colors.black,
                              ),
                            ),
                          ],
                          items: awards
                              .map((e) => FortuneItem(
                                    child: Text(
                                      e['name'],
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                    style: FortuneItemStyle(
                                      color: HexColor.fromHex(e['color']),
                                      borderColor: Colors.white,
                                      borderWidth: 3,
                                    ),
                                  ))
                              .toList(),
                        ),
                ),
                GestureDetector(
                  onTap: onRotate,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'Quay',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            )),
            Expanded(
                child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Image.asset(
                    imageUri,
                    width: 100,
                    height: 100,
                  ),
                ),
                !isAuth
                    ? Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                                'Vui lòng đăng ký hoặc đăng nhập để nhận thưởng',
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 40,
                            child: ElevatedButton(
                                onPressed: showLoginDialog,
                                child: const Text('Đăng nhập')),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 40,
                            child: ElevatedButton(
                                onPressed: showRegisterDialog,
                                child: const Text('Đăng ký')),
                          )
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text('Xin chào ',
                                                  style:
                                                      TextStyle(fontSize: 18)),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 4),
                                                child: Text(
                                                  '${currentUser?['username']}',
                                                  style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text('Bạn có ',
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 4),
                                                  child: Text(
                                                    '${currentUser?['turn']}',
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.blue),
                                                  ),
                                                ),
                                                const Text(' lượt quay',
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: ElevatedButton(
                                            onPressed: showHistoryDialog,
                                            child: const Text('Xem quà')),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 40,
                            child: ElevatedButton(
                                onPressed: onLogout,
                                child: const Text('Đăng xuất')),
                          )
                        ],
                      ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Future<void> showHistoryDialog() async {
    showDialog(
        context: context,
        builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Quà đã nhận',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: histories
                            .map((e) => Card(
                                elevation: 5, child: ListTile(title: Text(e))))
                            .toList(),
                      )),
                    ),
                  ],
                ),
              ),
            )));
  }

  Future<void> showLoginDialog() async {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              controller: loginUsernameController,
                              decoration: const InputDecoration(
                                hintText: 'Tên đăng nhập',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 40,
                            child: ElevatedButton(
                                onPressed: onLogin,
                                child: const Text('Đăng nhập')),
                          )
                        ]),
                  )),
            ));
  }

  Future<void> showRegisterDialog() async {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              controller: registerPhoneController,
                              decoration: const InputDecoration(
                                hintText: 'Số điện thoại',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              controller: registerUsernameController,
                              decoration: const InputDecoration(
                                hintText: 'Tên đăng nhập',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 40,
                            child: ElevatedButton(
                                onPressed: onRegister,
                                child: const Text('Đăng ký')),
                          )
                        ]),
                  )),
            ));
  }

  Future<void> showWelcomeDialog() async {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text('Chào mừng bạn',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                              'Vui lòng liên hệ Admin nếu bạn cần trợ giúp $adminContact',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center),
                          const SizedBox(
                            height: 40,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 40,
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Đồng ý')),
                          )
                        ]),
                  )),
            ));
  }

  Future<void> showResultDialog(String message) async {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'Chúc mừng bạn',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(message,
                              style: const TextStyle(fontSize: 18),
                              textAlign: TextAlign.center),
                          const SizedBox(
                            height: 40,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 40,
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Đồng ý')),
                          )
                        ]),
                  )),
            ));
  }
}
