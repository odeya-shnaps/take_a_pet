import 'package:flutter/material.dart';

enum Options { one, two, three, four, five, six }

/// This is the stateful widget that the main application instantiates.
class PickButton extends StatefulWidget {
  const PickButton({Key? key, required this.optionsList, required this.textController, required this.fontSize}) : super(key: key);

  final List<String> optionsList;
  final TextEditingController textController;
  final double fontSize;

  @override
  _PickButtonState createState() => _PickButtonState();
}

class _PickButtonState extends State<PickButton> {
  Options? picked;
  String _selected = "";
  int _numOptions = 2;

  @override
  void initState() {
    super.initState();
    _numOptions = widget.optionsList.length;
  }

  Widget _createOption(double width, int index, int numRow) {

    int correctIndex = index + (numRow * 2);

    if (correctIndex < _numOptions) {
      String text = widget.optionsList[correctIndex];

      return Container(
        width: width,
        child: ListTile(
          title: Text(text,
            style: TextStyle(
              color: Colors.black54,
              fontSize: widget.fontSize,
            ),
          ),
          leading: Radio<Options>(
            value: Options.values[correctIndex],
            groupValue: picked,
            onChanged: (Options? value) {
              setState(() {
                picked = value;
                _selected = text;
                widget.textController.text = _selected;
              });
            },
          ),
        ),
      );
    }
    return SizedBox();
  }

  List<Widget> _createChildren(double width, int numRow) {
    return new List<Widget>.generate(2, (int index) => _createOption(width/2, index, numRow));
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width - 40;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _createChildren(deviceWidth, 0)
        ),
        (_numOptions > 2) ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _createChildren(deviceWidth, 1)
        ) : SizedBox(),
        (_numOptions > 4) ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _createChildren(deviceWidth, 2)
        ) : SizedBox(),
      ],
    );
  }
}
