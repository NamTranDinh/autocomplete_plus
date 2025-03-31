import 'package:flutter/material.dart';
import 'package:autocomplete_plus/models/menu_item_type.dart';
import 'package:autocomplete_plus/utils/ultis.dart';

class CallbackManager<T extends MenuItemType> {
  CallbackManager({
    this.onItemSelected,
    this.onFieldSubmit,
    this.onItemDeleted,
    this.onChanged,
    this.onTapOutSide,
  });

  ItemCallback<T> onItemSelected;
  ItemCallback<T> onFieldSubmit;
  void Function()? onItemDeleted;
  void Function(String value)? onChanged;
  Function(PointerDownEvent event)? onTapOutSide;
}
