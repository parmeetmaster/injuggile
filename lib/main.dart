import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:service_app/providers/auth.dart';
import 'package:service_app/providers/customer.dart';
import 'package:service_app/providers/jobs_provider.dart';
import 'package:service_app/screens/artist_applied_jobs_screen.dart';
import 'package:service_app/screens/artist_bookings_screen.dart';
import 'package:service_app/screens/artist_change_password_screen.dart';
import 'package:service_app/screens/artist_current_bookings_screen.dart';
import 'package:service_app/screens/artist_profile_screen.dart';
import 'package:service_app/screens/chats_screen.dart';
import 'package:service_app/screens/choose_user_screen.dart';
import 'package:service_app/screens/edit_artist_profile_screen.dart';
import 'package:service_app/screens/forget_password_screen.dart';
import 'package:service_app/screens/home_screen.dart';
import 'package:service_app/screens/my_booking_screen.dart';
import 'package:service_app/screens/my_earnings_screen.dart';
import 'package:service_app/screens/my_wallet_screen.dart';
import 'package:service_app/screens/near_by_screen.dart';
import 'package:service_app/screens/notifications_screen.dart';
import 'package:service_app/screens/customer_profile_screen.dart';
import 'package:service_app/screens/payment_screen.dart';
import 'package:service_app/screens/phone_auth_screen.dart';
import 'package:service_app/screens/post_job_screen.dart';
import 'package:service_app/screens/receipt_details_screen.dart';
import 'package:service_app/screens/receipt_screen.dart';
import 'package:service_app/screens/search_jobs_screen.dart';
import 'package:service_app/screens/set_location_screen.dart';
import 'package:service_app/screens/splash_screen.dart';
import 'package:service_app/screens/terms_screen.dart';
import 'package:service_app/screens/tickets_screen.dart';
import 'package:service_app/screens/update_job_screen.dart';
import 'package:service_app/screens/widgets/custom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

// final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// new FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.max,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _flutterLocalNotificationsPlugin(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

String fcmToken;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_flutterLocalNotificationsPlugin);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );

  FirebaseMessaging.instance.getToken().then((value) {
    fcmToken = value;
    print('FCM token for FirebaseMessaging $fcmToken');
    // token!.printwtf; // print fcm token
  });

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isInit = true;

  @override
  void initState() {
    // var initializationSettingsAndroid =
    //     new AndroidInitializationSettings('@mipmap/ic_launcher');
    // var initializationSettingsIOS = new IOSInitializationSettings();
    // var initializationSettings = new InitializationSettings(
    //   android: initializationSettingsAndroid,
    //   iOS: initializationSettingsIOS,
    // );
    // flutterLocalNotificationsPlugin.initialize(initializationSettings,
    //     onSelectNotification: onSelectNotification);
    print('((((((((((((((((((((($fcmToken)))))))))))))))))))))');
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: android.smallIcon,
                playSound: true,
                // other properties...
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp event will published');
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('${notification.title}'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${notification.body}'),
                ],
              ),
            );
          },
        );
      }
    },);
    // _firebaseMessaging.requestNotificationPermissions();
    // _firebaseMessaging.configure(
    //   onMessage: (message) async {
    //     print('onMessage: $message');
    //     showNotification(
    //       message['data'] != null
    //           ? message['data']['title'] ?? 'Service App'
    //           : 'Service App',
    //       message['data'] != null
    //           ? message['data']['body'] ?? 'Service App'
    //           : 'Service App',
    //     );
    //   },
    //   onResume: (message) async {
    //     print('onResume: $message');
    //   },
    //   onLaunch: (message) async {
    //     print('onLaunch: $message');
    //   },
    // );
  }

  Future onSelectNotification(String text) async {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Mark"),
          content: Text("Mark : $text"),
        );
      },
    );
  }

  void showNotification(String title, String body) async {
    await _demoNotification(title, body);
  }

  Future<void> _demoNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_ID', 'channel name', 'channel description',
        importance: Importance.max,
        playSound: true,
        showProgress: true,
        priority: Priority.high,
        ticker: 'test ticker');

    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'test');
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      SharedPreferences.getInstance().then((prefs) {
        if (prefs.containsKey('token')) {
          isInit = false;
          return;
        }
        FirebaseMessaging.instance.getToken().then((value) async {
          prefs.setString('token', value);
          print('Token: $value');
          isInit = false;
        });
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, JobProvider>(
          create: (_) => JobProvider(),
          update: (_, auth, previousProvider) {
            previousProvider
              ..userId = auth.currentUser != null ? auth.currentUser.id : null;
            return previousProvider;
          },
        ),
        ChangeNotifierProxyProvider<Auth, Customer>(
          create: (_) => Customer(),
          update: (_, auth, previousCustomer) {
            previousCustomer
              ..userId = auth.currentUser != null ? auth.currentUser.id : null;
            return previousCustomer;
          },
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Service App',
          theme: ThemeData(
            primarySwatch: Colors.cyan,
            accentColor: Colors.amber,
            errorColor: Colors.red,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Poppins',
            textTheme: ThemeData.light().textTheme.copyWith(
                  headline6: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                  button: TextStyle(color: Colors.white),
                ),
            appBarTheme: AppBarTheme(
              textTheme: ThemeData.light().textTheme.copyWith(
                    headline6: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      fontSize: 18,
                    ),
                  ),
            ),
          ),
          routes: {
            CustomerProfileScreen.routeName: (ctx) => CustomerProfileScreen(),
            ChatsScreen.routeName: (ctx) => ChatsScreen(),
            MyBookingScreen.routeName: (ctx) => MyBookingScreen(),
            ReceiptScreen.routeName: (ctx) => ReceiptScreen(),
            SearchJobsScreen.routeName: (ctx) => SearchJobsScreen(),
            MyWalletScreen.routeName: (ctx) => MyWalletScreen(),
            NotificationsScreen.routeName: (ctx) => NotificationsScreen(),
            SetLocationScreen.routeName: (ctx) => SetLocationScreen(),
            PostJobScreen.routeName: (ctx) => PostJobScreen(),
            NearByScreen.routeName: (ctx) => NearByScreen(),
            ReceiptDetailsScreen.routeName: (ctx) => ReceiptDetailsScreen(),
            PaymentScreen.routeName: (ctx) => PaymentScreen(),
            UpdateJobScreen.routeName: (ctx) => UpdateJobScreen(),
            ForgetPasswordScreen.routeName: (ctx) => ForgetPasswordScreen(),
            TermsScreen.routeName: (ctx) => TermsScreen(),
            ArtistAppliedJobsScreen.routeName: (ctx) =>
                ArtistAppliedJobsScreen(),
            ArtistCurrentBookingsScreen.routeName: (ctx) =>
                ArtistCurrentBookingsScreen(),
            ArtistBookingsScreen.routeName: (ctx) => ArtistBookingsScreen(),
            ArtistProfileScreen.routeName: (ctx) => ArtistProfileScreen(),
            ArtistChangePasswordScreen.routeName: (ctx) =>
                ArtistChangePasswordScreen(),
            EditArtistProfileScreen.routeName: (ctx) =>
                EditArtistProfileScreen(),
            MyEarningsScreen.routeName: (ctx) => MyEarningsScreen(),
            TicketsScreen.routeName: (ctx) => TicketsScreen(),
            PhoneAuthScreen.routeName: (ctx) => PhoneAuthScreen(),
          },
          home: auth.isAuth
              ? CustomDrawer(child: HomeScreen())
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : ChooseUserScreen(),
                ),
        ),
      ),
    );
  }
}
