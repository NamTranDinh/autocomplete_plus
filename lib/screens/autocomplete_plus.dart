import 'package:autocomplete_plus/models/menu_item_type.dart';
import 'package:autocomplete_plus/utils/extensions.dart';
import 'package:autocomplete_plus/utils/helpers.dart';
import 'package:autocomplete_plus/utils/ultis.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AutocompletePlus<T extends MenuItemType> extends StatefulWidget {
  const AutocompletePlus({
    super.key,
    required this.getDataCallBack,
    this.onItemClicked,
    this.controller,
    this.validator,
    this.onChanged,
    this.showAllDataWhenNull = true,
    this.autoValidateMode,
    this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.label,
    this.labelWidget,
    this.inputFormatters,
    this.onTapOutSide,
    this.onFieldSubmit,
  });

  final bool showAllDataWhenNull;
  final AutovalidateMode? autoValidateMode;
  final String? hintText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? label;
  final Widget? labelWidget;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final GetDataCallback<T> getDataCallBack;
  final void Function(String?)? onChanged;
  final void Function(T? t)? onItemClicked;
  final void Function(T? t)? onFieldSubmit;
  final Function(PointerDownEvent event)? onTapOutSide;
  final String? Function(String?)? validator;

  @override
  State<AutocompletePlus<T>> createState() {
    return _AutocompletePlusState<T>();
  }
}

class _AutocompletePlusState<T extends MenuItemType> extends State<AutocompletePlus<T>> {
  final _loadingNotifier = ValueNotifier<bool>(false);
  final double _dropDownMaxHeight = 238;
  late GlobalKey keyTextField;

  List<T> data = [];

  @override
  void initState() {
    keyTextField = GlobalKey();

    getData();

    super.initState();
  }

  Future<void> getData() async {
    // _loadingNotifier.value = true;
    // if (kDebugMode) await Future.delayed(Duration(seconds: 1));
    // await widget.getDataCallBack.call().then((value) => data
    //   ..clear()
    //   ..addAll(value)
    //   ..toSet()
    //   ..toList());
    // _loadingNotifier.value = false;
  }

  @override
  void dispose() {
    if (widget.controller != null) widget.controller?.dispose();
    _loadingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelWidget != null || widget.label != null)
          widget.labelWidget ??
              Text(
                widget.label ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
        const SizedBox(height: 3),
        RawAutocomplete<T>(
          onSelected: (option) => widget.onItemClicked?.call(option),
          displayStringForOption: _displayStringForOption,
          optionsBuilder: (textEditingValue) async {
            if (!widget.showAllDataWhenNull) {
              if (textEditingValue.text == '') return Iterable<T>.empty();
            }

            return widget.getDataCallBack.call().then((value) => value).then(
              (data) {
                return data.where(
                  (o) {
                    return (o.itemName())
                        .removeDiacritics
                        .toLowerCase()
                        .contains(textEditingValue.text.removeDiacritics.toLowerCase());
                  },
                );
              },
            );
          },
          fieldViewBuilder: (context, ctl, focusNode, onFieldSubmitted) {
            return ValueListenableBuilder(
              valueListenable: _loadingNotifier,
              builder: (context, value, child) {
                return _buildTextFormField(ctl, context, focusNode);
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: _dropDownMaxHeight,
                  maxWidth: AppHelpers.getSizeByKey(keyTextField).width,
                ),
                padding: const EdgeInsets.all(8),
                decoration: buildBoxDecoration(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.toList().length,
                    itemBuilder: (context, index) {
                      return OptionViewItem(
                        keyTextField: keyTextField,
                        option: options.toList()[index],
                        onSelected: (p0) => onSelected(p0),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.1),
          spreadRadius: 3,
          blurRadius: 13,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  TextFormField _buildTextFormField(
    TextEditingController textEditingController,
    BuildContext context,
    FocusNode focusNode,
  ) {
    return TextFormField(
      key: keyTextField,
      controller: textEditingController,
      focusNode: focusNode,
      validator: widget.validator,
      keyboardType: TextInputType.text,
      scrollPadding: const EdgeInsets.only(bottom: 350),
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      textInputAction: TextInputAction.next,
      autovalidateMode: widget.autoValidateMode,
      inputFormatters: widget.inputFormatters,
      decoration: _buildInputDecoration(textEditingController, context),
      onChanged: (value) {
        widget.onChanged?.call(value);
        setState(() {});
      },
    );
  }

  InputDecoration _buildInputDecoration(
    TextEditingController textEditingController,
    BuildContext context,
  ) {
    return InputDecoration(
      prefixIcon: widget.prefixIcon,
      suffixIcon: _loadingNotifier.value
          ? SizedBox(
              height: 21,
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
              ),
            )
          : textEditingController.text.trim() != ''
              ? InkWell(
                  onTap: () {
                    textEditingController.clear();
                    widget.onItemClicked?.call(null);
                  },
                  child: Icon(Icons.close, color: Colors.black),
                )
              : widget.suffixIcon,
      filled: true,
      isDense: true,
      fillColor: Colors.white,
      hoverColor: Colors.transparent,
      errorMaxLines: 1,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      prefixIconConstraints: const BoxConstraints(
        maxWidth: 150,
        minWidth: 12,
      ),
      suffixIconConstraints: const BoxConstraints(
        maxWidth: 24 + 16,
        minWidth: 24 + 16,
        maxHeight: 24,
      ),
      hintText: widget.hintText ?? '',
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  static String _displayStringForOption<T extends MenuItemType>(T option) => option.itemName();
}

class OptionViewItem<T extends MenuItemType> extends StatefulWidget {
  const OptionViewItem({
    super.key,
    required this.option,
    required this.keyTextField,
    required this.onSelected,
  });

  final T option;
  final GlobalKey keyTextField;
  final Function(dynamic) onSelected;

  @override
  State<OptionViewItem> createState() => _OptionViewItemState();
}

class _OptionViewItemState extends State<OptionViewItem> {
  Color _backgroundOption = Colors.white;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onSelected(widget.option),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        width: AppHelpers.getSizeByKey(widget.keyTextField).width - 16,
        color: _backgroundOption,
        child: Text(
          widget.option.itemName(),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
