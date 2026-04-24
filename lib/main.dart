import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:world_casa/views/widgets/CartScreen.dart';
import 'package:world_casa/views/widgets/CatalogScreen.dart';
import 'package:world_casa/views/widgets/HomeScreen.dart';
import 'package:world_casa/views/widgets/ProfileScreen.dart';
import 'package:world_casa/views/widgets/WishListScreen.dart';
import 'package:world_casa/views/widgets/lear_flutter.dart';
import 'package:world_casa/views/widgets/learnObject.dart';
import 'package:world_casa/views/widgets/object.dart';
import 'package:flutter/services.dart';

String name = "Duy";
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // const list1 = [1, 2, 3];
  // final list2 = [1, 2, 3];
  // list1.add(4);//= [4, 5, 6]; // LỖI COMPILE-TIME: Constant variables can't be assigned a value.
  // list2 = [4, 5, 6]; // LỖI COMPILE-TIME: The final variable 'list2' can only be set once.
  //  int x = 5;
  // const myValue = x;//loi: Constant variables must be initialized with a constant value.
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // final scores = [45, 82, 33, 91, 50, 78, 20, 65];
  // var highScores = scores.where((score) => score > 50).toList();
  // highScores = highScores.map((score) => score + 5).toList();
  // print("High Score: $highScores");

  // var totalScore = highScores.reduce((a, b) => a + b);
  // print("Total Score: $totalScore");
  //getDisplayName(null);
  //getDisplayName("duy");
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // var double = multiplier(2);
  // var triple = multiplier(3);
  // print("Double of 5: ${double(5)}"); // Output: Double of
  // print("Triple of 5: ${triple(5)}"); // Output: Triple of 5: 15
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // const rawData = [
  //   {'name': 'iPhone', 'price': 1000},
  //   {'name': 'Case', 'price': 20},
  // ];
  // var listProduct = rawData
  //     .map((data) => "Product:${data['name']} - Price: ${data['price']}")
  //     .toList();
  // print("Products: $listProduct");

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // C3 c3 =
  //     C3(); // vi C3 with M1,M2 => M2 nam ben phai M1 nen C3 se goi ham doWork va stop cua M2
  // c3.doWork();
  // c3.stop();
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // try {
  //   print("Checking inventory...");
  //   bool inventoryAvailable = await checkInventory();

  //   if (inventoryAvailable) {
  //     print("Calculating shipping fee...");
  //     int shippingFee = await calculateShippingFee();

  //     confirmOrder(shippingFee);
  //   } else {
  //     print("Sorry, the product is out of stock.");
  //   }
  // } catch (e) {
  //   print("An error occurred: $e");
  // }
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // print("Begin:");

  // // Lắng nghe Stream
  // await for (int value in createCountdown(5)) {
  //   print(value);
  // }

  // print("Completed!");
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // createCountdown(
  //   5,
  // ).listen((value) => print(value), onDone: () => print("Over!"));

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // MyDateTime myDateTime = MyDateTime();
  // myDateTime.convertToHoursFromSeconds(7200);
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // await for (var value in getUsers()) {
  //   print(value);
  // }
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Dùng cách này để không cần biến context
        fontFamily: 'MyCustomFont',
      ),
      home: const MyMainLayout(),
    ),
  );
}

Stream<int> createCountdown1(int seconds) {
  return Stream.periodic(Duration(seconds: 1), (computationCount) {
        return seconds - computationCount;
      })
      .take(seconds + 1)
      .take(seconds); //đảm bảo Stream sẽ tự đóng sau khi phát đủ n giá trị
}

Stream<int> createCountdown(int seconds) async* {
  for (int i = seconds; i >= 0; i--) {
    // Chờ 1 giây trước khi phát ra số tiếp theo
    await Future.delayed(Duration(seconds: 1));

    // Phát giá trị hiện tại vào Stream
    yield i;
  }
}

Stream<Map<int, String>> getUsers() async* {
  final String response = await rootBundle.loadString('assets/user_data.json');
  final List<dynamic> data = json.decode(response);
  for (var item in data) {
    yield {item['id'] as int: item['name'] as String};
  }
}

void getDisplayName(String? name) {
  if (name?.isEmpty ?? true) {
    print("Guest");
  } else {
    print("Name: ${name!.toUpperCase()}");
  }
}

Future<void> isolateFunction() async {
  Isolate.run(() async {
    await Future.delayed(Duration(seconds: 5));
    name = "Duy in Isolate";
    print("name in Isolate: $name");
  });
  print("name out Isolate: $name");
}

//Closures
Function multiplier(num factor) {
  return (num n) {
    return n * factor;
  };
}

