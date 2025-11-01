class DateHelper {
  // Formats a DateTime to display hour for hourly weather displays
  static String formatHour(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:00'; //00 here appends fixed minutes to show full hour format
  }
  
  // Formats a DateTime to display day name daily weather displays
  static String formatDayName(DateTime dateTime) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dateTime.weekday - 1]; /// converts 1-7 weekday to 0-6 index
  }
  
  // Formats a DateTime to display short date for weekly weather displays
  static String formatShortDate(DateTime dateTime) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dateTime.month - 1]} ${dateTime.day}'; //converts 1-12 month to 0-11 index and get the day of month like 21
  }
  
  // Comprehensive date format for detailed weather displays
  static String formatFullDate(DateTime dateTime) {
    return '${formatDayName(dateTime)}, ${formatShortDate(dateTime)}'; //calls the above two methods to get full date format
  }
}