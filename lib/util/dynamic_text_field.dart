import 'package:flutter/material.dart';

class DynamicTextField extends StatefulWidget {
  const DynamicTextField({Key? key, required this.fieldsController, required this.hint}) : super(key: key);

  //final TextEditingController textController;
  final String hint;
  final List<TextEditingController> fieldsController;

  @override
  _DynamicTextFieldState createState() => _DynamicTextFieldState();
}

class _DynamicTextFieldState extends State<DynamicTextField> {

  final _formKey = GlobalKey<FormState>();
  List<bool> isPress = [];
  List<Icon> icons = [];

  int _numFields = 1;

  @override
  void initState() {
    super.initState();
  }

  Widget _createTextField(BuildContext context, int index) {
    widget.fieldsController.add(new TextEditingController());
    isPress.add(false);
    icons.add(Icon(Icons.add_circle_outline));

    return TextFormField(
      keyboardType: TextInputType.text,
      decoration: InputDecoration (
        //icon: Icon(Icons.recommend),
        suffixIcon: IconButton(
          icon: icons[index],
          onPressed: () {
            if (!isPress[index] && _formKey.currentState!.validate()) {

              setState(() {
                icons[index] = Icon(Icons.remove_circle_outline);
                isPress[index] = true;
                // add field
                _numFields++;
                //this filed is read only
              });

            } else if (isPress[index] && _numFields > 1){
              //remove this field
              widget.fieldsController.removeAt(index);
              isPress.removeAt(index);
              icons.removeAt(index);
              setState(() {
                _numFields -= 1;
              });
            }
          },
        ),
        hintText: widget.hint,
      ),
      readOnly: isPress[index],
      controller: widget.fieldsController[index],
      validator: (val) {
        if (val == "" || val == null || val.isEmpty) {
          return 'Please fill this ' + widget.hint + ' first';
        }
        // valid info
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width - 40;
    return Container(
      padding: const EdgeInsets.only(left: 30),
        width: deviceWidth,
        child: Flexible(
              child: Form(
                key: _formKey,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _numFields,
                  itemBuilder: (context, index) {
                    return _createTextField(context, index);
                  },
                ),
              ),

        ),
      );

  }
}

/*
Flexible(
    child: ListView.builder(
    shrinkWrap: true,
    itemCount: _count,
    itemBuilder: (context, index) {
        return _row(index);
    },
  ),
)
 */