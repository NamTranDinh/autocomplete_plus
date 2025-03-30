/// itemCode : "itemCode"
/// itemName : "itemName"

abstract class MenuItemType {
  String itemCode();

  String itemName();

  @override
  String toString() => 'MenuItemValue{ ${itemCode()} - ${itemName()}';
}
