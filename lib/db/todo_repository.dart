import 'dart:io';

import 'package:my_app/db/todo_schema.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class TodoRepository {
  static const _databaseName = "todo.db";
  static const _databaseVersion = 1;
  static const _tableName = "Todo";
  static const _columnId = "id";
  static const _columnTodoText = "todoText";
  static const _columnIsDone = "isDone";

  final Database db;

  TodoRepository(this.db);

  Future<List<Todo>> readTodoList() async {
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (index) {
      return Todo(
          id: maps[index]['id'],
          todoText: maps[index]['todoText'],
          isDone: maps[index]['isDone']);
    });
  }

  Future<void> addTodo(Todo todo) async {
    await db.insert(_tableName, todo.toMap());
  }

  Future<void> deleteTodo(int id) async {
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateTodoStatus(Todo todo) async {
    await db.update(
      _tableName,
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }
}
