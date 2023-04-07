import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kamus_investasi/pages/bookmark.dart';
import 'package:kamus_investasi/pages/feedback.dart';
import 'package:kamus_investasi/pages/history.dart';
import 'package:kamus_investasi/pages/home.dart';
import 'package:kamus_investasi/utils/datasets.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kamus Trading',
      theme: ThemeData(
        textTheme: GoogleFonts.ralewayTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: UpgradeAlert(
        upgrader: Upgrader(
            showIgnore: false, showLater: false, showReleaseNotes: false),
        child: const MyHomePage(),
      ),
      // home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool isInitializeDatasets = true;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future setupDatasets() async {
    DataSets dataSets = DataSets();
    bool result = await dataSets.initDictionaries();
    setState(() {
      isInitializeDatasets = result;
    });
  }

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    BookmarkScreen(),
    HistoryScreen(),
    FeedbackScreen(),
  ];

  @override
  void initState() {
    setupDatasets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !isInitializeDatasets
        ? Scaffold(
            body: _widgetOptions.elementAt(_selectedIndex),
            bottomNavigationBar: BottomNavigationBar(
              // showSelectedLabels: false,
              // showUnselectedLabels: false,
              backgroundColor: Colors.white,
              selectedFontSize: 12,
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Container(
                      margin: EdgeInsets.only(bottom: 3),
                      child: Icon(Iconsax.home)),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                      margin: EdgeInsets.only(bottom: 3),
                      child: Icon(Iconsax.bookmark)),
                  label: 'Bookmark',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                      margin: EdgeInsets.only(bottom: 3),
                      child: Icon(Iconsax.repeat_circle)),
                  label: 'Riwayat',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                      margin: EdgeInsets.only(bottom: 3),
                      child: Icon(Iconsax.message)),
                  label: 'Feedback',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Color.fromRGBO(14, 17, 17, 1),
              onTap: _onItemTapped,
            ),
          )
        : Scaffold(
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Color.fromRGBO(14, 17, 17, 1),
                ),
                SizedBox(
                  height: 20,
                ),
                Text('Loading 👾',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800)),
                SizedBox(
                  height: 5,
                ),
                Text('Mohon tunggu...', style: TextStyle(color: Colors.grey)),
              ],
            )),
          );
  }
}
