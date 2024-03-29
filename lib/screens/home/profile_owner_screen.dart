import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/background.dart';
import 'package:puzzle/core/app_colors.dart';
import 'package:puzzle/core/app_functions.dart';
import 'package:puzzle/generated/assets.dart';
import 'package:puzzle/models/call_model.dart';
import 'package:puzzle/screens/call/call_pickup_screen.dart';
import 'package:puzzle/screens/call/call_screen.dart';
import 'package:uuid/uuid.dart';

class ProfileOwnerScreen extends StatefulWidget {
  final String name;
  final String profilePicture;
  final String uid;
  final int pieceIndex;
  final int level;

  const ProfileOwnerScreen({
    Key? key,
    required this.pieceIndex,
    required this.level,
    required this.name,
    required this.profilePicture,
    required this.uid,
  }) : super(key: key);

  @override
  State<ProfileOwnerScreen> createState() => _ProfileOwnerScreenState();
}

class _ProfileOwnerScreenState extends State<ProfileOwnerScreen> {
  void startCall({
    required BuildContext context,
  }) async {
    String callId = const Uuid().v1();
    CallModel callerData = CallModel(
      callerId: FirebaseAuth.instance.currentUser!.uid,
      callerName: FirebaseAuth.instance.currentUser!.displayName ?? "",
      callerPicture: FirebaseAuth.instance.currentUser!.photoURL ?? "",
      receiverId: widget.uid,
      receiverName: widget.name,
      receiverPicture: widget.profilePicture,
      callId: callId,
      hasDialled: true,
    );

    CallModel receiverData = CallModel(
      callerId: FirebaseAuth.instance.currentUser!.uid,
      callerName: FirebaseAuth.instance.currentUser!.displayName ?? "",
      callerPicture: FirebaseAuth.instance.currentUser!.photoURL ?? "",
      receiverId: widget.uid,
      receiverName: widget.name,
      receiverPicture: widget.profilePicture,
      callId: callId,
      hasDialled: false,
    );
    try {
      await FirebaseFirestore.instance.collection("calls").doc(callerData.callerId).set(callerData.toMap());
      await FirebaseFirestore.instance
          .collection("calls")
          .doc(callerData.receiverId)
          .set(receiverData.toMap());
      if (!mounted) return;

      audioPlayer.stop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            channelId: callerData.callId,
            call: callerData,
            isGroupChat: false,
          ),
        ),
      ).then(
            (value) => setAudio(),
      );
    } catch (error) {
      showSnackBar(context: context, content: error.toString());
    }
  }



  @override
  void initState() {
    super.initState();
    setAudio();
  }

  final audioPlayer = AudioPlayer();
  final player = AudioCache(prefix: "assets/audio/");
  bool isPlaying = true;


  @override
  void dispose() {
    audioPlayer.dispose();
    player.clearAll();
    super.dispose();
  }

  Future setAudio() async {
    final url = await player.load("6.mp3");
    audioPlayer.play(UrlSource(url.path));
    setState(() {
      isPlaying = true;
    });
    audioPlayer.onPlayerComplete.listen((state) {
      setState(() {
        isPlaying = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CallPickupScreen(
        scaffold: Scaffold(
          body: Stack(
            children: [
              const CustomBackground(),
              Positioned(
                bottom: 20,
                left: 0,
                child: Image.asset(Assets.assetsStar, width: 50, height: 35),
              ),
              Positioned(
                bottom: 0,
                left: 30,
                child: Image.asset(Assets.assetsStar, width: 50, height: 25),
              ),
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
                          "هذه القطعة مع",
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
                    CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(widget.profilePicture),
                      radius: 150,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 40,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(widget.uid)
                            .collection("orders")
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .set({
                          "name": FirebaseAuth.instance.currentUser!.displayName,
                          "uId": FirebaseAuth.instance.currentUser!.uid,
                          "pieceIndex": widget.pieceIndex,
                          "level": widget.level,
                        }).then((value) => startCall(context: context));
                      },
                      child: Container(
                        height: 47,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 70),
                        decoration: BoxDecoration(
                          color: AppColors.buttonColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.call,
                                  size: 30,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "اتصل به",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
              Positioned(
                bottom: -60,
                right: -20,
                child: isPlaying?Image.asset(
                  "assets/gif/2.gif",
                  width: 200,
                  height: 200,
                ):const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