// Giả lập check kho: Mất 1 giây, trả về true
Future<bool> checkInventory() async {
  await Future.delayed(Duration(seconds: 1));
  return true;
}

// Giả lập tính phí ship: Mất 2 giây, trả về 30000
Future<int> calculateShippingFee() async {
  await Future.delayed(Duration(seconds: 2));
  return 30000;
}

// Xác nhận đơn hàng: In ra tổng tiền (Giả sử giá sản phẩm là 100.000)
void confirmOrder(int shippingFee) {
  int productPrice = 100000;
  int total = productPrice + shippingFee;
  print("🛒 Confirming order!");
  print("💰 Total amount to pay: $total");
}

class MyMainLayout extends StatefulWidget {
  const MyMainLayout({super.key});

  @override
  State<MyMainLayout> createState() => _MyMainLayoutState();
}

class _MyMainLayoutState extends State<MyMainLayout> {
  int _currentIndex = 0; // Quản lý 4 tab chính
  bool _isShowingCart =
      false; // Quản lý việc có đang hiện trang Giỏ hàng hay không

  // 1. Danh sách các màn hình nội dung
  final List<Widget> _pages = [
    const HomeScreen(),
    const CataLogScreen(),
    const WishListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      // --- PHẦN TRÊN: App Title & Menu (Cố định) ---
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.1),
        elevation: 0.5,
        centerTitle: true,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Độ mờ
            child: Container(color: Colors.transparent),
          ),
        ),
        // Tiêu đề App luôn hiển thị
        title: const Text(
          "WORLD CASA",
          style: TextStyle(
            color: Color(0xFF7D4F4A),
            fontWeight: FontWeight.bold,
          ),
        ),
        // Nút 3 gạch (Drawer)
        iconTheme: const IconThemeData(color: Color(0xFF7D4F4A)),

        actions: [
          IconButton(
            icon: Icon(Icons.search, color: const Color(0xFF7D4F4A)),
            onPressed: () {},
          ),
          // Nút Giỏ hàng
          IconButton(
            icon: Icon(
              _isShowingCart ? Icons.shopping_bag : Icons.shopping_bag_outlined,
              color: const Color(0xFF7D4F4A),
            ),
            onPressed: () {
              setState(() {
                _isShowingCart = true; // Chuyển body sang trang Cart
              });
            },
          ),
        ],
      ),

      // --- PHẦN MENU HÔNG (Drawer) ---
      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       const DrawerHeader(
      //         child: Text(
      //           'MENU',
      //           style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      //         ),
      //       ),
      //       ListTile(
      //         title: const Text('ABOUT'),
      //         onTap: () => Navigator.pop(context),
      //       ),
      //       ListTile(
      //         title: const Text('CONTACT'),
      //         onTap: () => Navigator.pop(context),
      //       ),
      //     ],
      //   ),
      // ),

      // --- PHẦN GIỮA: Nội dung thay đổi (Body) ---
      body: _isShowingCart
          ? const CartScreen() // Ưu tiên hiển thị Cart nếu biến này true
          : IndexedStack(index: _currentIndex, children: _pages),

      // --- PHẦN DƯỚI: Navigation Bar (Cố định) ---
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
            _isShowingCart =
                false; // Khi nhấn tab dưới, tự động tắt Cart để về trang chính
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined), // Icon viền khi không chọn
            selectedIcon: const Icon(Icons.home), // Icon tô đậm khi được chọn
            label: 'HOME',
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view_sharp),
            label: 'CATALOG',
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: 'WISHLIST',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: 'PROFILE',
          ),
        ],
      ),
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp();
//   }
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp();
//   }
// }
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   List<User> users = [
//     User(name: "Alice", age: 30),
//     User(name: "Bob", age: 25),
//     User(name: "Charlie", age: 35),
//   ];
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
//           centerTitle: true,
//           title: const Text(
//             "Flutter app test",
//             style: TextStyle(
//               fontSize: 30,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           backgroundColor: Colors.indigoAccent,
//         ),
//         body: Column(
//           // Column chính của màn hình
//           children: [
//             // Nếu bạn có thêm widget nào khác ở trên (như tiêu đề), hãy để ở đây
//             Expanded(
//               child: Scrollbar(
//                 thumbVisibility: true,
//                 child: ListView(
//                   children: users.map((user) {
//                     return Container(
//                       margin: const EdgeInsets.symmetric(
//                         vertical: 8,
//                         horizontal: 16,
//                       ),

//                       // 2. Padding bên trong để nội dung không chạm viền
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 5,
//                         vertical: 2,
//                       ),

//                       // 3. Trang trí: Màu nền, Viền và Bo góc
//                       decoration: BoxDecoration(
//                         color: user.isChecked
//                             ? Colors.indigo.withOpacity(0.05)
//                             : Colors.white,
//                         borderRadius: BorderRadius.circular(12), // Bo góc
//                         border: Border.all(
//                           color: user.isChecked
//                               ? Colors.indigoAccent
//                               : Colors.grey.shade300, // Đổi màu viền khi chọn
//                           width: 2, // Độ dày của viền
//                         ),
//                       ),

//                       child: Row(
//                         children: [
//                           Checkbox(
//                             checkColor: Colors.white,
//                             activeColor: Colors.indigoAccent,

//                             value: user.isChecked,
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 user.isChecked = value ?? false;
//                               });
//                             },
//                           ),
//                           Text(
//                             "User: ${user.name}, Age: ${user.age}",
//                             style: const TextStyle(
//                               fontSize: 25,
//                               color: Colors.red,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const Spacer(),
//                           Padding(
//                             padding: const EdgeInsets.only(right: 8.0),
//                             child: SizedBox(
//                               child: IconButton(
//                                 padding: EdgeInsets.zero,
//                                 constraints: const BoxConstraints(),
//                                 icon: const Icon(Icons.delete),
//                                 onPressed: () {
//                                   setState(() {
//                                     users.remove(user);
//                                   });
//                                 },
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//           ],
//         ),

//         floatingActionButton: Row(
//           mainAxisAlignment:
//               MainAxisAlignment.spaceEvenly, // Đẩy nút về bên phải
//           children: [
//             // Nút Xóa (Trừ)
//             FloatingActionButton(
//               onPressed: () {
//                 setState(() {
//                   if (users.isNotEmpty)
//                     users.removeWhere((user) => user.isChecked);
//                 });
//               },
//               backgroundColor: Colors.red,
//               child: const Icon(Icons.remove),
//             ),
//             // Nút Thêm (Cộng)
//             FloatingActionButton(
//               onPressed: () {
//                 setState(() {
//                   users.add(
//                     User(
//                       name: "User ${users.length + 1}",
//                       age: 20 + users.length,
//                     ),
//                   );
//                 });
//               },
//               backgroundColor: Colors.blue,
//               child: const Icon(Icons.add),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class BodyWidget extends StatefulWidget {
//   const BodyWidget({super.key});

//   @override
//   State<BodyWidget> createState() => _BodyWidgetState();
// }

// class _BodyWidgetState extends State<BodyWidget> {
//   @override
//   Widget build(BuildContext context) {
//     List<User> users = widget.users;
//     return Column(
//       // Column chính của màn hình
//       children: [
//         // Nếu bạn có thêm widget nào khác ở trên (như tiêu đề), hãy để ở đây
//         Expanded(
//           child: Scrollbar(
//             thumbVisibility: true,
//             child: ListView(
//               children: users.map((user) {
//                 return Container(
//                   margin: const EdgeInsets.symmetric(
//                     vertical: 8,
//                     horizontal: 16,
//                   ),

//                   // 2. Padding bên trong để nội dung không chạm viền
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 5,
//                     vertical: 2,
//                   ),

//                   // 3. Trang trí: Màu nền, Viền và Bo góc
//                   decoration: BoxDecoration(
//                     color: user.isChecked
//                         ? Colors.indigo.withOpacity(0.05)
//                         : Colors.white,
//                     borderRadius: BorderRadius.circular(12), // Bo góc
//                     border: Border.all(
//                       color: user.isChecked
//                           ? Colors.indigoAccent
//                           : Colors.grey.shade300, // Đổi màu viền khi chọn
//                       width: 2, // Độ dày của viền
//                     ),
//                   ),

//                   child: Row(
//                     children: [
//                       Checkbox(
//                         checkColor: Colors.white,
//                         activeColor: Colors.indigoAccent,

//                         value: user.isChecked,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             user.isChecked = value ?? false;
//                           });
//                         },
//                       ),
//                       Text(
//                         "User: ${user.name}, Age: ${user.age}",
//                         style: const TextStyle(
//                           fontSize: 25,
//                           color: Colors.red,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const Spacer(),
//                       Padding(
//                         padding: const EdgeInsets.only(right: 8.0),
//                         child: SizedBox(
//                           child: IconButton(
//                             padding: EdgeInsets.zero,
//                             constraints: const BoxConstraints(),
//                             icon: const Icon(Icons.delete),
//                             onPressed: () {
//                               setState(() {
//                                 users.remove(user);
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
