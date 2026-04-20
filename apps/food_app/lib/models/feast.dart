class Feast {
  const Feast({
    required this.id,
    required this.restaurantName,
    required this.dishNames,
    required this.diningDateIso,
    required this.numberOfPeople,
    required this.cost,
    this.imagePath,
  });

  final String id;
  final String restaurantName;
  final String dishNames;
  final String diningDateIso;
  final int numberOfPeople;
  final double cost;
  final String? imagePath;

  DateTime get diningDate => DateTime.tryParse(diningDateIso) ?? DateTime.now();

  Feast copyWith({
    String? restaurantName,
    String? dishNames,
    String? diningDateIso,
    int? numberOfPeople,
    double? cost,
    String? imagePath,
  }) {
    return Feast(
      id: id,
      restaurantName: restaurantName ?? this.restaurantName,
      dishNames: dishNames ?? this.dishNames,
      diningDateIso: diningDateIso ?? this.diningDateIso,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      cost: cost ?? this.cost,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  static Feast fromJson(Map<String, dynamic> json) {
    return Feast(
      id: (json['id'] ?? '').toString(),
      restaurantName: (json['restaurantName'] ?? '').toString(),
      dishNames: (json['dishNames'] ?? '').toString(),
      diningDateIso: (json['diningDateIso'] ?? '').toString(),
      numberOfPeople: (json['numberOfPeople'] ?? 1) is int
          ? json['numberOfPeople'] as int
          : int.tryParse((json['numberOfPeople'] ?? '1').toString()) ?? 1,
      cost: (json['cost'] ?? 0) is num
          ? (json['cost'] as num).toDouble()
          : double.tryParse((json['cost'] ?? '0').toString()) ?? 0,
      imagePath: (json['imagePath'] ?? '').toString().isEmpty
          ? null
          : (json['imagePath'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'restaurantName': restaurantName,
    'dishNames': dishNames,
    'diningDateIso': diningDateIso,
    'numberOfPeople': numberOfPeople,
    'cost': cost,
    'imagePath': imagePath ?? '',
  };
}
