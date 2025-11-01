class CountryHelper {
  static String countryCodeToEmoji(String code) {
    //Each letter in country code is converted to a regional indicator symbol 
    return code.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'), (match) {
      return String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397); 
      //get the match letter, get the unicode value of the letter and add offset to get regional indicator symbol
    });
  }
}
