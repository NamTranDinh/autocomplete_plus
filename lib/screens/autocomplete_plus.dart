import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autocomplete_plus/models/menu_item_type.dart';
import 'package:autocomplete_plus/screens/app_raw_autocomplete.dart';
import 'package:autocomplete_plus/utils/debounce.dart';
import 'package:autocomplete_plus/utils/extensions.dart';
import 'package:autocomplete_plus/utils/helpers.dart';
import 'package:autocomplete_plus/utils/ultis.dart';

class AutocompletePlus<T extends MenuItemType> extends StatefulWidget {
  const AutocompletePlus({
    super.key,
    required this.getDataCallBack,
    required this.controller,
    this.itemSelected,
    this.decoration,
    this.validator,
    this.autoValidateMode,
    this.inputFormatters,
    this.callBacks,
  });

  final GetDataCallback<T> getDataCallBack;
  final T? itemSelected;
  final TextEditingController controller;
  final AutocompletePlusDecoration? decoration;

  final AutovalidateMode? autoValidateMode;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String? value)? validator;

  final AutoCompletePlusCallBacks<T>? callBacks;

  @override
  State<AutocompletePlus<T>> createState() => _AutocompletePlusState<T>();
}

class _AutocompletePlusState<T extends MenuItemType> extends State<AutocompletePlus<T>>
    with SingleTickerProviderStateMixin {
  final keyTextField = GlobalKey();
  final textFieldFocusNode = FocusNode();
  final _loadingNotifier = ValueNotifier<bool>(false);

  final List<T> data = [];
  late TextEditingController filterController;

  T? itemSelected;

  @override
  void initState() {
    itemSelected = widget.itemSelected;
    filterController = TextEditingController(text: widget.controller.text);
    getData();
    super.initState();
  }

  Future<void> getData() async {
    if (textFieldFocusNode.hasFocus) {
      _loadingNotifier.value = true;
    }
    if (kDebugMode) await Future.delayed(const Duration(seconds: 1));
    DebounceHelper().run(
      () async => widget.getDataCallBack.call().then(
            (value) => data
              ..clear()
              ..addAll(value),
          ),
    );
    if (textFieldFocusNode.hasFocus) {
      _loadingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (focusNode, event) {
        final data = _getOptionsFiltered();
        print(data.isEmpty);
        if (data.isEmpty) return KeyEventResult.ignored;

        final currentIndex = itemSelected != null ? data.indexOf(itemSelected!) : 0;

        if (currentIndex >= 0 && currentIndex < data.length - 1) {
          itemSelected = data[currentIndex + 1];
        }

        return KeyEventResult.ignored;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.decoration?.labelWidget != null || widget.decoration?.label != null)
            widget.decoration?.labelWidget ??
                Text(
                  widget.decoration?.label ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
          const SizedBox(height: 3),
          AppRawAutocomplete<T>(
            focusNode: textFieldFocusNode,
            textEditingController: widget.controller,
            onSelected: (option) {
              itemSelected = option;
              widget.callBacks?.onItemSelected?.call(option);
              filterController.clear();
              textFieldFocusNode.unfocus();
            },
            displayStringForOption: _displayStringForOption,
            optionsBuilder: (textEditingValue) async {
              if (textFieldFocusNode.hasFocus && data.isEmpty) {
                await getData();
              }

              return _getOptionsFiltered();
            },
            fieldViewBuilder: (context, ctl, focusNode, onFieldSubmitted) {
              return ValueListenableBuilder(
                valueListenable: _loadingNotifier,
                builder: (context, value, child) => _buildTextFormField(context, ctl, focusNode, onFieldSubmitted),
              );
            },
            optionsViewBuilder: buildOptionsViewBuilder,
          ),
        ],
      ),
    );
  }

  List<T> _getOptionsFiltered() => data.where(
        (option) {
          return option
              .itemName()
              .removeDiacritics
              .toLowerCase()
              .contains(filterController.text.removeDiacritics.toLowerCase());
        },
      ).toList();

  Widget buildOptionsViewBuilder(BuildContext context, Function(T option) onSelected, Iterable<T> options) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: widget.decoration?.dropDownMaxHeight ?? 245,
          maxWidth: AppHelpers.getSizeByKey(keyTextField).width,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: buildBoxDecoration(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Theme(
            data: ThemeData(scrollbarTheme: const ScrollbarThemeData(thickness: WidgetStatePropertyAll(2))),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: options.toList().length,
              itemBuilder: (context, index) {
                return OptionViewItem<T>(
                  key: ValueKey(itemSelected?.itemCode() ?? ''),
                  keyTextField: keyTextField,
                  option: options.toList()[index],
                  onSelected: (p0) => onSelected(p0),
                  itemSelected: itemSelected,
                );
              },
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: .5),
                child: Divider(
                  height: 1,
                  color: Theme.of(context).dividerColor.withValues(alpha: .1),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.withValues(alpha: .2)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.1),
          spreadRadius: 5,
          blurRadius: 13,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  TextFormField _buildTextFormField(
    BuildContext context,
    TextEditingController textEditingController,
    FocusNode focusNode,
    VoidCallback onFieldSubmitted,
  ) {
    return TextFormField(
      key: keyTextField,
      controller: textEditingController,
      focusNode: focusNode,
      validator: widget.validator,
      keyboardType: TextInputType.text,
      scrollPadding: const EdgeInsets.only(bottom: 350),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      textInputAction: TextInputAction.done,
      autovalidateMode: widget.autoValidateMode,
      inputFormatters: widget.inputFormatters,
      decoration: _buildInputDecoration(textEditingController, context),
      onTap: () {
        textEditingController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: textEditingController.value.text.length,
        );
      },
      onTapOutside: (event) => widget.callBacks?.onTapOutSide?.call(event),
      onEditingComplete: () {
        if (itemSelected != null) widget.callBacks?.onItemSelected?.call(itemSelected!);
      },
      onFieldSubmitted: (value) {
        onFieldSubmitted();
        if (itemSelected != null) widget.callBacks?.onItemSelected?.call(itemSelected!);
      },
      onSaved: (newValue) {
        if (itemSelected != null) widget.callBacks?.onItemSelected?.call(itemSelected!);
      },
      onChanged: (value) {
        filterController.text = textEditingController.text;
        widget.callBacks?.onChanged?.call(value);
        if (data.isNotEmpty) itemSelected = _getOptionsFiltered().first;
        DebounceHelper().run(() => setState(() {}));
      },
    );
  }

  InputDecoration _buildInputDecoration(TextEditingController textEditingController, BuildContext context) {
    return InputDecoration(
      prefixIcon: widget.decoration?.prefixIcon,
      suffixIcon: _loadingNotifier.value
          ? _buildLoading()
          : textEditingController.text.trim() != ''
              ? InkWell(
                  onTap: () {
                    textEditingController.clear();
                    widget.callBacks?.onItemDeleted?.call();
                  },
                  child: const Icon(Icons.close, color: Colors.black),
                )
              : widget.decoration?.suffixIcon,
      filled: true,
      isDense: true,
      fillColor: Colors.white,
      hoverColor: Colors.transparent,
      errorMaxLines: 1,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      prefixIconConstraints: const BoxConstraints(maxWidth: 150, minWidth: 12),
      suffixIconConstraints: const BoxConstraints(minWidth: 24 + 16, maxHeight: 24),
      hintText: widget.decoration?.hintText ?? '',
      border: widget.decoration?.border,
      enabledBorder: widget.decoration?.enabledBorder,
      errorBorder: widget.decoration?.errorBorder,
      focusedErrorBorder: widget.decoration?.focusedErrorBorder,
      focusedBorder: widget.decoration?.focusedBorder,
      disabledBorder: widget.decoration?.disabledBorder,
    );
  }

  SizedBox _buildLoading() {
    return const SizedBox(
      height: 21,
      child: FittedBox(fit: BoxFit.fitHeight, child: CircularProgressIndicator(strokeWidth: 2.5)),
    );
  }

  @override
  void dispose() {
    widget.controller.dispose();
    _loadingNotifier.dispose();
    textFieldFocusNode.dispose();
    super.dispose();
  }

  static String _displayStringForOption<T extends MenuItemType>(T option) => option.itemName();
}

class OptionViewItem<T extends MenuItemType> extends StatelessWidget {
  const OptionViewItem({
    super.key,
    required this.option,
    required this.itemSelected,
    required this.keyTextField,
    required this.onSelected,
  });

  final T option;
  final T? itemSelected;
  final GlobalKey keyTextField;
  final Function(T item) onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onSelected(option),
        child: Container(
          height: 36,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color:
                itemSelected?.itemCode() == option.itemCode() ? Colors.grey.withValues(alpha: .2) : Colors.transparent,
          ),
          child: Text(
            option.itemName(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}
