import 'package:autocomplete_plus/utils/queue_future.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autocomplete_plus/models/menu_item_type.dart';
import 'package:autocomplete_plus/screens/app_raw_autocomplete.dart';
import 'package:autocomplete_plus/screens/substring_higlight.dart';
import 'package:autocomplete_plus/utils/debounce.dart';
import 'package:autocomplete_plus/utils/extensions.dart';
import 'package:autocomplete_plus/utils/helpers.dart';
import 'package:autocomplete_plus/utils/page_configuration.dart';
import 'package:autocomplete_plus/utils/ultis.dart';

/// {@template AutocompletePlus}
/// A customizable autocomplete widget that enhances the basic functionality
/// of a text field by providing a list of suggestions based on user input.
///
/// This widget supports loading data from an API, pagination, and various
/// customization options for styling and behavior.
///
/// [T] is the type of the menu items, which must extend [MenuItemType].
/// {@endtemplate}
class AutocompletePlus<T extends MenuItemType> extends StatefulWidget {
  const AutocompletePlus({
    super.key,
    required this.getDataCallBack,
    required this.controller,
    required this.isLoadFromApi,
    this.itemSelected,
    this.decoration,
    this.validator,
    this.autoValidateMode,
    this.inputFormatters,
    this.callBacks,
    this.initPageNo = 1,
    this.initPageSize = 20,
  }) : assert(initPageSize >= 20, 'Not support for pageSize < 20');

  /// init page number for list data. default is 1
  final int initPageNo;

  /// init page size for list data. default is 20
  final int initPageSize;

  /// is load data from api. default is false
  final bool isLoadFromApi;

  /// get data from callback
  final GetDataCallback<T> getDataCallBack;

  /// item selected default.
  final T? itemSelected;

  /// controller for text field.
  final TextEditingController controller;

  /// AutocompletePlusDecoration for decoration.
  final AutocompletePlusDecoration? decoration;

  /// Auto validate Mode for text field.
  final AutovalidateMode? autoValidateMode;

  /// TextInputFormatter for text field.
  final List<TextInputFormatter>? inputFormatters;

  /// validator for text field.
  final String? Function(String? value)? validator;

  /// Call back for [onItemSelected], [onFieldSubmit], [onItemDeleted], [onChanged], [onTapOutSide].
  ///
  ///  * [onItemSelected]: call back when user selected item in dropdown list.
  ///  * [onFieldSubmit]: call back when user submit text field.
  ///  * [onItemDeleted]: call back when user delete item.
  ///  * [onChanged]: call back when value of text field change.
  ///  * [onTapOutSide]: call back when user tap outside text field.
  final AutoCompletePlusCallBacks<T>? callBacks;

  @override
  State<AutocompletePlus<T>> createState() => _AutocompletePlusState<T>();
}

