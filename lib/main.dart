import 'package:flutter/material.dart';
// import 'package:kiosk_test_app/device_info.dart';
import 'package:kiosk_test_app/display.dart';
// import 'package:kiosk_test_app/mac_address.dart';
import 'package:kiosk_test_app/model/database_helper.dart';

final dbHelper = DatabaseHelper();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize the database
  await dbHelper.init();

  // Fetch data from the database and get the URL with ID 1
  final data = await dbHelper.findOne(1);
  String videoUrl = data?[DatabaseHelper.columnUrl] ?? '';

  runApp(MyApp(videoUrl: videoUrl));
}

class MyApp extends StatelessWidget {
  final String videoUrl;

  const MyApp({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Selamat Datang Di KIOSK'),
          backgroundColor: Colors.amberAccent,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Image.network(
                  'https://x6t2.c10.e2-2.dev/s3bucket/Buzzer.gif'),
            ),
            Expanded(
              child: VideoPlayerScreen1(
                videoLink: videoUrl,
              ),
            ),
            Expanded(
              child: Image.network(
                  'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif'),
            ),
          ],
        ),
      ),
    );
  }

//   Future<void> _insert() async {
//     // row to insert
//     Map<String, dynamic> row = {
//       DatabaseHelper.columnName: 'pusat',
//       DatabaseHelper.columnUrl: 'https://x6t2.c10.e2-2.dev/s3bucket/Sprite.mp4',
//     };
//     final id = await dbHelper.insert(row);
//     debugPrint('Inserted row id: $id');
//   }

//   Future<void> _refreshData() async {
//     // You can perform any data fetching or refreshing logic here
//     // For example, refetch the data from the database
//     final allRows = await dbHelper.queryAll();
//     debugPrint('Refreshed data:');
//     for (final row in allRows) {
//       debugPrint(row.toString());
//     }
//   }

//   Future<void> _checkById(int value) async {
//     final data = await dbHelper.findOne(value);
//     debugPrint('this data for: $data');
//   }

//   void _update(int id) async {
//     // row to update
//     Map<String, dynamic> row = {
//       DatabaseHelper.columnId: '$id',
//       DatabaseHelper.columnName: 'pusat',
//       DatabaseHelper.columnUrl:
//           'https://kiosk-server.apidev.lol/video/Buzzer.mp4'
//     };
//     final rowsAffected = await dbHelper.update(row);
//     debugPrint('updated $rowsAffected row(s)');
//   }
}
