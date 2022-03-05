import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';

class SubView3 extends StatefulWidget {
  const SubView3({Key? key}) : super(key: key);

  @override
  _SubView3State createState() => _SubView3State();
}

class _SubView3State extends State<SubView3> {
  bool loading = false;
  Firestore firestore = firebase.firestore();

  List<dynamic> data = [];

  Future<void> read() async {
    setState(() {
      loading = true;
    });
    data.clear();
    CollectionReference ref = firestore.collection('history');
    (await ref.orderBy('timestamp', 'asc').get()).docs.forEach((element) {
      data.add({
        'id': element.data()['id'],
        'username': element.data()['username'],
        'award': element.data()['award'],
      });
    });
    setState(() {
      loading = false;
    });
  }

  Future<void> delete(String id) async {
    firestore
        .collection('history')
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
            : ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) =>
                    SubItem3(data[index]['username'], data[index]['award'], () {
                      delete(data[index]['id']);
                    })));
  }
}

class SubItem3 extends StatelessWidget {
  final String username;
  final String award;
  final Function() onDelete;

  const SubItem3(this.username, this.award, this.onDelete, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: ListTile(
        title: Text(username),
        subtitle: Text(award),
        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete),
        ),
      ),
    );
  }
}
