import 'package:autocomplete_plus/utils/ultis.dart';

class PageConfiguration {
  PageConfiguration({
    this.pageNo = 1,
    this.pageSize = 20,
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
