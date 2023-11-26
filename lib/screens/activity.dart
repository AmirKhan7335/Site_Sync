

class Activity {
  String id;
  String name;
  String startDate;
  String finishDate;
  int order;

  Activity({
    this.id = '',
    required this.name,
    required this.startDate,
    required this.finishDate,
    required this.order,
  });
}