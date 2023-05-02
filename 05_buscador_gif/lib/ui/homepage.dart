import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:convert';

import 'gifPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;
    if (_search?.isEmpty ?? true) {
      response = await http.get(
          'https://api.giphy.com/v1/gifs/trending?api_key=1EnbWx2pqT1vdOp6P9yVy90zpFRFYUAt&limit=20&rating=g');
    } else {
      response = await http.get(
          'https://api.giphy.com/v1/gifs/search?api_key=1EnbWx2pqT1vdOp6P9yVy90zpFRFYUAt&q=$_search&limit=19&offset=$_offset&rating=g&lang=en');
    }

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Pesquise Aqui',
                    labelStyle: TextStyle(
                      color: Colors.white,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                  onSubmitted: (value) {
                    setState(() {
                      _search = value;
                    });
                  }),
            ),
            Expanded(
              child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 5),
                      );
                      break;
                    default:
                      if (snapshot.hasError)
                        return Container();
                      else
                        return _creatGifTable(context, snapshot);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCount(List data) {
    if (_search?.isEmpty ?? true)
      return data.length;
    else
      return data.length + 1;
  }

  Widget _creatGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _getCount(snapshot.data['data']),
      itemBuilder: (context, index) {
        if ((_search?.isEmpty ?? true) || index < snapshot.data['data'].length)
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data['data'][index]['images']['fixed_height']
                  ['url'],
              height: 300,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GifPage(snapshot.data['data'][index]),
                ),
              );
            },
            onLongPress: () {
              Share.share(
                snapshot.data['data'][index]['images']['fixed_height']['url'],
              );
            },
          );
        else
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70,
                  ),
                  Text(
                    'Carregar mais...',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  _offset += 19;
                });
              },
            ),
          );
      },
    );
  }
}

/*
trending
https://api.giphy.com/v1/gifs/trending?api_key=1EnbWx2pqT1vdOp6P9yVy90zpFRFYUAt&limit=20&rating=g

Search dogs
https://api.giphy.com/v1/gifs/search?api_key=1EnbWx2pqT1vdOp6P9yVy90zpFRFYUAt&q=dogs&limit=25&offset=25&rating=g&lang=en
*/
