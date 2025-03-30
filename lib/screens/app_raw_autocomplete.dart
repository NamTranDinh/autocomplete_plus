import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppRawAutocomplete<T extends Object> extends StatefulWidget {
  const AppRawAutocomplete({
    super.key,
    required this.optionsViewBuilder,
    required this.optionsBuilder,
    this.optionsViewOpenDirection = OptionsViewOpenDirection.down,
    this.displayStringForOption = defaultStringForOption,
    this.fieldViewBuilder,
    this.focusNode,
    this.onSelected,
    this.textEditingController,
    this.initialValue,
  })  : assert(
          fieldViewBuilder != null ||
              (key != null &&
                  focusNode != null &&
                  textEditingController != null),
          'Pass in a fieldViewBuilder, or otherwise create a separate field and pass in the FocusNode, TextEditingController, and a key. Use the key with RawAutocomplete.onFieldSubmitted.',
        ),
        assert((focusNode == null) == (textEditingController == null)),
        assert(
          !(textEditingController != null && initialValue != null),
          'textEditingController and initialValue cannot be simultaneously defined.',
        );

  final AutocompleteFieldViewBuilder? fieldViewBuilder;

  final FocusNode? focusNode;

  final AutocompleteOptionsViewBuilder<T> optionsViewBuilder;

  final OptionsViewOpenDirection optionsViewOpenDirection;

  final AutocompleteOptionToString<T> displayStringForOption;

  final AutocompleteOnSelected<T>? onSelected;

  final AutocompleteOptionsBuilder<T> optionsBuilder;

  final TextEditingController? textEditingController;

  final TextEditingValue? initialValue;

  static void onFieldSubmitted<T extends Object>(GlobalKey key) {
    final rawAutocomplete = key.currentState! as _AppRawAutocompleteState<T>;
    rawAutocomplete._onFieldSubmitted();
  }

  static String defaultStringForOption(Object? option) {
    return option.toString();
  }

  @override
  State<AppRawAutocomplete<T>> createState() => _AppRawAutocompleteState<T>();
}

