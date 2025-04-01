import 'package:flutter/material.dart';

final int __int64MaxValue = double.maxFinite.toInt();

class SubstringHighlight extends StatelessWidget {
  const SubstringHighlight({
    super.key,
    required this.text,
    this.caseSensitive = false,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.term,
    this.terms,
    this.textAlign = TextAlign.left,
    this.textStyle = const TextStyle(color: Colors.black),
    this.textStyleHighlight = const TextStyle(color: Colors.red),
    this.wordDelimiters = r' .,;?!<>[]~`@#$%^&*()+-=|\/_',
    this.words = false,
  }) : assert(term != null || terms != null, '');

  /// By default the search terms are case insensitive.  Pass false to force case sensitive matches.
  final bool caseSensitive;

  /// How visual overflow should be handled.
  final TextOverflow overflow;

  /// An optional maximum number of lines for the text to span, wrapping if necessary.
  /// If the text exceeds the given number of lines, it will be truncated according
  /// to [overflow].
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  final int? maxLines;

  /// The sub-string that is highlighted inside {SubstringHighlight.text}.  (Either term or terms must be passed.  If both are passed they are combined.)
  final String? term;

  /// The array of sub-strings that are highlighted inside {SubstringHighlight.text}.  (Either term or terms must be passed.  If both are passed they are combined.)
  final List<String>? terms;

  /// The String searched by {SubstringHighlight.term} and/or {SubstringHighlight.terms} array.
  final String text;

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  /// The {TextStyle} of the {SubstringHighlight.text} that isn't highlighted.
  final TextStyle textStyle;

  /// The {TextStyle} of the {SubstringHighlight.term}/{SubstringHighlight.ters} matched.
  final TextStyle textStyleHighlight;

  /// String of characters that define word delimiters if {words} flag is true.
  final String wordDelimiters;

  /// If true then match complete words only (instead of characters or substrings within words).  This feature is in ALPHA... use 'words' AT YOUR OWN RISK!!!
  final bool words;

  @override
  Widget build(BuildContext context) {
    final textLC = caseSensitive ? text : text.toLowerCase();

    // corner case: if both term and terms array are passed then combine
    final termList = <String>[term ?? '', ...(terms ?? [])];

    // remove empty search terms ('') because they cause infinite loops
    final termListLC = termList.where((s) => s.isNotEmpty).map((s) => caseSensitive ? s : s.toLowerCase()).toList();

    final children = <InlineSpan>[];

    var start = 0;
    var idx = 0; // walks text (string that is searched)
    while (idx < textLC.length) {
      void nonHighlightAdd(int end) => children.add(TextSpan(text: text.substring(start, end), style: textStyle));

      // find index of term that's closest to current idx position
      var iNearest = -1;
      var idxNearest = __int64MaxValue;
      for (var i = 0; i < termListLC.length; i++) {
        int at;
        if ((at = textLC.indexOf(termListLC[i], idx)) >= 0) //MAGIC//CORE
        {
          if (words) {
            if (at > 0 && !wordDelimiters.contains(textLC[at - 1])) // is preceding character a delimiter?
            {
              continue; // preceding character isn't delimiter so disqualify
            }

            final followingIdx = at + termListLC[i].length;
            if (followingIdx < textLC.length &&
                !wordDelimiters.contains(textLC[followingIdx])) // is character following the search term a delimiter?
            {
              continue; // following character isn't delimiter so disqualify
            }
          }

          if (at < idxNearest) {
            iNearest = i;
            idxNearest = at;
          }
        }
      }

      if (iNearest >= 0) {
        // found one of the terms at or after idx
        // iNearest is the index of the closest term at or after idx that matches

        if (start < idxNearest) {
          // we found a match BUT FIRST output non-highlighted text that comes BEFORE this match
          nonHighlightAdd(idxNearest);
          start = idxNearest;
        }

        // output the match using desired highlighting
        final termLen = termListLC[iNearest].length;
        children.add(TextSpan(text: text.substring(start, idxNearest + termLen), style: textStyleHighlight));
        start = idx = idxNearest + termLen;
      } else {
        if (words) {
          idx++;
          nonHighlightAdd(idx);
          start = idx;
        } else {
          // if none match at all (ever!)
          // --or--
          // one or more matches but during this iteration there are NO MORE matches
          // in either case, add reminder of text as non-highlighted text
          nonHighlightAdd(textLC.length);
          break;
        }
      }
    }

    return RichText(
      maxLines: maxLines,
      overflow: overflow,
      text: TextSpan(children: children, style: textStyle),
      textAlign: textAlign,
    );
  }
}
