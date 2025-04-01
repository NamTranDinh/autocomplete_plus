import 'package:autocomplete_plus/models/menu_item_type.dart';

class MockPostModel extends MenuItemType{
  MockPostModel({
    this.userId,
    this.id,
    this.title,
    this.body,
  });

  MockPostModel.fromJson(dynamic json) {
    userId = json['userId'];
    id = json['id'];
    title = json['title'];
    body = json['body'];
  }

  int? userId;
  int? id;
  String? title;
  String? body;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['userId'] = userId;
    map['id'] = id;
    map['title'] = title;
    map['body'] = body;
    return map;
  }

  @override
  String itemCode() {
    return id.toString();
  }

  @override
  String itemName() {
    return title.toString();
  }
}
