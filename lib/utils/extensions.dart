extension StringExtension on String {
  String get toFirstCapital {
    return split(' ').map((word) {
      if (word.isNotEmpty) {
        return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
      }
      return word;
    }).join(' ');
  }

  String get removeDiacritics {
    return replaceAll(RegExp(r'[^\x00-\x7F]'), '').toLowerCase();
  }
}