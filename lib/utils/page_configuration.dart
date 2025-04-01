import 'package:autocomplete_plus/utils/ultis.dart';

class PageConfiguration {
  PageConfiguration({
    this.pageNo = 0,
    this.pageSize = 10,
    this.keyWord,
    this.pageActions = PageActions.refresh,
  });

  factory PageConfiguration.reset({String? keyWord}) {
    return PageConfiguration(keyWord: keyWord);
  }

  int pageNo;
  int pageSize;
  String? keyWord;
  PageActions pageActions;
}
