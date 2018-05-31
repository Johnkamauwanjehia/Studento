import 'package:flutter/material.dart';
import '../UI/studento_app_bar.dart';
import '../util/shared_prefs_interface.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>  with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool isScheduleSet;
  List<Widget> dayTabs = [
    Tab(text: "Mon"),
    Tab(text: "Tues"),
    Tab(text: "Wed"),
    Tab(text: "Thurs"),
    Tab(text: "Fri"),
  ];

  @override
  initState(){
    super.initState();
    SharedPreferencesHelper
      .getIsScheduleSet()
      .then(
        (bool _isScheduleSet) => isScheduleSet = _isScheduleSet
    );
    _tabController = TabController(
      length: dayTabs.length,
      vsync: this,
      // The initial tab should be on the current day, unless if it's the
      // weekend. In that case we should show the schedule for the next Monday.
      initialIndex: DateTime.now().weekday > 5 ? 0 : DateTime.now().weekday
      );
  }

  @override
  dispose(){
    _tabController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    //Contains the layout of the page.
    return Scaffold(
      appBar: StudentoAppBar(
        title: "Schedule",
        bottom: TabBar(
          controller: _tabController,
          tabs: dayTabs,
          indicatorColor: Colors.blue.shade400,
        ),
      ),
      body: ListView(
          children: getClasses(),
      ),
    );
  }

  List<Widget> getClasses() {
    if (isScheduleSet == true){
      return [Text("...")];
    } else {
      return [
        Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.all(25.0),),
            Text("You haven't added your schedule yet.", textScaleFactor: 1.4,),
            Padding(padding: EdgeInsets.all(20.0),),
            FlatButton.icon(
              color: Theme.of(context).accentColor,
              onPressed: (){print("You clicked this button");},
              icon: Icon(Icons.schedule),
              label: Text("Configure Schedule"),
            ),
          ],
        )
      ];
    }
  }

}


// // Copyright 2015 The Chromium Authors. All rights reserved.
// // Use of this source code is governed by a BSD-style license that can be
// // found in the LICENSE file.

// import 'package:flutter/material.dart';

// enum TabsDemoStyle {
//   iconsAndText,
//   iconsOnly,
//   textOnly
// }

// class _Page {
//   const _Page({ this.icon, this.text });
//   final IconData icon;
//   final String text;
// }

// const List<_Page> _allPages = const <_Page>[
//   const _Page(icon: Icons.grade, text: 'TRIUMPH'),
//   const _Page(icon: Icons.playlist_add, text: 'NOTE'),
//   const _Page(icon: Icons.check_circle, text: 'SUCCESS'),
//   const _Page(icon: Icons.question_answer, text: 'OVERSTATE'),
//   const _Page(icon: Icons.sentiment_very_satisfied, text: 'SATISFACTION'),
//   const _Page(icon: Icons.camera, text: 'APERTURE'),
//   const _Page(icon: Icons.assignment_late, text: 'WE MUST'),
//   const _Page(icon: Icons.assignment_turned_in, text: 'WE CAN'),
//   const _Page(icon: Icons.group, text: 'ALL'),
//   const _Page(icon: Icons.block, text: 'EXCEPT'),
//   const _Page(icon: Icons.sentiment_very_dissatisfied, text: 'CRYING'),
//   const _Page(icon: Icons.error, text: 'MISTAKE'),
//   const _Page(icon: Icons.loop, text: 'TRYING'),
//   const _Page(icon: Icons.cake, text: 'CAKE'),
// ];

// class SchedulePage extends StatefulWidget {
//   static const String routeName = '/material/scrollable-tabs';

//   @override
//   SchedulePageState createState() => new SchedulePageState();
// }

