import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/pages/components/notification_controller.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async {
  await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelGroupKey: "basic_channel_group",
            channelKey: "Basic Notification",
            channelName: "Basic Notification",
            channelDescription: "Basic Notification channel")
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: "basic_channel_group",
            channelGroupName: "Basic Group")
      ],
      debug: true);
  bool isAllowedToSendNotification =
      await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedToSendNotification) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final Set<String> notifiedDocuments = Set<String>();

 @override
void initState() {
  super.initState();

  // Set up notification listeners
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
    onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
    onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod,
  );

  // Listen for changes in the registrations collection
FirebaseFirestore.instance
  .collection('registrations')
  .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
  .snapshots()
  .listen((snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.modified &&
          change.doc['status'] == true &&
          !notifiedDocuments.contains(change.doc.id)) {
        
        // Assuming 'lockerNumber' is a field in your document
        int lockerNumber = change.doc['lockerNumber'] ?? -1;  // -1 or some error value

        // Trigger a notification including locker number
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            channelKey: 'Basic Notification',
            title: 'Package Delivered',
            body: 'Your package has been delivered to Locker $lockerNumber.',
          ),
        );

        // Add the document ID to the set of notified documents
        notifiedDocuments.add(change.doc.id);
      }
    }
});
}
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}

