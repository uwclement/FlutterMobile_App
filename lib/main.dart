import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app_flutter/pages/battery_service.dart';
import 'package:mobile_app_flutter/pages/connectivity_service.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app_flutter/pages/Calculator.dart';
import 'package:mobile_app_flutter/pages/NavDrawer.dart';
import 'package:mobile_app_flutter/pages/SignIn.dart';
import 'package:mobile_app_flutter/pages/SignUp.dart';
import 'package:mobile_app_flutter/pages/theme_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ConnectivityService()),
        ChangeNotifierProvider(create: (context) => BatteryService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Tab Navigation Demo',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 18, 57, 142),
            ),
            useMaterial3: true,
          ),
          themeMode:
          themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _previousConnectionStatus = true;

  static final List<Widget> _widgetOptions = <Widget>[
    const SignIn(),
    const SignUp(),
    const Calculator(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    Provider.of<ConnectivityService>(context, listen: false).initConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false)
                  .toggleTheme();
            },
          ),
        ],
      ),
      drawer: NavDrawer(onItemSelected: _onItemTapped),
      body: Consumer<ConnectivityService>(
        builder: (context, connectivityService, child) {
          if (_previousConnectionStatus != connectivityService.isConnected) {
            _previousConnectionStatus = connectivityService.isConnected;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Fluttertoast.showToast(
                msg: connectivityService.isConnected
                    ? "Connected to the Internet"
                    : "No Internet Connection",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: connectivityService.isConnected ? Colors.green : Colors.red,
                textColor: Colors.white,
              );
            });
          }
          return Stack(
            children: [
              Center(
                child: _widgetOptions.elementAt(_selectedIndex),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: connectivityService.isConnected ? 0 : 30,
                  color: Colors.red,
                  child: Center(
                    child: Text(
                      'No Internet Connection',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Sign In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Sign Up',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        onTap: _onItemTapped,
      ),
    );
  }
}