import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:take_a_pet/db/data_repository.dart';
import 'package:take_a_pet/models/animal_profile.dart';
import 'package:take_a_pet/util/const.dart';
import 'package:take_a_pet/util/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:take_a_pet/util/shadow_button.dart';
import 'package:take_a_pet/db/db_logic.dart';
import 'package:take_a_pet/util/pick_button.dart';
import 'package:take_a_pet/views/Image_view.dart';
import 'package:take_a_pet/db/storage_repository.dart';
import 'package:take_a_pet/util/dynamic_text_field.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:http/http.dart' as http;


class AnimalProfileCreate extends StatefulWidget {

  AnimalProfileCreate({Key? key, required this.logic, required this.storage, required this.dataRepo}) : super(key: key);

  final DBLogic logic;
  final StorageRepository storage;
  final DataRepository dataRepo;

  @override
  _AnimalProfileCreateState createState() => _AnimalProfileCreateState();
}

class _AnimalProfileCreateState extends State<AnimalProfileCreate> {

  var random = new Random();
  String _animalId = "";
  AnimalProfile _currentAnimal = new AnimalProfile(id: "15414",
      type: "",
      name: "",
      age: 0.0,
      // image: "",
      gender: "",
      size: "",
      color: [],
      location: "",
      createdAt: Timestamp.now(),
      creatorId: "",
      isAdopted: false,
      isDeleted: false,
      qualities: [],
      likesNum: 0);
  String _currentUserId = '';
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool saved = false;
  var _pressIcon = List<bool>.filled(3, false);
  //var _fieldIcons = List<Icon>.filled(3, Icon(Icons.keyboard_arrow_down_sharp));
  String _error = "";
  File? _selectedImage;
  var nameController = TextEditingController();
  //var breedController = TextEditingController();
  //var typeController = TextEditingController();
  var descriptionController = TextEditingController();
  var locationController = TextEditingController();
  var ageController = TextEditingController();
  var genderController = TextEditingController();
  var trainedController = TextEditingController();
  var sizeController = TextEditingController();
  List<TextEditingController> qualitiesController = [];
  List<TextEditingController> colorsController = [];
  final nameFocus = FocusNode();
  final typeFocus = FocusNode();
  final breedFocus = FocusNode();
  final ageFocus = FocusNode();
  final descriptionFocus = FocusNode();
  final locationFocus = FocusNode();
  Flushbar _flushbarError = Flushbar(message: "",);
  bool validImage = false;
  bool algoInProgress = false;
  String breedClassification='';
  String typeClassification='';


  @override
  void initState() {
    super.initState();

    // get current user's id and generate new animal id.
    _currentUserDetails();
  }

  @override
  void dispose() {
    // Clean up the controller and focus nodes when the Widget is disposed
    nameController.dispose();
    //breedController.dispose();
    //typeController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    ageController.dispose();
    genderController.dispose();
    trainedController.dispose();
    sizeController.dispose();
    nameFocus.dispose();
    typeFocus.dispose();
    breedFocus.dispose();
    ageFocus.dispose();
    descriptionFocus.dispose();
    locationFocus.dispose();
    qualitiesController.forEach((element) => element.dispose());
    colorsController.forEach((element) => element.dispose());
    super.dispose();
  }

  void _showError() {
    if (_error != "") {
      _flushbarError = Flushbar(
        title: "Error!",
        message: _error,
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red,
        titleSize: 14.0,
        messageSize: 12.0,
      );
      _flushbarError.show(context);
    }
    _error = "";
  }

  // void _initialize() {
  //   setState(() {
  //     nameController = TextEditingController();
  //     breedController = TextEditingController();
  //     typeController = TextEditingController();
  //     descriptionController = TextEditingController();
  //     locationController = TextEditingController();
  //     ageController = TextEditingController();
  //     genderController = TextEditingController();
  //     trainedController = TextEditingController();
  //     sizeController = TextEditingController();
  //     qualitiesController.clear();
  //     colorsController.clear();
  //   });
  // }

  String _generateAnimalId() {
    var num1 = random.nextInt(1000);
    var num2 = random.nextInt(100);
    return num1.toString() + DateTime.now().toString() + num2.toString();
  }