// class SchedulePageState extends State<SchedulePage> with SingleTickerProviderStateMixin {
//   TabController _controller;
//   TabsDemoStyle _demoStyle = TabsDemoStyle.iconsAndText;
//   bool _customIndicator = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = new TabController(vsync: this, length: _allPages.length);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void changeDemoStyle(TabsDemoStyle style) {
//     setState(() {
//       _demoStyle = style;
//     });
//   }

//   Decoration getIndicator() {
//     if (!_customIndicator)
//       return const UnderlineTabIndicator();

//     switch(_demoStyle) {
//       case TabsDemoStyle.iconsAndText:
//         return new ShapeDecoration(
//           shape: const RoundedRectangleBorder(
//             borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
//             side: const BorderSide(
//               color: Colors.white24,
//               width: 2.0,
//             ),
//           ) + const RoundedRectangleBorder(
//             borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
//             side: const BorderSide(
//               color: Colors.transparent,
//               width: 4.0,
//             ),
//           ),
//         );

//       case TabsDemoStyle.iconsOnly:
//         return new ShapeDecoration(
//           shape: const CircleBorder(
//             side: const BorderSide(
//               color: Colors.white24,
//               width: 4.0,
//             ),
//           ) + const CircleBorder(
//             side: const BorderSide(
//               color: Colors.transparent,
//               width: 4.0,
//             ),
//           ),
//         );

//       case TabsDemoStyle.textOnly:
//         return new ShapeDecoration(
//           shape: const StadiumBorder(
//             side: const BorderSide(
//               color: Colors.white24,
//               width: 2.0,
//             ),
//           ) + const StadiumBorder(
//             side: const BorderSide(
//               color: Colors.transparent,
//               width: 4.0,
//             ),
//           ),
//         );
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Color iconColor = Theme.of(context).accentColor;
//     return new Scaffold(
//       appBar: new AppBar(
//         title: const Text('Scrollable tabs'),
//         actions: <Widget>[
//           new IconButton(
//             icon: const Icon(Icons.sentiment_very_satisfied),
//             onPressed: () {
//               setState(() {
//                 _customIndicator = !_customIndicator;
//               });
//             },
//           ),
//           new PopupMenuButton<TabsDemoStyle>(
//             onSelected: changeDemoStyle,
//             itemBuilder: (BuildContext context) => <PopupMenuItem<TabsDemoStyle>>[
//               const PopupMenuItem<TabsDemoStyle>(
//                 value: TabsDemoStyle.iconsAndText,
//                 child: const Text('Icons and text')
//               ),
//               const PopupMenuItem<TabsDemoStyle>(
//                 value: TabsDemoStyle.iconsOnly,
//                 child: const Text('Icons only')
//               ),
//               const PopupMenuItem<TabsDemoStyle>(
//                 value: TabsDemoStyle.textOnly,
//                 child: const Text('Text only')
//               ),
//             ],
//           ),
//         ],
//         bottom: new TabBar(
//           controller: _controller,
//           isScrollable: true,
//           indicator: getIndicator(),
//           tabs: _allPages.map((_Page page) {
//             switch (_demoStyle) {
//               case TabsDemoStyle.iconsAndText:
//                 return new Tab(text: page.text, icon: new Icon(page.icon));
//               case TabsDemoStyle.iconsOnly:
//                 return new Tab(icon: new Icon(page.icon));
//               case TabsDemoStyle.textOnly:
//                 return new Tab(text: page.text);
//             }
//           }).toList(),
//         ),
//       ),
//       body: new TabBarView(
//         controller: _controller,
//         children: _allPages.map((_Page page) {
//           return new SafeArea(
//             top: false,
//             bottom: false,
//             child: new Container(
//               key: new ObjectKey(page.icon),
//               padding: const EdgeInsets.all(12.0),
//               child: new Card(
//                 child: new Center(
//                   child: new Icon(
//                     page.icon,
//                     color: iconColor,
//                     size: 128.0,
//                     semanticLabel: 'Placeholder for ${page.text} tab',
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }).toList()
//       ),
//     );
//   }
// }