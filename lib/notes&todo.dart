import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_notes_app/sql_helper.dart';

class NotesTodo extends StatefulWidget {
  const NotesTodo({super.key});

  @override
  State<NotesTodo> createState() => _NotesTodoState();
}

class _NotesTodoState extends State<NotesTodo> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            SqlHelper().deleteAllNotes();
            SqlHelper().deleteAllTodo().whenComplete(() => setState((){}));
          },
              icon: Icon(
                  Icons.delete
              ))
        ],
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
                child: FutureBuilder(
                  future: SqlHelper().loadNotes(),
                  builder:
                      (BuildContext context,
                      AsyncSnapshot<List<Map>> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error');
                    }
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return Dismissible(
                                key: UniqueKey(),
                                onDismissed: (direction) {
                                  SqlHelper()
                                      .deleteNote(snapshot.data![index]['id']);
                                },
                                child: Card(
                                  color: Colors.blue,
                                  child: Column(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            showEditNoteDialog(
                                                context,
                                                snapshot.data![index]['title'],
                                                snapshot
                                                    .data![index]['content'],
                                                snapshot.data![index]['id']);
                                          },
                                          icon: Icon(Icons.edit)),
                                      Text(('Id : ') +
                                          (snapshot.data![index]['id'])),
                                      Text(('Title : ') +
                                          (snapshot.data![index]['title']).toString()),
                                      Text(('Content : ') +
                                          (snapshot.data![index]['content']).toString()),
                                    ],
                                  ),
                                ));
                          });
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                )
            ),
            Expanded(
                child: FutureBuilder(
                  future: SqlHelper().loadTodo(),
                  builder:
                      (BuildContext context,
                      AsyncSnapshot<List<Map>> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error');
                    }
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            bool isDone = snapshot.data![index]['value'] == 0
                                ? false
                                : true;
                            return Card(
                              color: Colors.greenAccent,
                              child: Row(
                                children: [
                                  Checkbox(
                                      value: isDone,
                                      onChanged: (bool? value) {
                                        SqlHelper()
                                            .updateTodoChecked(
                                            snapshot.data![index]['id'],
                                            snapshot.data![index]['value'])
                                            .whenComplete(() =>
                                            setState(() {}));

                                      }),
                                  Text('${(snapshot.data![index]['title'])}',
                                    style: TextStyle(color: isDone?Colors.white:Colors.black),
                                  ),
                                ],
                              ),
                            );
                          });
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                )
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: 'Increment',
            onPressed: () {
              showInsertNoteDialog(context);
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.blue,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal:  8.0),
            child: FloatingActionButton(
              tooltip: 'Increment',
              onPressed: () {
                showInsertTodoDialog(context);
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

  void showInsertNoteDialog(context) {
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return Material(
            color: Colors.white.withOpacity(0.3),
            child: CupertinoAlertDialog(
              title: Text('Add new Note'),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  child: Text('Yes'),
                  onPressed: () {
                    SqlHelper()
                        .insertNote(Notes(
                        title: titleController.text,
                        content: contentController.text))
                        .whenComplete(() => setState(() {}));
                    titleController.clear();
                    contentController.clear();
                    Navigator.pop(context);
                  },
                ),
              ],
              content: Column(
                children: [
                  TextField(
                    controller: titleController,
                  ),
                  TextField(
                    controller: contentController,
                  ),
                ],
              ),
            ),
          );
        });
  }

  void showEditNoteDialog(context, String titleinit, String contentInit,
      int id) {
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return Material(
            color: Colors.white.withOpacity(0.3),
            child: CupertinoAlertDialog(
              title: Text('Edit Note'),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  child: Text('Yes'),
                  onPressed: () {
                    SqlHelper()
                        .updateNote(Notes(
                        id: id,
                        title: titleinit,
                        content: contentInit))
                        .whenComplete(() => setState(() {}));
                    Navigator.pop(context);
                  },
                ),
              ],
              content: Column(
                children: [
                  TextFormField(
                    initialValue: titleinit,
                    onChanged:(value) {
                      titleinit = value;
                    },
                  ),
                  TextFormField(
                    initialValue: contentInit,
                    onChanged: (value){
                      contentInit = value;
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
  void showInsertTodoDialog(context) {
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return Material(
            color: Colors.white.withOpacity(0.3),
            child: CupertinoAlertDialog(
              title: Text('Add new To do'),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  child: Text('Yes'),
                  onPressed: () {
                    SqlHelper()
                        .insertTodo(Todo(
                        title: titleController.text,
                    ))
                        .whenComplete(() => setState(() {}));
                    titleController.clear();
                  },
                ),
              ],
              content: Column(
                children: [
                  TextField(
                    controller: titleController,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
