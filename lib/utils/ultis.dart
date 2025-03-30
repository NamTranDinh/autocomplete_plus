import 'dart:async';

import 'package:flutter/material.dart';

typedef GetDataCallback<T> = Future<List<T>> Function();

typedef AutocompleteOptionsBuilder<T extends Object> = FutureOr<Iterable<T>>
    Function(TextEditingValue textEditingValue);

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

enum OptionsViewOpenDirection { up, down }
