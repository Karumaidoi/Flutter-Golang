class Book {
  late String id;
  late String name;
  late String isbn;
  late String description;

  Book(
      {required this.id,
      required this.isbn,
      required this.name,
      required this.description});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
        id: json["ID"],
        isbn: json["Name"],
        name: json["ISBN"],
        description: json['Description']);
  }
}
