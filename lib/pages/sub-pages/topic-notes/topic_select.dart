import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../UI/studento_app_bar.dart';
import '../../../util/jaguar_laucher.dart';
import '../../../util/shared_prefs_interface.dart';

class TopicSelectPage extends StatefulWidget {
  final String selectedSubject;
  final String level;
  TopicSelectPage(this.selectedSubject, this.level);

  @override
  _TopicSelectPageState createState() => _TopicSelectPageState();
}

class _TopicSelectPageState extends State<TopicSelectPage> {
  List topicsList;
  String subjectCode;

  @override
  void initState() {
    super.initState();
    JaguarLauncher.startLocalServer(serverPort: 8090);
    getTopicsList();
    getSubjectCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Stack(children: <Widget>[
          _getTopicsListView(),
          _getBackground(),
          _getGradient(),
          _getToolbar(context),
        ]),
      ),
    );
  }

  void getSubjectCode() async{
    List<String> subjectCodesList = await SharedPreferencesHelper.getSubjectsCodesList();
    List<String> subjectsList = await SharedPreferencesHelper.getSubjectsList();

    int indexOfSubjectCode = subjectsList.indexOf(widget.selectedSubject);
    subjectCode  = subjectCodesList[indexOfSubjectCode];
  }

  void getTopicsList() async {
    var _topicsList;
    String _topicsListData =
        await rootBundle.loadString('assets/json/subjects_topic_lists.json');
    Map topicsListData = json.decode(_topicsListData);

    try {
      _topicsList =
          topicsListData[widget.selectedSubject]['topic_list']['${widget.level}'];
    } catch (e) {
      showNotesNotFoundDialog();
    }
    setState(() => topicsList = _topicsList);
  }

  Widget _getBackground() {
    final Widget subjectNameAndNoOfTopicsContainer = Container(
      constraints: BoxConstraints.expand(height: 250.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: (topicsList == null)
          ? <Widget>[CircularProgressIndicator()]
          : <Widget>[
            Text(
              "${widget.selectedSubject}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Mina',
                color: Colors.white,
                fontSize: 30.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 4.0),
            ),
            Text(
              "${topicsList.length} topics",
              style: TextStyle(
                color: Color(0xFFFefefe),
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
      ),
    );

    // TODO Turn this into a SliverAppBar for better mobility.
    // Also, instead of the background image let's get some fancy animation
    // like https://www.youtube.com/watch?v=MAET-z1apKA on a dark purple
    // background or the like.
    return Stack(
      children: <Widget>[
        Container(
          constraints: BoxConstraints.expand(height: 250.0),
          child: Image.asset(
            "assets/images/physics-background-img.jpg", //subject.picture,
            fit: BoxFit.cover,
            height: 300.0,
          ),
        ),
        subjectNameAndNoOfTopicsContainer,
      ],
    );
  }

  Widget _getGradient() {
    return Container(
      height: 90.0,
      margin: EdgeInsets.only(top: 160.0),
      decoration: BoxDecoration(
          gradient: LinearGradient(
        stops: [0.0, 1.0],
        begin: FractionalOffset(0.0, 0.0),
        end: FractionalOffset(0.0, 1.0),
        colors: <Color>[
          Color(0),
          Colors.white,
        ],
      )),
    );
  }

  void _handleSelectedTopic(String selectedTopic) {
    print("you selected $selectedTopic");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WebviewScaffold(
          url: 'http://localhost:8090/html/topic-notes/$subjectCode/$selectedTopic.html',
          withZoom: true,
          appBar: StudentoAppBar(title: "View Topic"),
        ),
      ),
    );
  }

  /// Returns a [ListView] that contains [ListTiles] for each available
  /// topic.
  Widget _getTopicsListView() {
    // If the topic list is still being loaded or happens to be empty,
    // show a [CircularProgressIndicator].
    if (topicsList == null) {
      return CircularProgressIndicator();
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(0.0, 250.0, 0.0, 32.0),
      itemCount: topicsList.length,
      itemBuilder: (BuildContext context, int index) {
        String topicName = topicsList[index];
        return Column(children: <Widget>[
          Divider(),
          ListTile(
            title: Text(topicName),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16.0,
            ),
            enabled: true,
            onTap: () => _handleSelectedTopic(topicName),
          ),
        ]);
      },
    );
  }

  Container _getToolbar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: BackButton(color: Colors.white),
    );
  }

  /// Despite the vastness of the internet, we have not managed to find notes
  /// for some topics, and in some cases, for entire subjects. So when a user
  /// tries to tap on a subject/topic which does not have any notes, we show an
  /// [AlertDialog] explaining the situation.
  ///
  /// (S)he can then file an issue or maybe even a PR. If the issue is popular,
  /// developers will put in added effort to find notes as per the request.
  Future<Null> showNotesNotFoundDialog() {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sorry!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 12.0)),
                Text('''No notes for this topic or subject :(
\nThe good news is that you can request for it by filing an issue.'''),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('FILE ISSUE'),
              onPressed: () async {
                const url = 'https://github.com/MaskyS/studento/issues/';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not open $url. Check your internet connection and try again.';
                }
              },
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () => Navigator.popUntil(
                context, ModalRoute.withName('/')
              ),
            ),
          ],
        );
      },
    );
  }
}
