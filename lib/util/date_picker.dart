import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:take_a_pet/util/shadow_button.dart';
import 'package:take_a_pet/util/text_form.dart';

class DatePicker extends StatefulWidget {

  const DatePicker({Key? key, required this.textController, required this.active}) : super(key: key);

  final TextEditingController textController;
  final bool active;

  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  /// Which holds the selected date
  /// Defaults to today's date.
  DateTime selectedDate = DateTime.now();
  String date = "Date Of Birth";

  /// This decides which day will be enabled
  /// This will be called every time while displaying day in calender.
  bool _decideWhichDayToEnable(DateTime day) {
    if ((day.isAfter(DateTime.now().subtract(Duration(days: 1))) &&
        day.isBefore(DateTime.now().add(Duration(days: 10))))) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

  }

  _selectDate(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    //assert(theme.platform != null);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDatePicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDatePicker(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.date_range),
      onPressed: () => widget.active ? _selectDate(context) : {},
      color: widget.active ? Colors.amber : Colors.grey,
      tooltip: 'Date Of Birth',
    );
  }

  buildCupertinoDatePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (picked) {
                if (picked != null && picked != selectedDate)
                  setState(() {
                    selectedDate = picked;
                    date = organizeDate("${selectedDate.toLocal()}".split(' ')[0]);
                    widget.textController.text = date;
                  });
              },
              initialDateTime: selectedDate,
              minimumYear: 1900,
              maximumYear: 2025,
            ),
          );
        });
  }

  buildMaterialDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2025),
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDatePickerMode: DatePickerMode.day,
      //selectableDayPredicate: _decideWhichDayToEnable,
      helpText: 'Select booking date',
      cancelText: 'Not now',
      confirmText: 'Book',
      errorFormatText: 'Enter valid date',
      errorInvalidText: 'Enter date in valid range',
      fieldLabelText: 'Booking date',
      fieldHintText: 'Month/Day/Year',
      /*
                  builder: (context, child) {
                        return Theme(
                              data: ThemeData.light(),
                              child: ,
                        );
                  },*/
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        date = organizeDate("${selectedDate.toLocal()}".split(' ')[0]);
        widget.textController.text = date;
      });
  }

  String organizeDate(String date) {
    var splitDate = date.split('-');
    return splitDate[1] + "/" + splitDate[2] + "/" + splitDate[0];
  }

}


/*
Text(
          "${selectedDate.toLocal()}".split(' ')[0],
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

          Container(
            height: 100,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: DateTime(1900, 1, 1),
              onDateTimeChanged: (DateTime newDateTime) {
                // Do something
              },
            ),
          ),
 */

/*
    final deviceSize = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        /*
        LimitedBox(
          maxWidth: deviceSize.width/2,
          child: TextFormField(
            //labelText: "Date Of Birth",
            keyboardType: TextInputType.datetime,
            decoration: const InputDecoration (
                icon: Icon(Icons.description_outlined),
                hintText: "Date Of Birth",
            ),
            onSaved: (value) {},
            enabled: false,
          ),
        ),*/
        Text(
            "$date",
          style: TextStyle(
              fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(width: 10.0),
        IconButton(
          icon: Icon(Icons.date_range),
          onPressed: () => _selectDate(context),
          color: Colors.lightBlue,
        ),
      ],
    );*/