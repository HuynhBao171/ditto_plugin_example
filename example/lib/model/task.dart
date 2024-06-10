class Task {
  final String? id;
  final String body;
  bool isCompleted;

  Task({
    required this.id,
    required this.body,
    required this.isCompleted,
  });

  factory Task.fromMap(Map<String, dynamic> documentData) {
    return Task(
      id: documentData['id'] as String?,
      body: documentData['body'] as String,
      isCompleted: documentData['isCompleted'] as bool,
    );
  }
}