  double _getAge() {
    // which way is better??
    return double.tryParse(ageController.text) ?? 0.0;
  }

  List<String> _getQualities() {
    List<String> qual = [];
    for (int i = 0; i < qualitiesController.length; i++) {
      String text = qualitiesController[i].text;
      if (text != "") {
        qual.add(text);
      }
    }
    return qual;
  }

  List<String> _getColors() {
    List<String> colors = [];
    for (int i = 0; i < colorsController.length; i++) {
      String text = colorsController[i].text;
      if (text != "") {
        colors.add(text);
      }
    }
    return colors;
  }

  void _insertDetailsToAnimal() {

    print('inserting details');
    double age = _getAge();
    List<String> qualities = _getQualities();
    List<String> colors = _getColors();
    bool? trained = (trainedController.text == 'Trained') ? true : ((trainedController.text == 'Not Trained') ? false : null);
    _currentAnimal = _currentAnimal.copyWith(id: _animalId,
        type: typeClassification,
        name: nameController.text,
        age: age,
        // image: "",
        gender: genderController.text,
        size: sizeController.text,
        color: colors,
        location: locationController.text,
        //createdAt: Timestamp.now(),
        creatorId: _currentUserId,
        isAdopted: false,
        isDeleted: false,
        qualities: qualities,
        breed: breedClassification,
        isTrained: trained,
        about: descriptionController.text);

    print('DONE inserting details');

  }

  Future<void> _currentUserDetails() async {
    try {
      _currentUserId = widget.logic.getCurrentUser()!.uid;
      _animalId = _generateAnimalId();
      _currentAnimal = _currentAnimal.copyWith(id: _animalId);
    } catch (e) {
      _animalId = _generateAnimalId();
      _error = e.toString();
      _showError();
    }
  }

  Future<void> _addProfileToCreator() async {
    try {
      var creatorUser = await widget.logic.getUserById(_currentUserId);
      creatorUser.addToCreatedProfilesList(_animalId);
      widget.logic.updateUserInfo(updatedUser: creatorUser);
    } catch(e) {
      _error = e.toString();
      _showError();
    }
  }

  Future<void> _saveDetails(BuildContext context) async {



    print('saving details');

    try {
      //print('try');
      if(!validImage) {
        // print('You uploaded invalid image for your pet - see details above');
        throw 'You uploaded invalid image for your pet - see details above';
      }

      if (_formKey.currentState!.validate()) {
        //print('validate');

        // want to show the loading widget instead of form field
        // setState - tells the framework that the widget’s state has changed and that the widget should be redrawn
        setState(() {
          loading = true;
        });

          _insertDetailsToAnimal();
          //print('AFTER insert details to animal');


          //print('name   '+_currentAnimal.name);

        await widget.dataRepo.createAnimalInDB(newAnimal: _currentAnimal);
        await _addProfileToCreator();
        if(_selectedImage != null) {
          await widget.storage.uploadImageToStorage(_animalId, _selectedImage as File);
        }


    // Future.wait([
    //         widget.dataRepo.createAnimalInDB(newAnimal: _currentAnimal),
    //         _addProfileToCreator(),
    //         if(_selectedImage != null) widget.storage.uploadImageToStorage(_animalId, _selectedImage as File),
    //         //widget.dataRepo.updateAnimal(updatedAnimal: _currentAnimal)
    //       ]);

          print('finish insertion to DB');

          setState(() {

            _error = "";
            loading = false;
            saved = true;
          });



        } else {
        //print('You have problems in the info inserted');

        throw 'You have problems in the info inserted - see details above';
      }


    } catch (e) {
      _error = e.toString();
      _showError();
      setState(() {
        print('saving=trueERROR');
        saved = false;

        loading = false;
      });
    }
  }


  Widget _getActionButtons(BuildContext context) {


    return Padding(
        padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
        child: (validImage) ? ShadowButton(
          text: "PUBLISH",
          color: Colors.green,
          height: 40,
          width: 100,
          onPressed: () {
            //setState(() {});
            // save all in db

            print('PUBLISH');

            _saveDetails(context);

          },
        ) :
        ShadowButton(
          text: "PUBLISH",
          color: Colors.green[200],
          height: 40,
          width: 100,
          onPressed: () {},
        )
    );

  }

