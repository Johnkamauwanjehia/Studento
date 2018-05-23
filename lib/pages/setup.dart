import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';
import '../UI/subjects_list_select.dart';
import '../UI/setup_page.dart';
import '../util/shared_prefs_interface.dart';

class Setup extends StatefulWidget {
  Setup({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _SetupState createState() => new _SetupState();
}

class _SetupState extends State<Setup> {
  /// [TextEditingController] for the name [TextField].
  final TextEditingController nameController = TextEditingController();

  /// Error text that appears under the name [TextField] when there are issues.
  String errorText;

  /// pageIndex is used to fetch specific [SetupPage]s from the setupPages
  /// [List].
  int pageIndex = 0;

  /// The user's selected level.
  String selectedLevel;

  @override
  Widget build(BuildContext context) {
    return setupPages()[pageIndex];
  }

  /// Returns the list of setupPages.
  List<SetupPage> setupPages() {
    return [
      SetupPage(
        leadIcon: Icons.person_pin,
        title: "Introductions",
        subtitle: "How should we call you, awesome user?",
        body: _buildInfoBody(),
        onFloatingButtonPressed: validateAndPushSubjectsPage,
      ),
      SetupPage(
        leadIcon: Icons.book,
        title: "Subjects",
        subtitle: "Choose your subjects below:",
        body: SubjectsList(),
        onFloatingButtonPressed: validateAndPushSessionsPage,
      ),
      SetupPage(
        leadIcon: Icons.table_chart,
        title: "Sessions",
        subtitle: "Set up your school sessions/periods info",
        body: _buildSessionsBody(),
        onFloatingButtonPressed: pushPermissionsPage,
      ),
      SetupPage(
        leadIcon: Icons.lock,
        title: "Permissions",
        subtitle:
            "This app requires the following permissions in order to work at its best:",
        body: _buildPermissionsBody(),
        onFloatingButtonPressed: requestPermissionsAndPushHomePage,
      )
    ];
  }

  ListView _buildInfoBody() {
    InputDecoration nameTextFieldDeco = InputDecoration(
      errorStyle: TextStyle(color: Colors.redAccent),
      errorText: errorText,
      labelText: "Name",
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepPurpleAccent),
      ),
    );

    return ListView(children: <Widget>[
          TextFormField(
            controller: nameController,
            onSaved: SharedPreferencesHelper.setName,
            onFieldSubmitted: validateName,
            decoration: nameTextFieldDeco,
          ),
          Padding(padding: EdgeInsets.only(top: 25.0)),
          Text(
            "Which Cambridge International Examination are you taking part in?",
            style: TextStyle(color: Colors.black54),
          ),
          RadioListTile(
            title: Text("O Level"),
            value: "O level",
            groupValue: selectedLevel,
            selected: false,
            onChanged: (String level) {
              SharedPreferencesHelper.setLevel(level);
              setState(() {
                selectedLevel = level;
              });
            },
          ),
          RadioListTile(
            title: Text("A Level"),
            value: "A level",
            groupValue: selectedLevel,
            selected: false,
            onChanged: (String level) {
              SharedPreferencesHelper.setLevel(level);
              setState(() {
                selectedLevel = level;
              });
            },
          ),
    ]);
  }

  Widget _buildSessionsBody() {
    return ListView(
      children: <Widget>[
        SessionsLengthSlider(),
        NoOfSessionsSlider(),
      ],
    );
  }

