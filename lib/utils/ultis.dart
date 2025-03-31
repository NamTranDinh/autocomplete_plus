import 'dart:async';

import 'package:flutter/material.dart';
import 'package:autocomplete_plus/models/callback_mananger.dart';
import 'package:autocomplete_plus/models/menu_item_type.dart';

class AutocompletePlusDecoration {
  AutocompletePlusDecoration({
    this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.label,
    this.labelWidget,
    this.dropDownMaxHeight = 245,
    this.border,
    this.enabledBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.focusedBorder,
    this.disabledBorder,
  });

  final String? label;
  final Widget? labelWidget;
  final String? hintText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final double dropDownMaxHeight;

  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final InputBorder? focusedBorder;
  final InputBorder? disabledBorder;
}

typedef ItemCallback<T> = void Function(T item)?;

typedef GetDataCallback<T> = Future<List<T>> Function();

typedef AutocompleteOptionsBuilder<T extends Object> = FutureOr<Iterable<T>> Function(
    TextEditingValue textEditingValue);

typedef AutocompleteOnSelected<T extends Object> = void Function(T option);

typedef AutocompleteOptionsViewBuilder<T extends Object> = Widget Function(
  BuildContext context,
  AutocompleteOnSelected<T> onSelected,
  Iterable<T> options,
);

typedef AutocompleteFieldViewBuilder = Widget Function(
  BuildContext context,
  TextEditingController textEditingController,
  FocusNode focusNode,
  VoidCallback onFieldSubmitted,
);

typedef AutocompleteOptionToString<T extends Object> = String Function(
  T option,
);

typedef AutoCompletePlusCallBacks<T extends MenuItemType> = CallbackManager<T>;

enum OptionsViewOpenDirection { up, down }
