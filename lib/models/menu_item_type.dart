abstract class MenuItemType {
  String itemCode();

  String itemName();

  Map<String, dynamic> toJson() => {
        'itemCode': itemCode(),
        'itemName': itemName(),
      };

  @override
  String toString() => 'MenuItemValue{ ${itemCode()} - ${itemName()} }';
}
