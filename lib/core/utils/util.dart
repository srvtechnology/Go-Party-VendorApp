import 'package:intl/intl.dart';

String formatDate(String dateTime) {
  return DateFormat("dd/MM/yyyy")
      .format(DateTime.parse(dateTime));
}
