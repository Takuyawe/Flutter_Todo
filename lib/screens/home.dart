import "dart:io";

import "package:flutter/material.dart";
import "package:my_app/constants/colors.dart";
import "package:my_app/constants/db.dart";
import "package:my_app/db/todo_repository.dart";
import "package:my_app/db/todo_schema.dart";
import "package:my_app/widgets/todo_item.dart";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";
import "package:sqflite/sqflite.dart";

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TodoRepository? _todoRepository;
  List<Todo> _todoList = [];
  List<Todo> _foundTodo = [];
  final _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeTodoRepository();
  }

  Future<void> initializeTodoRepository() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, databaseName);
    Database database = await openDatabase(
      path,
      version: databaseVersion,
      onCreate: (Database db, int version) async {
        await db.execute('''
        CREATE TABLE $tableName (
          $columnId INTEGER PRIMARY KEY,
          $columnTodoText TEXT,
          $columnIsDone String
        )
      ''');
      },
    );
    _todoRepository = TodoRepository(database);
    print(database.isOpen);
    print("database, $database");
    _loadTodoList();
  }

  Future<void> _loadTodoList() async {
    _todoList = await _todoRepository!.readTodoList();
    setState(() {
      _foundTodo = _todoList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: tdBgColor,
          appBar: AppBar(
              backgroundColor: tdBgColor,
              title: Row(
                children: [
                  Icon(
                    Icons.menu,
                    color: tdBlack,
                    size: 30,
                  ),
                  Spacer(),
                  Container(
                      height: 40,
                      width: 40,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset("assets/images/profile.jpeg")))
                ],
              )),
          body: Stack(
            children: [
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(children: [
                    searchBox(),
                    Expanded(
                        child: ListView(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 50, bottom: 20),
                          child: Text(
                            "All Todos",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w500),
                          ),
                        ),
                        for (Todo todo in _foundTodo)
                          TodoItem(
                              todo: todo,
                              onTodoChanged: _handleTodoChange,
                              onDeleteItem: _deleteTodoItem)
                      ],
                    ))
                  ])),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      Expanded(
                          child: Container(
                        margin:
                            EdgeInsets.only(bottom: 20, right: 20, left: 20),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(0, 0),
                                  blurRadius: 10,
                                  spreadRadius: 0),
                            ],
                            borderRadius: BorderRadius.circular(10)),
                        child: TextField(
                          controller: _todoController,
                          decoration: InputDecoration(
                              hintText: "Add a new todo item",
                              border: InputBorder.none),
                        ),
                      )),
                      Container(
                        margin: EdgeInsets.only(bottom: 20, right: 20),
                        child: ElevatedButton(
                          child: Text("+",
                              style:
                                  TextStyle(fontSize: 40, color: Colors.white)),
                          onPressed: () {
                            _addTodoItem(_todoController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tdBlue,
                            minimumSize: Size(60, 60),
                            elevation: 10,
                          ),
                        ),
                      )
                    ],
                  ))
            ],
          ),
        ));
  }

  void _handleTodoChange(Todo todo) async {
    int newStatus = todo.isDone == 0 ? 1 : 0;
    Todo newTodo = todo.copyWith(isDone: newStatus);
    setState(() {
      todo.isDone = newStatus;
    });
    await _todoRepository?.updateTodoStatus(newTodo);
  }

  void _deleteTodoItem(int id) async {
    await _todoRepository?.deleteTodo(id);
    _loadTodoList();
  }

  void _addTodoItem(String todoText) async {
    Todo todo = Todo(todoText: todoText, isDone: 0);
    await _todoRepository?.addTodo(todo);
    _loadTodoList();
    _todoController.clear();
  }

  void _runFilter(String enteredText) {
    List<Todo> results = [];
    if (enteredText.isEmpty) {
      results = _todoList;
    } else {
      results = _todoList
          .where((item) =>
              item.todoText.toLowerCase().contains(enteredText.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundTodo = results;
    });
  }

  Widget searchBox() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: TextField(
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(0),
              prefixIcon: Icon(
                Icons.search,
                color: tdBlack,
                size: 20,
              ),
              prefixIconConstraints:
                  BoxConstraints(maxHeight: 20, minWidth: 25),
              border: InputBorder.none,
              hintText: "Search",
              hintStyle: TextStyle(color: tdGray)),
          onChanged: (enteredText) => _runFilter(enteredText),
        ));
  }
}