class _AutocompletePlusState<T extends MenuItemType> extends State<AutocompletePlus<T>>
    with SingleTickerProviderStateMixin {
  /// Global key for the text field.
  final keyTextField = GlobalKey();

  /// Focus node for the text field.
  final _textFieldFocusNode = FocusNode();

  /// Notifier for the loading state.
  final _loadingNotifier = ValueNotifier<bool>(false);

  /// List of data to display.
  final List<T> _dataHolder = [];

  /// Search text editing controller.
  late TextEditingController searchController;

  /// Page configuration for pagination.
  late PageConfiguration pageConfiguration;

  /// Selected item.
  T? itemSelected;

  /// Queue for handling asynchronous operations.
  final _queue = Queue();

  @override
  void initState() {
    itemSelected = widget.itemSelected;
    pageConfiguration = PageConfiguration(
      pageNo: widget.initPageNo,
      pageSize: widget.initPageSize,
      keyWord: widget.controller.text,
    );
    searchController = TextEditingController(text: widget.controller.text);

    super.initState();
  }

  /// Asynchronously fetches data based on the provided [pageConfigs].
  ///
  /// This method checks if the text field has focus and if the current page is the initial page.
  /// If so, it sets the loading state to true. It also checks if the pagination should be disabled.
  /// It then calls the [widget.getDataCallBack] to fetch data. If the data is empty and the current page is
  /// beyond the initial page, it disables pagination. Finally, it updates the UI.
  Future<List<T>> getData({required PageConfiguration pageConfigs}) async {
    if (_textFieldFocusNode.hasFocus && pageConfigs.pageNo == widget.initPageNo) {
      _loadingNotifier.value = true;
    }
    if (pageConfigs.pageActions == PageActions.disable && pageConfigs.pageNo > widget.initPageNo) return _dataHolder;

    await Future.delayed(Duration(seconds: 1));
    await widget.getDataCallBack.call(pageConfigs.pageNo, pageConfigs.pageSize, pageConfigs.keyWord).then(
      (value) {
        if (value.isEmpty && pageConfigs.pageNo > widget.initPageNo) {
          pageConfigs.pageActions = PageActions.disable;
          return;
        }

        if (pageConfigs.pageNo == widget.initPageNo) {
          _dataHolder
            ..clear()
            ..addAll(value);
        } else {
          _dataHolder.addAll(value);
        }

        if (value.length < widget.initPageSize) {
          pageConfigs.pageActions = PageActions.disable;
        }
        setState(() {});
      },
    );
    if (_loadingNotifier.value) {
      _loadingNotifier.value = false;
    }
    return _dataHolder;
  }

  /// Filters the list of options based on the current search text.
  ///
  /// This method returns a list of options (`List<T>`) that match the current search
  /// criteria. It filters the `data` list, keeping only the items whose `itemName`
  /// contains the search text (case-insensitive and diacritics-insensitive).
  List<T> _getOptionsFiltered() => _dataHolder.where(
        (option) {
          return option
              .itemName()
              .removeDiacritics
              .toLowerCase()
              .contains(searchController.text.removeDiacritics.toLowerCase());
        },
      ).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.decoration?.labelWidget != null || widget.decoration?.label != null)
          widget.decoration?.labelWidget ??
              Text(
                widget.decoration?.label ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
        if (widget.decoration?.labelWidget != null || widget.decoration?.label != null) const SizedBox(height: 3),
        AppRawAutocomplete<T>(
          focusNode: _textFieldFocusNode,
          textEditingController: widget.controller,
          onSelected: (option) {
            setState(() {
              itemSelected = option;
              widget.callBacks?.onItemSelected?.call(option);
              searchController.clear();
              _textFieldFocusNode.unfocus();
            });
          },
          optionsBuilder: (textEditingValue) async {
            if (_textFieldFocusNode.hasFocus && _dataHolder.isEmpty) {
              return _queue.add(() async => await getData(pageConfigs: pageConfiguration));
            }
            return _getOptionsFiltered();
          },
          fieldViewBuilder: _buildTextFormField,
          optionsViewBuilder: buildOptionsViewBuilder,
          displayStringForOption: _displayStringForOption,
        ),
      ],
    );
  }

  Widget buildOptionsViewBuilder(BuildContext context, Function(T option) onSelected, Iterable<T> _) {
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
        child: Theme(
          data: ThemeData(scrollbarTheme: const ScrollbarThemeData(thickness: WidgetStatePropertyAll(2))),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: _getOptionsFiltered().toList().length,
            itemBuilder: (context, index) {
              if (_getOptionsFiltered().toList().length - 1 == index && widget.isLoadFromApi) {
                if (pageConfiguration.pageActions != PageActions.disable) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _loadingNotifier.value = true);
                  _queue.add(() async {
                    pageConfiguration.pageNo += 1;
                    pageConfiguration.keyWord = searchController.text;
                    getData(pageConfigs: pageConfiguration);
                  });
                }
              }

              return OptionViewItem<T>(
                key: ValueKey(itemSelected?.itemCode() ?? ''),
                keyTextField: keyTextField,
                option: _getOptionsFiltered().toList()[index],
                onSelected: (p0) => onSelected(p0),
                itemSelected: itemSelected,
                term: searchController.text.trim() == '' ? widget.controller.text : searchController.text,
                index: index + 1,
              );
            },
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: .5),
              child: Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: .1)),
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

  Widget _buildTextFormField(
    BuildContext context,
    TextEditingController textEditingController,
    FocusNode focusNode,
    VoidCallback onFieldSubmitted,
  ) {
    return ValueListenableBuilder(
      valueListenable: _loadingNotifier,
      builder: (context, value, child) => TextFormField(
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
        onTapOutside: (event) {
          focusNode.unfocus();
          widget.callBacks?.onTapOutSide?.call(event);
        },
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
          searchController.text = textEditingController.text;
          widget.callBacks?.onChanged?.call(value);
          if (_getOptionsFiltered().isNotEmpty) itemSelected = _getOptionsFiltered().first;
          DebounceHelper().run(
            () => setState(() {
              pageConfiguration.pageNo = widget.initPageNo;
              pageConfiguration.pageActions = PageActions.refresh;
              getData(pageConfigs: pageConfiguration);
            }),
          );
        },
      ),
    );
  }

  InputDecoration _buildInputDecoration(TextEditingController textEditingController, BuildContext context) {
    return InputDecoration(
      prefixIcon: widget.decoration?.prefixIcon,
      suffixIcon: _loadingNotifier.value
          ? _buildLoading()
          : textEditingController.text.trim() != '' || widget.controller.text.trim() != ''
              ? InkWell(
                  onTap: () {
                    setState(() {
                      textEditingController.clear();
                      searchController.clear();
                      widget.callBacks?.onItemDeleted?.call();
                      if (_getOptionsFiltered().isNotEmpty) itemSelected = _getOptionsFiltered().first;
                    });
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
    _textFieldFocusNode.dispose();
    _queue.dispose();
    super.dispose();
  }

  static String _displayStringForOption<T extends MenuItemType>(T option) => option.itemName();
}

/// A widget that represents a single item in the list of options within the [AutocompletePlus] dropdown.
///
/// This widget is responsible for displaying the item's text and highlighting any substrings that match
/// the current search term. It also handles the selection of the item and updates the UI accordingly.
///
class OptionViewItem<T extends MenuItemType> extends StatelessWidget {
  const OptionViewItem({
    super.key,
    required this.option,
    required this.itemSelected,
    required this.keyTextField,
    required this.onSelected,
    required this.term,
    this.index,
  });

  /// The menu item that this widget represents.
  final T option;

  /// The currently selected item, if any.
  final T? itemSelected;

  /// The global key for the text field associated with this autocomplete widget.
  final GlobalKey keyTextField;

  /// A callback function that is called when this item is selected.
  ///
  /// This function takes a single argument, `item`, which represents the selected menu item of type `T`.
  final Function(T item) onSelected;

  /// The search term that is used to filter the menu items.
  ///
  /// This term is used to highlight matching substrings within the menu item's text.
  final String term;

  /// The index of this item within the list of options.
  ///
  /// This can be used to determine the position of this item in the list,
  /// starting from 1 for the first item, 2 for the second, and so on.
  final int? index;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onSelected(option),
        child: Container(
          constraints: BoxConstraints(minHeight: 36),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: itemSelected?.itemCode() == option.itemCode()
                ? Colors.grey.withValues(alpha: 00.2)
                : Colors.transparent,
          ),
          child: SubstringHighlight(
            text: '${option.itemCode()} - ${option.itemName()}',
            term: term,
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
