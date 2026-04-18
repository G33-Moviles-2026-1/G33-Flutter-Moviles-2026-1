class ValidateBookingDate {
  const ValidateBookingDate();

  String? call(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastBookableDate = today.add(const Duration(days: 7));
    final normalized = DateTime(date.year, date.month, date.day);

    if (normalized.isBefore(today) || normalized.isAfter(lastBookableDate)) {
      return 'You can only book for today and the next 7 days.';
    }

    return null;
  }
}