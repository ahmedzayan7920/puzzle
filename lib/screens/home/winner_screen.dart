import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/background.dart';
import 'package:puzzle/core/app_colors.dart';
import 'package:puzzle/core/app_functions.dart';
import 'package:puzzle/generated/assets.dart';
import 'package:puzzle/screens/call/call_pickup_screen.dart';
import 'package:puzzle/screens/home/leaderboard_screen.dart';

class WinnerScreen extends StatefulWidget {
  final int userPiece;
  final int level;
  final String name;
  final String profilePicture;

  const WinnerScreen({
    Key? key,
    required this.userPiece,
    required this.level,
    required this.name,
    required this.profilePicture,
  }) : super(key: key);

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CallPickupScreen(
        scaffold: Scaffold(
          body: Stack(
            children: [
              const CustomBackground(),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(Assets.assetsStar, width: 50, height: 50),
                        const SizedBox(width: 10),
                        Text(
                          "مبروك لقد فزت",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 40,
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("users")
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Map selection = (snapshot.data!.data() as Map)["selection"];
                          Map data = Map.fromEntries(
                            selection.entries.toList()
                              ..sort(
                                (a, b) => a.value.compareTo(b.value),
                              ),
                          );
                          // print(selection);
                          // print(data);
                          List noSort = [0];
                          print(noSort);
                          for (int i = 0; i < data.keys.toList().length; i++) {
                            noSort.add(int.parse(data.keys.toList()[i]));
                          }
                          print(noSort);
                          int level = (snapshot.data!.data() as Map)["level"];
                          String image = "";
                          if ((level % 4) == 0) {
                            image = "assets/image.jpeg";
                          } else if ((level % 4) == 1){
                            image = "assets/selection_${noSort[1] - 1}.jpeg";
                          } else if ((level % 4) == 2){
                            image = "assets/selection_${noSort[2] - 1}.jpeg";
                          } else if ((level % 4) == 3){
                            image = "assets/selection_${noSort[3] - 1}.jpeg";
                          }
                          return Image.asset(
                            image,
                            width: width,
                            height: width,
                            fit: BoxFit.fitWidth,
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          );
                        }
                      },
                    ),
                    // Image.asset(Assets.assetsWinner, height: 120),
                    // CircleAvatar(
                    //   radius: 120,
                    //   backgroundColor: AppColors.textColor,
                    //   child: CircleAvatar(
                    //     backgroundColor: AppColors.buttonColor,
                    //     backgroundImage: CachedNetworkImageProvider(widget.profilePicture),
                    //     radius: 110,
                    //   ),
                    // ),
                    // const SizedBox(height: 20),
                    // Text(
                    //   widget.name,
                    //   maxLines: 1,
                    //   overflow: TextOverflow.ellipsis,
                    //   style: TextStyle(
                    //     color: AppColors.textColor,
                    //     fontSize: 40,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        showLoadingDialog(context);
                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update({
                          'pieces': [widget.userPiece],
                          "level": FieldValue.increment(1),
                          "score": FieldValue.increment(10),
                        }).then((value) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CallPickupScreen(scaffold: LeaderboardScreen()),
                            ),
                          );
                        });
                      },
                      child: Container(
                        height: 47,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 60),
                        decoration: BoxDecoration(
                          color: AppColors.buttonColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Text(
                              "أحصل علي الجائزة",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_forward_ios),
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
