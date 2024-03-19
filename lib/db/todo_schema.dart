class Todo {
  int? id;
  String todoText;
  int isDone;

  Todo({this.id, required this.todoText, this.isDone = 0});

  Map<String, dynamic> toMap() {
    return {"id": id, "todoText": todoText, "isDone": isDone};
  }

  Todo copyWith({int? id, String? todoText, int? isDone}) {
    return Todo(
        id: id ?? this.id,
        todoText: todoText ?? this.todoText,
        isDone: isDone ?? this.isDone);
  }
}
