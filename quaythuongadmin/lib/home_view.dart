import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:quaythuongadmin/subview1.dart';
import 'package:quaythuongadmin/subview2.dart';
import 'package:quaythuongadmin/subview3.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Widget> subViews = [
    const SubView1(),
    const SubView2(),
    const SubView3()
  ];
  int currentIndex = 0;
  List<dynamic> items = [
    {'icon': Icons.person, 'text': 'Danh sách thành viên'},
    {'icon': Icons.wallet_giftcard, 'text': 'Giải thưởng'},
    {'icon': Icons.list_alt, 'text': 'Danh sách trao thưởng'},
    {'icon': Icons.exit_to_app, 'text': 'Đăng xuất'}
  ];

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isAuth = false;
  Firestore firestore = firebase.firestore();

  Future<void> onLogin() async {
    if (usernameController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      const snackBar = SnackBar(
        content: Text('Không được trống'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      CollectionReference ref = firestore.collection('admin');
      DocumentSnapshot doc = (await ref.get()).docs[0];
      if (usernameController.text.trim() != doc.data()['username']) {
        const snackBar = SnackBar(
          content: Text('Sai tên đăng nhập'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else if (passwordController.text.trim() != doc.data()['password']) {
        const snackBar = SnackBar(
          content: Text('Sai mật khẩu'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuth', true);
        setState(() {
          isAuth = true;
        });
      }
    }
  }

  Future<void> onLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      isAuth = false;
    });
  }

  Future<void> onClickTab(int index) async {
    if (index == 3) {
      await onLogout();
    } else {
      setState(() {
        currentIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isAuth = prefs.getBool('isAuth') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        backgroundColor: Colors.black,
      ),
      body: Row(
        children: [
          Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black87,
                child: SingleChildScrollView(
                  child: Column(
                    children: isAuth
                        ? Iterable<int>.generate(items.length)
                            .map((i) => ListTile(
                                  selected: currentIndex == i,
                                  iconColor: Colors.white,
                                  textColor: Colors.white,
                                  selectedColor: Colors.blue,
                                  onTap: () async {
                                    await onClickTab(i);
                                  },
                                  leading: Icon(items[i]['icon']),
                                  title: Text(items[i]['text']),
                                ))
                            .toList()
                        : [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: usernameController,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: 'Tên đăng nhập',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: 'Mật khẩu',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 16.0, left: 4, right: 4),
                              child: ElevatedButton(
                                  onPressed: onLogin,
                                  child: const Text('Đăng nhập')),
                            )
                          ],
                  ),
                ),
              )),
          Expanded(
              flex: 5,
              child: Container(
                color: Colors.black26,
                child: isAuth
                    ? subViews[currentIndex]
                    : const Center(
                        child: Text(
                          'Vui lòng đăng nhập để quản lý',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
              ))
        ],
      ),
    );
  }
}
