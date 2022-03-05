import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SubView1 extends StatefulWidget {
  const SubView1({Key? key}) : super(key: key);

  @override
  _SubView1State createState() => _SubView1State();
}

class _SubView1State extends State<SubView1> {
  TextEditingController controller = TextEditingController();
  bool loading = false;
  Firestore firestore = firebase.firestore();

  List<dynamic> data = [];

  Future<void> create() async {
    if (controller.text.trim().isEmpty) {
      const snackBar = SnackBar(
        content: Text('Không được trống'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      CollectionReference ref = firestore.collection('user');
      if ((await firestore
              .collection('user')
              .where('username', '==', controller.text.trim())
              .get())
          .docs
          .isEmpty) {
        ref.doc().set({
          'username': controller.text.trim(),
          'phone': '',
          'turn': 0,
          'activeAwards': '',
          'histories': ['']
        }).then((_) {
          controller.clear();
          const snackBar = SnackBar(
            content: Text('Thêm thành công'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          read();
        }).catchError((_) {
          const snackBar = SnackBar(
            content: Text('Thêm thất bại'),
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

  Future<void> read() async {
    setState(() {
      loading = true;
    });
    data.clear();
    CollectionReference ref = firestore.collection('user');
    (await ref.get()).docs.forEach((element) {
      data.add({
        'username': element.data()['username'],
        'phone': element.data()['phone'],
        'turn': element.data()['turn'],
        'activeAwards': element.data()['activeAwards'],
        'histories': element.data()['histories'] ?? ['']
      });
    });
    setState(() {
      loading = false;
    });
  }

  Future<void> update(String username, String key, dynamic newValue) async {
    firestore
        .collection('user')
        .where('username', '==', username)
        .get()
        .then((value) => value
            .forEach((p0) => p0.ref.update(data: {key: newValue}).then((_) {
                  const snackBar = SnackBar(
                    content: Text('Sửa thành công'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  read();
                })))
        .catchError((_) {
      const snackBar = SnackBar(
        content: Text('Sửa thất bại'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  Future<void> delete(String username) async {
    firestore
        .collection('user')
        .where('username', '==', username)
        .get()
        .then((value) => value.forEach((p0) => p0.ref.delete().then((_) {
              const snackBar = SnackBar(
                content: Text('Xoá thành công'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              read();
            })))
        .catchError((_) {
      const snackBar = SnackBar(
        content: Text('Xoá thất bại'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  void initState() {
    super.initState();
    read();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: loading
            ? const SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Center(child: CircularProgressIndicator()))
            : Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                hintText: 'Tên đăng nhập',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Center(
                                child: ElevatedButton(
                                    onPressed: create,
                                    child: const Text('Tạo'))))
                      ],
                    ),
                  ),
                  Expanded(
                      child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) => SubItem1(
                                  data[index]['username'],
                                  data[index]['phone'],
                                  data[index]['turn'],
                                  data[index]['activeAwards'],
                                  (data[index]['histories'] as List).last,
                                  (value) {
                                update(data[index]['username'], 'turn',
                                    int.parse(value));
                              }, (value) {
                                update(data[index]['username'], 'activeAwards',
                                    value);
                              }, () {
                                delete(data[index]['username']);
                              })))
                ],
              ));
  }
}

class SubItem1 extends StatefulWidget {
  final String username;
  final String phone;
  final int turn;
  final String activeAwards;
  final String lastAward;
  final Function(String) onUpdate1;
  final Function(String) onUpdate2;
  final Function() onDelete;

  const SubItem1(this.username, this.phone, this.turn, this.activeAwards,
      this.lastAward, this.onUpdate1, this.onUpdate2, this.onDelete,
      {Key? key})
      : super(key: key);

  @override
  _SubItem1State createState() => _SubItem1State();
}

class _SubItem1State extends State<SubItem1> {
  late TextEditingController controller1;
  late TextEditingController controller2;

  @override
  void initState() {
    super.initState();
    controller1 = TextEditingController(text: '${widget.turn}');
    controller2 = TextEditingController(text: widget.activeAwards);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.username,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'SĐT: ${widget.phone}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  controller: controller1,
                  decoration: InputDecoration(
                      labelText: 'Lượt quay',
                      border: const OutlineInputBorder(),
                      suffixIcon: InkWell(
                        child: const Icon(Icons.check),
                        onTap: () {
                          if (controller1.text.isNotEmpty) {
                            widget.onUpdate1(controller1.text.trim());
                          }
                        },
                      )),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: controller2,
                  decoration: InputDecoration(
                      labelText: 'Cho phép quay',
                      border: const OutlineInputBorder(),
                      suffixIcon: InkWell(
                        child: const Icon(Icons.check),
                        onTap: () {
                          if (controller2.text.isNotEmpty) {
                            widget.onUpdate2(controller2.text.trim());
                          }
                        },
                      )),
                ),
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                enabled: false,
                controller: TextEditingController(text: widget.lastAward),
                decoration: const InputDecoration(
                    labelText: 'Giải thưởng', border: OutlineInputBorder()),
              ),
            )),
            IconButton(
              onPressed: widget.onDelete,
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
