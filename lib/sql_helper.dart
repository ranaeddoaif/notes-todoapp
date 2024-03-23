import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Notes {
  final int? id;
  final String title;
  final String content;

  Notes({this.id, required this.title, required this.content});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'content': content};
  }
}

class Todo {
  final int? id;
  final String title;
  final int? value;

  Todo({this.id, required this.title, this.value=0});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'value': value};
  }
}

class SqlHelper {
  Database? database;

  Future getDatabase() async {
    if (database != null) return database;
    database = await iniDatabese();
    return database;
  }

  Future iniDatabese() async {
    String path = join(await getDatabasesPath(), 'gdsc_benha_2024.db');
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      Batch batch = db.batch();
      batch.execute('''
       CREATE TABLE notes(
       id INTEGER PRIMARY KEY,
       title TEXT,
       content TEXT
   )
      ''');

      batch.execute('''
       CREATE TABLE todo(
       id INTEGER PRIMARY KEY,
       title TEXT,
       value INTEGER
   )
      ''');
    });
  }

  Future insertNote(Notes note) async {
    Database db = await getDatabase();
    Batch batch = db.batch();
    batch.insert('notes', note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    batch.commit();
  }

  Future insertTodo(Todo todo) async {
    Database db = await getDatabase();
    Batch batch = db.batch();
    batch.insert('todo', todo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    batch.commit();
  }

  Future<List<Map>> loadNotes() async {
    Database db = await getDatabase();
    List<Map> maps = await db.query('notes');
    List<Map> generatedList = [];
    for (int i = 0; i < maps.length; i++) {
      Map<String, dynamic> generatedMap = {
        'id': maps[i]['id'],
        'title': maps[i]['title'],
        'content': maps[i]['content'],
      };
      generatedList.add(generatedMap);
    }
    return generatedList;
  }

  Future<List<Map>> loadTodo() async {
    Database db = await getDatabase();
    List<Map> maps = await db.query('todo');
    List<Map> generatedList = [];
    for (int i = 0; i < maps.length; i++) {
      Map<String, dynamic> generatedMap = {
        'id': maps[i]['id'],
        'title': maps[i]['title'],
        'value': maps[i]['value'],
      };
      generatedList.add(generatedMap);
    }
    return generatedList;
  }

  Future updateNote(Notes newnote) async {
    Database db = await getDatabase();
    await db.update(
      'notes',
      newnote.toMap(),
      where: 'id= ?',
      whereArgs: [newnote.id],
    );
  }

  Future updateTodoChecked(int id, int currentValue) async {
    Database db = await getDatabase();
    Map<String, dynamic> values = {
      'value': currentValue == 0 ? 1 : 0,
    };
    await db.update('todo', values, where: 'id= ?', whereArgs: [id]);
  }

  Future deleteAllNotes() async {
    Database db = await getDatabase();
    await db.delete('notes');
  }

  Future deleteAllTodo() async {
    Database db = await getDatabase();
    await db.delete('todo');
  }

  Future deleteNote(int id) async {
    Database db = await getDatabase();
    await db.delete(
      'notes',
      where: 'id= ?',
      whereArgs: [id],
    );
  }
}
