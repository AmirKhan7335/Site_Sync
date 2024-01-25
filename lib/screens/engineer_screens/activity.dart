class Activity {
  String id; // Unique identifier
  String name;
  String startDate; // Change the type to String
  String finishDate; // Change the type to String
  int order;
  String image;

  Activity({
    required this.id,
    required this.name,
    required this.startDate,
    required this.finishDate,
    required this.order,
    this.image='',
  });
}