  Widget _buildPermissionsBody() {
    return Column(children: <Widget>[
      ListTile(
        isThreeLine: true,
        leading: Icon(Icons.storage),
        title: Text("Storage"),
        subtitle: Column(children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 5.0)),
          Text(
            "For storing topic notes, past papers, pictures and more",
            textScaleFactor: 0.9,
            style: TextStyle(color: Colors.black54),
          ),
        ]),
      ),
    ]);
  }

  /// Check if name is empty, made up of only spaces or contains any digits.
  void validateName(String name) {
    if (name == null ||
        name.isEmpty ||
        name.replaceAll(' ', '').isEmpty ||
        name.contains(RegExp(r'\d+'))) {
      setState(
          () => errorText = "Your name doesn't look right. Please try again.");
    } else if (errorText != null) {
      setState(() => errorText = null);
    }
  }

  /// Pushes the [SetupPage] which is found at [pageIndex] in the [List]
  /// returned by [setupPages()]
  void pushNextPage(int pageIndex) {
    Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => setupPages()[pageIndex]),
        );
  }

  void validateAndPushSubjectsPage() {
    String msg;
    if (errorText != null) {
      msg = "The name you entered doesn't look right. Please try again.";
    } else if (selectedLevel == null) {
      msg = "Please fill out all the details first";
    }
    if (msg != null) {
      setState(() => errorText = msg);
    } else {
      pushNextPage(1);
    }
  }

  void validateAndPushSessionsPage() {
    SharedPreferencesHelper.getSubjectsList().then((List<String> subjectsList) {
      if (subjectsList != null) {
        pushNextPage(2);
      }
    });
  }

  void pushPermissionsPage() async{
    pushNextPage(3);
  }

  void requestPermissionsAndPushHomePage() async {
    bool result = false;

    while (result == false) {
      result = await SimplePermissions
          .requestPermission(Permission.WriteExternalStorage);
      print("permission request result is " + result.toString());
    }

    Navigator
        .of(context)
        .pushNamedAndRemoveUntil('home_page', ModalRoute.withName('home_page'));
    // We no longer need to show setup pages to user.
    SharedPreferencesHelper.setIsFirstRun(true);
  }
}

/// Slider for setting the length of each user's session/period.
class SessionsLengthSlider extends StatefulWidget {
  @override
  _SessionsLengthSliderState createState() => new _SessionsLengthSliderState();
}

class _SessionsLengthSliderState extends State<SessionsLengthSlider> {
  String sessionLength = "30.0";

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10.0, top: 15.0),
          child: Text(
            "How long are the sessions/periods at your school?",
            textScaleFactor: 1.2,
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
        Center(
          child: Text(
            "$sessionLength mins",
            textScaleFactor: 1.2,
            style: TextStyle(color: Colors.black45),
          )
        ),
        Slider(
          min: 15.0,
          max: 45.0,
          activeColor: Colors.deepPurpleAccent,
          inactiveColor: Colors.black54,
          divisions: 6,
          label: "$sessionLength",
          value: double.parse(sessionLength),
          onChanged: saveSessionsLength,
        ),
      ],
    );
  }

  /// Updates the session length in both the slider and in shared_prefs.
  void saveSessionsLength(double length){
    String _length = length.toString();

    SharedPreferencesHelper.setSessionLength(_length);
    setState(() => sessionLength = _length);
  }
}

/// Slider for setting the number of sessions in a school day.
class NoOfSessionsSlider extends StatefulWidget {
  @override
  _NoOfSessionsSliderState createState() => new _NoOfSessionsSliderState();
}

class _NoOfSessionsSliderState extends State<NoOfSessionsSlider> {
  int noOfSessions = 8;
  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 15.0, top: 15.0),
          child: Text(
            "How many sessions/periods do you have in a day?",
            textScaleFactor: 1.2,
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
        Center(
          child: Text(
            "$noOfSessions",
            textScaleFactor: 1.2,
            style: TextStyle(color: Colors.black45),
          )
        ),
        Slider(
          min: 6.0,
          max: 12.0,
          activeColor: Colors.deepPurpleAccent,
          inactiveColor: Colors.black54,
          divisions: 6,
          label: "$noOfSessions",
          value: noOfSessions.toDouble(),
          onChanged: saveNoOfSessions,
        ),
      ],
    );
  }

  /// Set the number of sessions in both the slider and shared_prefs.
  void saveNoOfSessions(double no){
    SharedPreferencesHelper.setNoOfSessions(no.toInt());
    setState(() => noOfSessions = no.toInt());
  }
}