class _AppRawAutocompleteState<T extends Object>
    extends State<AppRawAutocomplete<T>> {
  final _fieldKey = GlobalKey();
  final _optionsLayerLink = LayerLink();
  final _optionsViewController = OverlayPortalController(
    debugLabel: '_RawAutocompleteState',
  );

  TextEditingController? _internalTextEditingController;

  TextEditingController get _textEditingController {
    return widget.textEditingController ??
        (_internalTextEditingController ??= TextEditingController()
          ..addListener(_onChangedField));
  }

  FocusNode? _internalFocusNode;

  FocusNode get _focusNode {
    return widget.focusNode ??
        (_internalFocusNode ??= FocusNode()
          ..addListener(_updateOptionsViewVisibility));
  }

  late final Map<Type, CallbackAction<Intent>> _actionMap =
      <Type, CallbackAction<Intent>>{
    AutocompletePreviousOptionIntent:
        _AutocompleteCallbackAction<AutocompletePreviousOptionIntent>(
      onInvoke: _highlightPreviousOption,
      isEnabledCallback: () => _canShowOptionsView,
    ),
    AutocompleteNextOptionIntent:
        _AutocompleteCallbackAction<AutocompleteNextOptionIntent>(
      onInvoke: _highlightNextOption,
      isEnabledCallback: () => _canShowOptionsView,
    ),
    DismissIntent: CallbackAction<DismissIntent>(onInvoke: _hideOptions),
  };

  Iterable<T> _options = Iterable<T>.empty();
  T? _selection;

  String? _lastFieldText;
  final ValueNotifier<int> _highlightedOptionIndex = ValueNotifier<int>(0);

  static const _shortcuts = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowUp):
        AutocompletePreviousOptionIntent(),
    SingleActivator(LogicalKeyboardKey.arrowDown):
        AutocompleteNextOptionIntent(),
  };

  bool get _canShowOptionsView {
    return _focusNode.hasFocus && _selection == null && _options.isNotEmpty;
  }

  Future<void> _updateOptionsViewVisibility() async {
    final value = _textEditingController.value;
    final options = await widget.optionsBuilder(value);
    _options = options;

    if (_canShowOptionsView) {
      _optionsViewController.show();
    } else {
      _optionsViewController.hide();
    }
  }

  Future<void> _onChangedField() async {
    final value = _textEditingController.value;
    final options = await widget.optionsBuilder(value);
    _options = options;
    _updateHighlight(_highlightedOptionIndex.value);
    final selection = _selection;
    if (selection != null &&
        value.text != widget.displayStringForOption(selection)) {
      _selection = null;
    }

    if (value.text != _lastFieldText) {
      _lastFieldText = value.text;
      await _updateOptionsViewVisibility();
    }
  }

  void _onFieldSubmitted() {
    if (_optionsViewController.isShowing) {
      _select(_options.elementAt(_highlightedOptionIndex.value));
    }
  }

  void _select(T nextSelection) {
    if (nextSelection == _selection) {
      return;
    }
    _selection = nextSelection;
    final selectionString = widget.displayStringForOption(nextSelection);
    _textEditingController.value = TextEditingValue(
      selection: TextSelection.collapsed(offset: selectionString.length),
      text: selectionString,
    );
    widget.onSelected?.call(nextSelection);
    _updateOptionsViewVisibility();
  }

  void _updateHighlight(int newIndex) {
    _highlightedOptionIndex.value =
        _options.isEmpty ? 0 : newIndex % _options.length;
  }

  void _highlightPreviousOption(AutocompletePreviousOptionIntent intent) {
    assert(_canShowOptionsView);
    _updateOptionsViewVisibility();
    assert(_optionsViewController.isShowing);
    _updateHighlight(_highlightedOptionIndex.value - 1);
  }

  void _highlightNextOption(AutocompleteNextOptionIntent intent) {
    assert(_canShowOptionsView);
    _updateOptionsViewVisibility();
    assert(_optionsViewController.isShowing);
    _updateHighlight(_highlightedOptionIndex.value + 1);
  }

  Object? _hideOptions(DismissIntent intent) {
    if (_optionsViewController.isShowing) {
      _optionsViewController.hide();
      return null;
    } else {
      return Actions.invoke(context, intent);
    }
  }

  Widget _buildOptionsView(BuildContext context) {
    final textDirection = Directionality.of(context);
    final followerAlignment = switch (widget.optionsViewOpenDirection) {
      OptionsViewOpenDirection.up => AlignmentDirectional.bottomStart,
      OptionsViewOpenDirection.down => AlignmentDirectional.topStart,
    }
        .resolve(textDirection);
    final targetAnchor = switch (widget.optionsViewOpenDirection) {
      OptionsViewOpenDirection.up => AlignmentDirectional.topStart,
      OptionsViewOpenDirection.down => AlignmentDirectional.bottomStart,
    }
        .resolve(textDirection);

    return CompositedTransformFollower(
      link: _optionsLayerLink,
      showWhenUnlinked: false,
      targetAnchor: targetAnchor,
      followerAnchor: followerAlignment,
      child: TextFieldTapRegion(
        child: AutocompleteHighlightedOption(
          highlightIndexNotifier: _highlightedOptionIndex,
          child: Builder(
            builder: (BuildContext context) {
              return widget.optionsViewBuilder(context, _select, _options);
            },
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final initialController = widget.textEditingController ??
        (_internalTextEditingController =
            TextEditingController.fromValue(widget.initialValue));
    initialController.addListener(_onChangedField);
    widget.focusNode?.addListener(_updateOptionsViewVisibility);
  }

  @override
  void didUpdateWidget(AppRawAutocomplete<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(
      oldWidget.textEditingController,
      widget.textEditingController,
    )) {
      oldWidget.textEditingController?.removeListener(_onChangedField);
      if (oldWidget.textEditingController == null) {
        _internalTextEditingController?.dispose();
        _internalTextEditingController = null;
      }
      widget.textEditingController?.addListener(_onChangedField);
    }
    if (!identical(oldWidget.focusNode, widget.focusNode)) {
      oldWidget.focusNode?.removeListener(_updateOptionsViewVisibility);
      if (oldWidget.focusNode == null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }
      widget.focusNode?.addListener(_updateOptionsViewVisibility);
    }
  }

  @override
  void dispose() {
    widget.textEditingController?.removeListener(_onChangedField);
    _internalTextEditingController?.dispose();
    widget.focusNode?.removeListener(_updateOptionsViewVisibility);
    _internalFocusNode?.dispose();
    _highlightedOptionIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fieldView = widget.fieldViewBuilder?.call(
          context,
          _textEditingController,
          _focusNode,
          _onFieldSubmitted,
        ) ??
        const SizedBox.shrink();
    return OverlayPortal.targetsRootOverlay(
      controller: _optionsViewController,
      overlayChildBuilder: _buildOptionsView,
      child: TextFieldTapRegion(
        child: Container(
          key: _fieldKey,
          child: Shortcuts(
            shortcuts: _shortcuts,
            child: Actions(
              actions: _actionMap,
              child: CompositedTransformTarget(
                link: _optionsLayerLink,
                child: fieldView,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AutocompleteCallbackAction<T extends Intent> extends CallbackAction<T> {
  _AutocompleteCallbackAction({
    required super.onInvoke,
    required this.isEnabledCallback,
  });

  final bool Function() isEnabledCallback;

  @override
  bool isEnabled(covariant T intent) => isEnabledCallback();

  @override
  bool consumesKey(covariant T intent) => isEnabled(intent);
}

class AutocompletePreviousOptionIntent extends Intent {
  const AutocompletePreviousOptionIntent();
}

class AutocompleteNextOptionIntent extends Intent {
  const AutocompleteNextOptionIntent();
}

class AutocompleteHighlightedOption
    extends InheritedNotifier<ValueNotifier<int>> {
  const AutocompleteHighlightedOption({
    super.key,
    required ValueNotifier<int> highlightIndexNotifier,
    required super.child,
  }) : super(notifier: highlightIndexNotifier);

  static int of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<AutocompleteHighlightedOption>()
            ?.notifier
            ?.value ??
        0;
  }
}
