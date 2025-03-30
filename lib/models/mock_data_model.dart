import 'package:autocomplete_plus/models/menu_item_type.dart';

/// id : 1
/// countryName : "United States"
/// countryCode : "US"
/// population : 331002651
/// capital : "Washington, D.C."

class MockDataModel extends MenuItemType{
  MockDataModel({
    this.id,
    this.countryName,
    this.countryCode,
    this.population,
    this.capital,
  });

  MockDataModel.fromJson(dynamic json) {
    id = json['id'];
    countryName = json['countryName'];
    countryCode = json['countryCode'];
    population = json['population'];
    capital = json['capital'];
  }

  num? id;
  String? countryName;
  String? countryCode;
  num? population;
  String? capital;

  MockDataModel copyWith({
    num? id,
    String? countryName,
    String? countryCode,
    num? population,
    String? capital,
  }) =>
      MockDataModel(
        id: id ?? this.id,
        countryName: countryName ?? this.countryName,
        countryCode: countryCode ?? this.countryCode,
        population: population ?? this.population,
        capital: capital ?? this.capital,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['countryName'] = countryName;
    map['countryCode'] = countryCode;
    map['population'] = population;
    map['capital'] = capital;
    return map;
  }


  static List<MockDataModel> mockData() {
    return [
      {"id": 1, "countryName": "United States", "countryCode": "US", "population": 331002651, "capital": "Washington, D.C."},
      {"id": 2, "countryName": "Canada", "countryCode": "CA", "population": 37742154, "capital": "Ottawa"},
      {"id": 3, "countryName": "United Kingdom", "countryCode": "GB", "population": 67886011, "capital": "London"},
      {"id": 4, "countryName": "Australia", "countryCode": "AU", "population": 25499884, "capital": "Canberra"},
      {"id": 5, "countryName": "Germany", "countryCode": "DE", "population": 83783942, "capital": "Berlin"},
      {"id": 6, "countryName": "France", "countryCode": "FR", "population": 65273511, "capital": "Paris"},
      {"id": 7, "countryName": "Japan", "countryCode": "JP", "population": 126476461, "capital": "Tokyo"},
      {"id": 8, "countryName": "India", "countryCode": "IN", "population": 1380004385, "capital": "New Delhi"},
      {"id": 9, "countryName": "Brazil", "countryCode": "BR", "population": 212559417, "capital": "Brasília"},
      {"id": 10, "countryName": "South Africa", "countryCode": "ZA", "population": 59308690, "capital": "Pretoria"},
      {"id": 11, "countryName": "Italy", "countryCode": "IT", "population": 60244639, "capital": "Rome"},
      {"id": 12, "countryName": "Mexico", "countryCode": "MX", "population": 128932753, "capital": "Mexico City"},
      {"id": 13, "countryName": "Russia", "countryCode": "RU", "population": 145912025, "capital": "Moscow"},
      {"id": 14, "countryName": "Spain", "countryCode": "ES", "population": 46754778, "capital": "Madrid"},
      {"id": 15, "countryName": "Netherlands", "countryCode": "NL", "population": 17134872, "capital": "Amsterdam"},
      {"id": 16, "countryName": "Sweden", "countryCode": "SE", "population": 10099265, "capital": "Stockholm"},
      {"id": 17, "countryName": "Norway", "countryCode": "NO", "population": 5421241, "capital": "Oslo"},
      {"id": 18, "countryName": "Argentina", "countryCode": "AR", "population": 45195777, "capital": "Buenos Aires"},
      {"id": 19, "countryName": "Saudi Arabia", "countryCode": "SA", "population": 34813867, "capital": "Riyadh"},
      {"id": 20, "countryName": "Turkey", "countryCode": "TR", "population": 84339067, "capital": "Ankara"}
    ].map((e) => MockDataModel.fromJson(e)).toList();
  }

  @override
  String itemCode() {
    return countryCode ?? '';
  }

  @override
  String itemName() {
    return countryName?? '';
  }
}
