import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:db_mcp_demo_flutter_app/chat_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisiere Firebase
  await Firebase.initializeApp();
  
  // Automatischer anonymer Login für die Demo
  try {
    await FirebaseAuth.instance.signInAnonymously();
    print("Erfolgreich anonym eingeloggt");
  } catch (e) {
    print("Fehler beim Firebase Login: $e");
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF135BEC);
    const Color backgroundDark = Color(0xFF101622);
    const Color backgroundLight = Color(0xFFF6F6F8);

    final TextTheme darkTextTheme = GoogleFonts.spaceGroteskTextTheme(
      ThemeData.dark().textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
    );
    
    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        surface: backgroundDark,
        primary: primaryColor,
      ),
      textTheme: darkTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[400]),
        titleTextStyle: darkTextTheme.titleLarge, 
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );

    final TextTheme lightTextTheme = GoogleFonts.spaceGroteskTextTheme(ThemeData.light().textTheme);

    final ThemeData lightTheme = ThemeData(
       useMaterial3: true,
       brightness: Brightness.light,
       scaffoldBackgroundColor: backgroundLight,
       primaryColor: primaryColor,
       colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        surface: backgroundLight,
      ),
       textTheme: lightTextTheme,
       appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[600]),
        titleTextStyle: lightTextTheme.titleLarge?.copyWith(color: Colors.black), 
       ),
        elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'TrainAI Assistant',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const WelcomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark ? const Color(0xFF101622) : const Color(0xFFF6F6F8);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.train, color: Theme.of(context).primaryColor, size: 30),
            const SizedBox(width: 8),
            Text(
              'TrainAI',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.1,
            left: -MediaQuery.of(context).size.width * 0.2,
            child: _buildBlurCircle(MediaQuery.of(context).size.width * 0.8, MediaQuery.of(context).size.height * 0.4, Theme.of(context).primaryColor.withOpacity(0.2)),
          ),
           Positioned(
            bottom: -MediaQuery.of(context).size.height * 0.1,
            right: -MediaQuery.of(context).size.width * 0.2,
            child: _buildBlurCircle(MediaQuery.of(context).size.width * 0.6, MediaQuery.of(context).size.height * 0.3, Colors.blue.withOpacity(0.1)),
          ),

          // Main Content
          LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Hero Section
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildHeroImage(),
                          const SizedBox(height: 24),
                          _buildHeroText(context),
                        ],
                      ),
                      
                      // Action Area
                      _buildActionArea(context),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(double width, double height, Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
        child: Container(),
      ),
    );
  }

  Widget _buildHeroImage() {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
        decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(16),
           boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.25),
               blurRadius: 30,
               offset: const Offset(0, 15),
             )
           ]
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/hero_train.jpg',
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      const Color(0xFF101622).withOpacity(0.9),
                    ],
                    stops: const [0, 0.5, 1],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101622).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Live Status Active',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroText(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.spaceGrotesk(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: isDark ? Colors.white : Colors.grey[900],
              letterSpacing: -1,
            ),
            children: [
              const TextSpan(text: 'Master the Rails\n'),
              TextSpan(
                text: 'Effortlessly',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Your Personal Deutsche Bahn Expert. Real-time delays, route planning, and expert travel tips at your fingertips.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionArea(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          _buildFeaturesGrid(isDark),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Start Chatting'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 16),
           Text(
            'Powered by Gemini & DB API',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(bool isDark) {
    final Color tileColor = isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.grey[200]!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFeatureTile(isDark, tileColor, Icons.schedule, 'Delays'),
        const SizedBox(width: 8),
        _buildFeatureTile(isDark, tileColor, Icons.alt_route, 'Routes'),
        const SizedBox(width: 8),
        _buildFeatureTile(isDark, tileColor, Icons.tips_and_updates, 'Tips'),
      ],
    );
  }

  Widget _buildFeatureTile(bool isDark, Color tileColor, IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 28),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: isDark ? Colors.grey[400] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
