import 'package:my_app/constants/db.dart';
import 'package:my_app/db/todo_schema.dart';
import 'package:sqflite/sqflite.dart';

class TodoRepository {
  final Database db;

  TodoRepository(this.db);

  Future<List<Todo>> readTodoList() async {
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (index) {
      return Todo(
          id: maps[index]['id'],
          todoText: maps[index]['todoText'],
          isDone: maps[index]['isDone']);
    });
  }

  Future<void> addTodo(Todo todo) async {
    await db.insert(tableName, todo.toMap());
  }

  Future<void> deleteTodo(int id) async {
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateTodoStatus(Todo todo) async {
    await db.update(
      tableName,
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }
}