  Widget _createProfileImage() {
    return Container(
      height: 170.0,
      color: Colors.white,
      child: Stack(
        fit: StackFit.loose,
        children: <Widget>[
          InkWell(
            child: Center(
              child: Container(
                width: 170.0,
                height: 170.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[400],
                ),
                child: (_selectedImage == null) // no image in db and no image selected
                    ? Icon(
                  Icons.pets,
                  size: 130,
                  color: Colors.white,
                )
                    : ClipRRect( // the pickedPicture
                  borderRadius: BorderRadius.circular(50),
                  child: Image.file(_selectedImage as File,
                      fit: BoxFit.fill), // there is selected image - showing it
                ),
              ),
            ),
            onTap: () {
              if (_selectedImage != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ImageView(
                            selectedImage: _selectedImage, forEdit: false,),
                    ));
              }
            },
          ),
          Padding(
              padding: EdgeInsets.only(top: 125.0, left: 70),
              child: CircleAvatar(
                backgroundColor: Colors.lightBlue,
                radius: 20.0,
                child: IconButton(
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  iconSize: 25,
                  onPressed: !algoInProgress ? () {
                    _showImageSourceActionSheet();
                    _error = '';
                  } : () {},
                ),
              )),
        ],
      ),
    );
  }

  Widget _createTextFormField(BuildContext context, String hint, Icon textIcon,
      TextEditingController controller, FocusNode focus, FocusNode? nextFocus,
      TextInputType inputType, bool isRequired) {
    int? lines = 1;
    if (hint == "About Your Pet") {
      lines = null;
    }

    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: (hint == "About Your Pet") ? TextCapitalization.sentences : TextCapitalization.words,
      decoration: InputDecoration(
          icon: textIcon,
          hintText: hint
      ),
      autofocus: true,
      maxLines: lines,
      controller: controller,
      focusNode: focus,
      onFieldSubmitted: (nextFocus != null) ? (value) {
        FocusScope.of(context).requestFocus(nextFocus);
      } : null,

      validator: isRequired ? (val) {
        if (val == "" || val == null || val.isEmpty || val == '0.0') {
          return 'Please insert ' + hint;
        }
        // valid info
        return null;
      } : null,
    );
  }

  Widget _pickButton(BuildContext context, String hint,
      int index,
      TextEditingController controller, List<String> options, bool isRequired) {
    return Container(
      child: _pressIcon[index]
          ? PickButton(
          optionsList: options, textController: controller, fontSize: 14.0)
          : SizedBox(height: 0),
      //Column(
      // children: [
      //   Padding(
      //     padding: EdgeInsets.only(left: 10, right: 20),
      //     child: Stack(
      //       alignment: Alignment.centerLeft,
      //       children: <Widget>[
      //         IconButton(
      //           icon: _fieldIcons[index],
      //           color: Colors.lightBlue,
      //           onPressed: () {
      //             setState(() {
      //               if (_pressIcon[index]) {
      //                 _fieldIcons[index] = Icon(Icons
      //                     .keyboard_arrow_down_sharp);
      //                 _pressIcon[index] = false;
      //               } else {
      //                 _fieldIcons[index] = Icon(Icons
      //                     .keyboard_arrow_up_sharp);
      //                 _pressIcon[index] = true;
      //               }
      //             });
      //           },
      //         ),
      //         Padding(
      //           padding: const EdgeInsets.only(left: 50),
      //           child: TextFormField(
      //             keyboardType: TextInputType.text,
      //             decoration: InputDecoration(
      //               suffixIcon: IconButton(
      //                 icon: Icon(Icons.remove_circle_outline),
      //                 onPressed: () {
      //                   controller.text = "";
      //                 },
      //               ),
      //               hintText: hint,
      //             ),
      //             readOnly: true,
      //             controller: controller,
      //             //focusNode: focus,
      //             onFieldSubmitted: (value) {
      //               //FocusScope.of(context).requestFocus(dateFocus);
      //             },
      //             validator: isRequired ? (val) {
      //               if (val == "" || val == null || val.isEmpty) {
      //                 return 'Please insert ' + hint;
      //               }
      //               // valid info
      //               return null;
      //             } : null,
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      //   SizedBox(height: 20),
      //   _pressIcon[index]
      //       ? PickButton(
      //       optionsList: options, textController: controller, fontSize: 14.0)
      //       : SizedBox(height: 0,),
      // ],
      //),
    );
  }

  Widget _createTextFieldPickButton(BuildContext context, String hint, Icon icon, int index,
      TextEditingController controller, List<String> options, bool isRequired) {

    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[
                icon,
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      suffixIcon: !isRequired ? IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          controller.text = "";
                        },
                      ) : null,
                      hintText: hint,
                    ),
                    onTap: () {
                      setState(() {
                        if (_pressIcon[index]) {
                          //_fieldIcons[index] = Icon(Icons.keyboard_arrow_down_sharp);
                          _pressIcon[index] = false;
                        } else {
                          //_fieldIcons[index] = Icon(Icons.keyboard_arrow_up_sharp);
                          _pressIcon[index] = true;
                        }
                      });
                    } ,
                    readOnly: true,
                    controller: controller,
                    //focusNode: focus,
                    onFieldSubmitted: (value) {
                      //FocusScope.of(context).requestFocus(dateFocus);
                    },
                    validator: isRequired ? (val) {
                      if (val == "" || val == null || val.isEmpty || val == '0.0') {
                        return 'Please insert ' + hint;
                      }
                      // valid info
                      return null;
                    } : null,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          _pressIcon[index]
              ? PickButton(
              optionsList: options, textController: controller, fontSize: 14.0)
              : SizedBox(height: 0,),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {


    return AdminScaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: const Text('Animal Profile'),
            backgroundColor: Colors.lightBlue,
            actions: !algoInProgress ?
            [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_forward)
            ),
            ] : [] // if algorithm is running - no option to go back,,
        ),
        sideBar: buildSideBar(context),
        //body: _isFormSubmitted(context),
        body: Container(
          color: Colors.white,
          child: loading ? Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Text('Saving profile', style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                CircularProgressIndicator(color: Colors.orange,)
              ],
            ),
          ) : saved ? Center(
            child: Text('Profile saved',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),),

          ) : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 30.0, 20, 30),
              children: <Widget>[
                Center(
                  child: Text(
                    'Pet Image',
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                _createProfileImage(),
                _isImageValid(context),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget> [
                          Text(
                              'Breed:    ',
                              style : TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45
                              )
                          ),
                          Flexible(
                            child: Text(
                                breedClassification,
                                style : TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black
                                )
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      //validImage ?
                      Row(
                        children: <Widget> [
                          Text(
                              'Type:    ',
                              style : TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45
                              )
                          ),
                          Flexible(
                            child: Text(
                                typeClassification,
                                style : TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black
                                )
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _createTextFormField(
                          context,
                          "Name",
                          Icon(Icons.pets),
                          nameController,
                          nameFocus,
                          typeFocus,
                          TextInputType.name,
                          true),
                      SizedBox(height: 20),
                      _createTextFormField(
                          context,
                          "Age",
                          Icon(Icons.date_range_outlined),
                          ageController,
                          ageFocus,
                          locationFocus,
                          TextInputType.text,
                          true),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                _createTextFieldPickButton(
                    context, "Gender", Icon(Icons.wc_outlined, color: Colors.grey,), 0, genderController, ['Female', 'Male'],
                    true),
                //SizedBox(height: 10),
                _createTextFieldPickButton(
                    context, "Is Trained?", Icon(Icons.wb_incandescent_outlined, color: Colors.grey), 1, trainedController,
                    ['Trained', 'Not Trained'], false),
                //SizedBox(height: 10),
                _createTextFieldPickButton(context, "Size", Icon(Icons.photo_size_select_large_outlined, color: Colors.grey), 2, sizeController,
                    ['S', 'M', 'L'], true),
                //SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _createTextFormField(
                            context,
                            "Location",
                            Icon(Icons.location_on),
                            locationController,
                            locationFocus,
                            null,
                            TextInputType.text,
                            true),
                        //colors
                        SizedBox(height: 30),
                        Text(
                          'Colors',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 10),
                        DynamicTextField(
                          hint: "Color", fieldsController: colorsController,),
                        // qualities
                        SizedBox(height: 30),
                        Text('Qualities',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        DynamicTextField(hint: "Quality",
                          fieldsController: qualitiesController,),
                        SizedBox(height: 20),
                        _createTextFormField(
                            context,
                            "About Your Pet",
                            Icon(Icons.description_outlined),
                            descriptionController,
                            descriptionFocus,
                            null,
                            TextInputType.text,
                            false),
                      ]
                  ),
                ),
                SizedBox(height: 3),
                // loading ? CircularProgressIndicator()
                //     :
                // create the appropriate buttons after pressing edit or in the start - on registration
                _getActionButtons(context),
              ],
            ),
          )
        ),
      );

  }

  // Widget _isFormSubmitted(BuildContext context) {
  //   if (saving) {
  //     return CircularProgressIndicator();
  //   }
  //
  //
  //   return Container(
  //     color: Colors.white,
  //     child: Form(
  //       key: _formKey,
  //       child: ListView(
  //         padding: const EdgeInsets.fromLTRB(20, 30.0, 20, 30),
  //         children: <Widget>[
  //           Center(
  //             child: Text(
  //               'Pet Image',
  //               style: TextStyle(
  //                   fontSize: 16.0,
  //                   fontWeight: FontWeight.bold
  //               ),
  //             ),
  //           ),
  //           _createProfileImage(),
  //           _isImageValid(context),
  //           SizedBox(height: 20),
  //           Padding(
  //             padding: EdgeInsets.only(left: 20, right: 20),
  //             child: Column(
  //               children: [
  //                 Row(
  //                   children: <Widget> [
  //                     Text(
  //                         'Breed:    ',
  //                         style : TextStyle(
  //                             fontSize: 16.0,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.black45
  //                         )
  //                     ),
  //                     Flexible(
  //                       child: Text(
  //                           breedClassification,
  //                           style : TextStyle(
  //                               fontSize: 18.0,
  //                               fontWeight: FontWeight.bold,
  //                               color: Colors.black
  //                           )
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: 20),
  //                 //validImage ?
  //                 Row(
  //                   children: <Widget> [
  //                     Text(
  //                         'Type:    ',
  //                         style : TextStyle(
  //                             fontSize: 16.0,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.black45
  //                         )
  //                     ),
  //                     Flexible(
  //                       child: Text(
  //                           typeClassification,
  //                           style : TextStyle(
  //                               fontSize: 18.0,
  //                               fontWeight: FontWeight.bold,
  //                               color: Colors.black
  //                           )
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: 20),
  //                 _createTextFormField(
  //                     context,
  //                     "Name",
  //                     Icon(Icons.pets),
  //                     nameController,
  //                     nameFocus,
  //                     typeFocus,
  //                     TextInputType.name,
  //                     true),
  //                 SizedBox(height: 20),
  //                 _createTextFormField(
  //                     context,
  //                     "Age",
  //                     Icon(Icons.date_range_outlined),
  //                     ageController,
  //                     ageFocus,
  //                     locationFocus,
  //                     TextInputType.text,
  //                     true),
  //               ],
  //             ),
  //           ),
  //           SizedBox(height: 20),
  //           _createTextFieldPickButton(
  //               context, "Gender", Icon(Icons.wc_outlined, color: Colors.grey,), 0, genderController, ['Female', 'Male'],
  //               true),
  //           //SizedBox(height: 10),
  //           _createTextFieldPickButton(
  //               context, "Is Trained?", Icon(Icons.wb_incandescent_outlined, color: Colors.grey), 1, trainedController,
  //               ['Trained', 'Not Trained'], false),
  //           //SizedBox(height: 10),
  //           _createTextFieldPickButton(context, "Size", Icon(Icons.photo_size_select_large_outlined, color: Colors.grey), 2, sizeController,
  //               ['S', 'M', 'L'], true),
  //           //SizedBox(height: 10),
  //           Padding(
  //             padding: EdgeInsets.only(left: 20, right: 20),
  //             child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   _createTextFormField(
  //                       context,
  //                       "Location",
  //                       Icon(Icons.location_on),
  //                       locationController,
  //                       locationFocus,
  //                       null,
  //                       TextInputType.text,
  //                       true),
  //                   //colors
  //                   SizedBox(height: 30),
  //                   Text(
  //                     'Colors',
  //                     style: TextStyle(
  //                         fontSize: 16.0,
  //                         fontWeight: FontWeight.bold
  //                     ),
  //                   ),
  //                   SizedBox(height: 10),
  //                   DynamicTextField(
  //                     hint: "Color", fieldsController: colorsController,),
  //                   // qualities
  //                   SizedBox(height: 30),
  //                   Text('Qualities',
  //                     style: TextStyle(
  //                         fontSize: 16.0, fontWeight: FontWeight.bold),
  //                   ),
  //                   SizedBox(height: 10),
  //                   DynamicTextField(hint: "Quality",
  //                     fieldsController: qualitiesController,),
  //                   SizedBox(height: 20),
  //                   _createTextFormField(
  //                       context,
  //                       "About Your Pet",
  //                       Icon(Icons.description_outlined),
  //                       descriptionController,
  //                       descriptionFocus,
  //                       null,
  //                       TextInputType.text,
  //                       false),
  //                 ]
  //             ),
  //           ),
  //           //SizedBox(height: 20),
  //           _getActionButtons(context),
  //           // create the appropriate buttons after pressing edit or in the start - on registration
  //
  //         ],
  //       ),
  //     ),
  //   );
  //
  //
  // }


  Widget _isImageValid(BuildContext context) {
    if (algoInProgress) {
      return Column(
        children: <Widget> [
          Text(
              'We are checking your image',
              style : TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green
              )
          ),
          CircularProgressIndicator()
        ],
      );
    }

    if(!validImage) {
      print(_error);
      return Center(
        child: Text(_error.toString(),textAlign: TextAlign.center,
            style : TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.red
            )),
      );
    } else {
      print('approved');
      return Icon(Icons.assignment_turned_in_outlined, color: Colors.green);
    }

  }


  Future<void> openImagePicker({required ImageSource imageSource}) async {
    try{
      final pickedImage = await ImagePicker().getImage(source: imageSource, maxWidth: 512, maxHeight: 512);
      if (pickedImage == null) return; // if no image picked - not changing anything

      setState(() {
        _selectedImage = File(pickedImage.path);
        breedClassification = '';
        typeClassification = '';
      });

      // starting the algo to check if photo is valid
      await _checkPickedImage(context);

    } catch (e) {
      //print(e);
      _error = e.toString();
      _showError();
    }
  }


  void _showImageSourceActionSheet() {
    Function(ImageSource) selectImageSource = (imageSource) {
      openImagePicker(imageSource: imageSource);
    };

    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) =>
            CupertinoActionSheet(
              actions: [
                CupertinoActionSheetAction(
                  child: Text('Camera'),
                  onPressed: () {
                    Navigator.pop(context);
                    selectImageSource(ImageSource.camera);
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text('Gallery'),
                  onPressed: () {
                    Navigator.pop(context);
                    selectImageSource(ImageSource.gallery);
                  },
                ),
                (_selectedImage != null) ?
                CupertinoActionSheetAction(
                  child: Text('Remove Picture'),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      validImage = false;
                    });
                  },
                )
                    :
                Container(),
              ],
            ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) =>
            Wrap(children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  selectImageSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_album),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  selectImageSource(ImageSource.gallery);
                },
              ),
              (_selectedImage != null) ?
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Remove Picture'),
                onTap: () {
                  Navigator.pop(context);
                  // remove from db
                  setState(() {
                    _selectedImage = null;
                    validImage = false;
                  });
                },
              )
                  :
              Container(),
            ]),
      );
    }
  }



  Future<String> _convertImageToString() async {

    List<int> imageBytes = _selectedImage!.readAsBytesSync();
    print(imageBytes);
    var base64Image = base64Encode(imageBytes);
    print('finished convert to 64');
    return base64Image;

  }

  Future<Map<String, dynamic>> _classifyPickedImage() async {

    String image = await _convertImageToString();

    // transfer bytes
    Uri functionUrl = Uri.parse('https://europe-central2-take-a-pet.cloudfunctions.net/classify_image');

    print('URL '+ functionUrl.host);
    var jsonImage = {'image': image};
    print(image.length);

    try {
      var response = await http.post(functionUrl, body: jsonImage);
      var modelResult = json.decode(response.body);

      //var data= await json.decode(json.encode(response.databody);


      print(modelResult);
      print(modelResult.runtimeType);

      return modelResult;

    } catch (e) {
      print(e);
      throw Exception('Heavy traffic, please try again');

    }
  }

  Future<Map<String, dynamic>> _isAcceptedAnimal(String label) async {

    // cloud function
    Uri functionUrl = Uri.parse('https://europe-central2-take-a-pet.cloudfunctions.net/is_label_an_accepted_animal');

    print('URL '+ functionUrl.host);

    var jsonLabel = {'label': label};


    try {
      var response = await http.post(functionUrl, body: jsonLabel);
      var modelResult = json.decode(response.body);

      //var data= await json.decode(json.encode(response.databody);


      print(modelResult);
      print(modelResult.runtimeType);

      return modelResult;

    } catch (e) {
      print(e);
      throw e;
    }
  }


  Future<void> _checkIfAccepted(String label) async {
    print('_checkIfAccepted');
    print(label);

    try {
      setState(() {
        algoInProgress = true;
      });


      // check if the label is an accepted animal
      var acceptedResult = await _isAcceptedAnimal(label);

      setState(() {
        algoInProgress = false;
      });

      //classificationLabel = finalLabel;

      var finalOut = acceptedResult['message']; // animal type OR error

      var outVal = acceptedResult['outResult'];

      if(outVal == 'Error') {
        throw finalOut;
      }

      if(outVal == true) {
        // removing '_' from the label

        typeClassification = finalOut;
        setState(() {
          validImage = true;
        });

      } else {
        print('exception');
        throw acceptedResult['message'];
      }


    } catch (e) {
      // no valid image
      print(e);
      _error = e.toString();

      setState(() {
        algoInProgress = false;
        validImage = false;
      });

    }

  }

  Future<void> _checkPickedImage(BuildContext context) async {
    print('checking');
    // no new image selected
    if(_selectedImage == null) return;

    try {
      setState(() {
        algoInProgress = true;
        validImage = false;
      });

      var classificationResult = await _classifyPickedImage();
      setState(() {
        algoInProgress = false;
      });

      var finalLabel = classificationResult['label'];
      print(finalLabel);

      var outVal = classificationResult['isMultiple'];

      if(outVal == 'Error') {
        throw finalLabel;
      }

      if(outVal == true){
        BuildContext dialogContext;

        // finalLabel is a list
        // the user should choose his option from the list
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              dialogContext = context;
              // return WillPopScope(
              //   onWillPop: () => showExitPopup(context),
              //   //onWillPop: () { return Future.value(false); },
              //   child:
               return AlertDialog(
                  content: Container(
                    height: MediaQuery.of(context).size.height / 2,
                    child: Column(
                        children: [
                          Text('We couldn\'t decide.\n\nYour image is a:', textAlign: TextAlign.center ,style: TextStyle(fontWeight: FontWeight.bold),),
                          SizedBox(height: 20,),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              //var label = finalLabel[index].replaceAll('_', ' ');
                              return new ElevatedButton(
                                  onPressed: () {
                                    finalLabel = finalLabel[index];
                                    Navigator.pop(dialogContext);
                                  }, child: Text(finalLabel[index].replaceAll('_', ' ')));
                            },
                          ),
                        ]
                    ),
                  ),
                );
              //);
            });


      }

      breedClassification = finalLabel.replaceAll('_', ' ');


      _checkIfAccepted(finalLabel);


    } catch (e) {
      // no valid image
      print(e);
      _error = e.toString();

      setState(() {
        algoInProgress = false;
        validImage = false;
      });

    }

  }


}