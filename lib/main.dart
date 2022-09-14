import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'model/model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(),
          primarySwatch: Colors.blue,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String title = '';
  String description = '';
  String isbn = '';
  late Future<List<Book>> myData;
  @override
  void initState() {
    myData = getData();
    super.initState();
  }

  Future<List<Book>> getData() async {
    var response =
        await http.get(Uri.parse("http://127.0.0.1:3000/api/v1/books"));

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => Book.fromJson(data)).toList();
    } else {
      throw Exception("Something wrong happenned");
    }
  }

  Future<http.Response> createBook(
      String title, String description, String isbn) async {
    var response = await http.post(
      Uri.parse('http://127.0.0.1:3000/api/v1/books/create-book'),
      headers: <String, String>{
        'Content-Type': "application/json; charset=UTF-8"
      },
      body: jsonEncode(<String, dynamic>{
        "isbn": isbn,
        "name": title,
        "description": title,
      }),
    );
    return response;
  }

  Future<http.Response> deleteBook(String id) async {
    var response = await http
        .delete(Uri.parse("http://127.0.0.1:3000/api/v1/book/delete-book/$id"));
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books for Gophers'),
        actions: [
          IconButton(
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: const Text('Enter Book Details'),
                        content: Column(
                          children: [
                            SizedBox(
                                height: 45,
                                child: CupertinoTextField(
                                  onChanged: (val) {
                                    setState(() {
                                      title = val;
                                    });
                                  },
                                  placeholder: 'Title',
                                  decoration: const BoxDecoration(),
                                )),
                            SizedBox(
                                height: 45,
                                child: CupertinoTextField(
                                  onChanged: (val) {
                                    description = val;
                                  },
                                  placeholder: 'Description',
                                  decoration: const BoxDecoration(),
                                )),
                            SizedBox(
                                height: 45,
                                child: CupertinoTextField(
                                  onChanged: (val) {
                                    isbn = val;
                                  },
                                  placeholder: 'ISBN',
                                  decoration: const BoxDecoration(),
                                )),
                          ],
                        ),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                if (title != '' ||
                                    description != '' ||
                                    isbn != '') {
                                  await createBook(title, description, isbn);
                                } else {
                                  Navigator.of(context).pop();
                                }
                                setState(() {
                                  myData = getData();
                                });

                                Navigator.of(context).pop();
                              },
                              child: const Text("Ok"))
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: FutureBuilder<List<Book>>(
          future: myData,
          builder: ((context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    key: ValueKey(snapshot.data![index]),
                    trailing: IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: const Text('Are you sure to delete?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () async {
                                          await deleteBook(
                                              snapshot.data![index].id);
                                          setState(() {
                                            myData = getData();
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Ok'))
                                  ],
                                );
                              });
                        },
                        icon: const Icon(CupertinoIcons.trash)),
                    onLongPress: () {},
                    onTap: (() {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              content: Text(
                                snapshot.data![index].description,
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          });
                    }),
                    leading: const CircleAvatar(
                      child: Icon(CupertinoIcons.book),
                    ),
                    title: Text(snapshot.data![index].isbn),
                    subtitle: Text(snapshot.data![index].name),
                  );
                });
          })),
    );
  }
}
