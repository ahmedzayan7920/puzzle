import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/background.dart';
import 'package:puzzle/core/app_colors.dart';
import 'package:puzzle/generated/assets.dart';
import 'package:puzzle/screens/call/call_pickup_screen.dart';
import 'package:puzzle/screens/home/profile_owner_screen.dart';

class PieceOwnerScreen extends StatefulWidget {
  final int pieceIndex;
  final int level;

  const PieceOwnerScreen({
    Key? key,
    required this.pieceIndex,
    required this.level,
  }) : super(key: key);

  @override
  State<PieceOwnerScreen> createState() => _PieceOwnerScreenState();
}

class _PieceOwnerScreenState extends State<PieceOwnerScreen> {
  late Query<Map<String, dynamic>> ref;

  @override
  void initState() {
    ref = FirebaseFirestore.instance.collection('users').where("pieces", arrayContains: widget.pieceIndex);
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
    final url = await player.load("5.mp3");
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
            alignment: Alignment.bottomCenter,
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
                    Expanded(
                      child: StreamBuilder(
                          stream: ref.snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<QueryDocumentSnapshot<Map<String, dynamic>>> data = snapshot.data!.docs
                                  .where((e) => ((e.data()["level"] ?? 0) % 4) == (widget.level % 4))
                                  .toList();
                              if (data.isNotEmpty) {
                                return ListView.separated(
                                  itemCount: data.length,
                                  separatorBuilder: (_, i) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> child = data[index].data();
                                    return InkWell(
                                      onTap: () {
                                        audioPlayer.stop();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProfileOwnerScreen(
                                              pieceIndex: widget.pieceIndex,
                                              level: widget.level,
                                              name: child["name"],
                                              profilePicture: child["profilePicture"],
                                              uid: child["uId"],
                                            ),
                                          ),
                                        ).then(
                                          (value) => setAudio(),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          border: Border.all(
                                            color: AppColors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage:
                                                CachedNetworkImageProvider(child["profilePicture"]),
                                            radius: 25,
                                          ),
                                          title: Text(
                                            child["name"],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: AppColors.white,
                                              fontSize: 25,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Center(
                                  child: Text(
                                    "لا أحد يمتلك تلك القطعة",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: AppColors.white,
                                    ),
                                  ),
                                );
                              }
                            } else if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            return const Center(
                              child: Text(
                                "حدث خطا برجاء المحاولة لاحقا",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),
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
                bottom: 0,
                child: isPlaying
                    ? RotationTransition(
                        turns: const AlwaysStoppedAnimation(.25),
                        child: Image.asset(
                          "assets/gif/2.gif",
                          width: 250,
                          height: 250,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
