import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(
    MaterialApp(
      home: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();

  List _toDoList = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(
                          color: Colors.blueAccent,
                        ),
                      ),
                      controller: _toDoController,
                    ),
                  ),
                  RaisedButton(
                    color: Colors.blueAccent,
                    onPressed: () {
                      _addToDo();
                    },
                    child: Text("ADD"),
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  itemCount: _toDoList.length,
                  itemBuilder: buildItem,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(context, index) {
    return Dismissible(
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            _toDoList[index]["ok"] = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        _lastRemoved = Map.from(_toDoList[index]);
        _lastRemovedPos = index;
        _toDoList.removeAt(index);
        setState(() {
          _saveData();
        });

        final snack = SnackBar(
          content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: () {
              _toDoList.insert(_lastRemovedPos, _lastRemoved);
              setState(() {
                _saveData();
              });
            },
          ),
          duration: Duration(
            seconds: 2,
          ),
        );
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(snack);
      },
    );
  }

  Future<Null> _refresh() async {
    await Future.delayed(
      Duration(seconds: 1),
    );

    _toDoList.sort((a, b) {
      if (a["ok"] && !b["ok"])
        return 1;
      else if (!a["ok"] && b["ok"])
        return -1;
      else
        return 0;
    });
    setState(() {
      _saveData();
    });
    return null;
  }

  void _addToDo() {
    Map<String, dynamic> newToDo = Map();

    newToDo["title"] = _toDoController.text;
    _toDoController.text = "";
    newToDo["ok"] = false;
    _toDoList.add(newToDo);
    setState(() {
      _saveData();
    });
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
