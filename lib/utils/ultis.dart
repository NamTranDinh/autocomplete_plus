import 'dart:async';

import 'package:flutter/material.dart';
import 'package:autocomplete_plus/utils/callback_mananger.dart';
import 'package:autocomplete_plus/models/menu_item_type.dart';

/// Represents the decoration of the AutocompletePlus widget.
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

  /// The text to display as the label for the field.
  final String? label;

  /// The widget to display as the label for the field.
  final Widget? labelWidget;

  /// The text to display as the hint for the field.
  final String? hintText;

  /// The widget to display as the suffix icon for the field.
  final Widget? suffixIcon;

  /// The widget to display as the prefix icon for the field.
  final Widget? prefixIcon;

  /// The maximum height of the dropdown.
  final double dropDownMaxHeight;

  /// The border to display when the field is not focused.
  final InputBorder? border;

  /// The border to display when the field is enabled.
  final InputBorder? enabledBorder;

  /// The border to display when the field has an error.
  final InputBorder? errorBorder;

  /// The border to display when the field has an error and is focused.
  final InputBorder? focusedErrorBorder;

  /// The border to display when the field is focused.
  final InputBorder? focusedBorder;

  /// The border to display when the field is disabled.
  final InputBorder? disabledBorder;
}

/// Callback function for item selection.
typedef ItemCallback<T> = void Function(T item)?;

/// Callback function to get data for the autocomplete widget.
typedef GetDataCallback<T> = Future<List<T>> Function(int pageNo, int pageSize, String? keyword);

/// Callback function to build the options for the autocomplete widget.
typedef AutocompleteOptionsBuilder<T extends Object> = FutureOr<Iterable<T>> Function(
  TextEditingValue textEditingValue,
);

/// Callback function when an option is selected.
typedef AutocompleteOnSelected<T extends Object> = void Function(T option);

/// Callback function to build the view for the options.
typedef AutocompleteOptionsViewBuilder<T extends Object> = Widget Function(
  BuildContext context,
  AutocompleteOnSelected<T> onSelected,
  Iterable<T> options,
);

/// Callback function to build the view for the field.
typedef AutocompleteFieldViewBuilder = Widget Function(
  BuildContext context,
  TextEditingController textEditingController,
  FocusNode focusNode,
  VoidCallback onFieldSubmitted,
);

/// Callback function to convert an option to a string.
typedef AutocompleteOptionToString<T extends Object> = String Function(
  T option,
);

/// Callback manager for the AutocompletePlus widget.
typedef AutoCompletePlusCallBacks<T extends MenuItemType> = CallbackManager<T>;

/// Enum for the direction in which the options view opens.
/// [up] - Opens above the field.
/// [down] - Opens below the field.
enum OptionsViewOpenDirection { up, down }

/// Enum for page actions.
/// [refresh] - Refreshes the data.
/// [disable] - Disables the pagination.
enum PageActions { refresh, disable }
