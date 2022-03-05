import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quaythuongadmin/config.dart';
import 'package:string_validator/string_validator.dart';
import 'package:uuid/uuid.dart';

class SubView2 extends StatefulWidget {
  const SubView2({Key? key}) : super(key: key);

  @override
  _SubView2State createState() => _SubView2State();
}

class _SubView2State extends State<SubView2> {
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController(text: '#');
  TextEditingController controller3 = TextEditingController(text: '0');
  bool loading = false;
  Firestore firestore = firebase.firestore();
  Uuid uuid = const Uuid();

  List<dynamic> data = [];

  Future<void> create() async {
    if (controller1.text.trim().isEmpty ||
        isHexadecimal(controller2.text.trim()) ||
        controller3.text.trim().isEmpty) {
      const snackBar = SnackBar(
        content: Text('Không được trống'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      CollectionReference ref = firestore.collection('award');
      ref.doc().set({
        'id': uuid.v4(),
        'name': controller1.text.trim(),
        'color': controller2.text.trim(),
        'turn': int.parse(controller3.text.trim()),
      }).then((_) {
        controller1.clear();
        controller2.text = '#';
        controller3.text = '0';

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
    }
  }

  Future<void> read() async {
    setState(() {
      loading = true;
    });
    data.clear();
    CollectionReference ref = firestore.collection('award');
    (await ref.get()).docs.forEach((element) {
      data.add({
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

  Future<void> update(String id, String key, dynamic newValue) async {
    firestore
        .collection('award')
        .where('id', '==', id)
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

  Future<void> delete(String id) async {
    firestore
        .collection('award')
        .where('id', '==', id)
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
                              controller: controller1,
                              decoration: const InputDecoration(
                                labelText: 'Tên',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: controller2,
                            decoration: const InputDecoration(
                              labelText: 'Màu',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              controller: controller3,
                              decoration: const InputDecoration(
                                labelText: 'Tăng lượt quay',
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
                        itemBuilder: (context, index) => SubItem2(
                                index,
                                data[index]['name'],
                                data[index]['color'],
                                data[index]['turn'], (value) {
                              update(data[index]['id'], 'name', value);
                            }, (value) {
                              update(data[index]['id'], 'color', value);
                            }, (value) {
                              update(
                                  data[index]['id'], 'turn', int.parse(value));
                            }, () {
                              delete(data[index]['id']);
                            })),
                  ),
                ],
              ));
  }
}

class SubItem2 extends StatefulWidget {
  final int index;
  final String name;
  final String color;
  final int turn;
  final Function(String) onUpdate1;
  final Function(String) onUpdate2;
  final Function(String) onUpdate3;
  final Function() onDelete;

  const SubItem2(this.index, this.name, this.color, this.turn, this.onUpdate1,
      this.onUpdate2, this.onUpdate3, this.onDelete,
      {Key? key})
      : super(key: key);

  @override
  _SubItem2State createState() => _SubItem2State();
}

class _SubItem2State extends State<SubItem2> {
  late TextEditingController controller1;
  late TextEditingController controller2;
  late TextEditingController controller3;

  @override
  void initState() {
    super.initState();
    controller1 = TextEditingController(text: widget.name);
    controller2 = TextEditingController(text: widget.color);
    controller3 = TextEditingController(text: '${widget.turn}');
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${widget.index}',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: HexColor.fromHex(widget.color)),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    TextField(
                      controller: controller1,
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          labelText: 'Tên',
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextField(
                        controller: controller2,
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            labelText: 'Màu',
                            border: const OutlineInputBorder(),
                            suffixIcon: InkWell(
                              child: const Icon(Icons.check),
                              onTap: () {
                                if (isHexadecimal(controller2.text.trim())) {
                                  widget.onUpdate2(controller2.text.trim());
                                }
                              },
                            )),
                      ),
                    ),
                    TextField(
                      controller: controller3,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          labelText: 'Tăng lượt quay',
                          border: const OutlineInputBorder(),
                          suffixIcon: InkWell(
                            child: const Icon(Icons.check),
                            onTap: () {
                              if (controller3.text.isNotEmpty) {
                                widget.onUpdate3(controller3.text.trim());
                              }
                            },
                          )),
                    ),
                  ],
                ),
              ),
              Expanded(flex: 2, child: Container()),
              IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        ));
  }
}
