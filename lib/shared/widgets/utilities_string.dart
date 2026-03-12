extension StringFormats on String {
  String toTitleCase() {
    return replaceAll('_', ' ')
        .split(' ')
        .map((str) => str.isEmpty ? '' : '${str[0].toUpperCase()}${str.substring(1)}')
        .join(' ');
  }
}