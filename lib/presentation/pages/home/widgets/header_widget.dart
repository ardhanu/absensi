import 'package:attendify/core/constants/app_colors.dart';
import 'package:attendify/presentation/pages/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'dart:convert';

class HeaderWidget extends StatefulWidget {
  final Future<dynamic> futureProfile;
  final bool hasAttendedToday;
  final VoidCallback showDialogDetailsAttended;
  final VoidCallback? onRefreshData;

  const HeaderWidget({
    Key? key,
    required this.futureProfile,
    required this.hasAttendedToday,
    required this.showDialogDetailsAttended,
    this.onRefreshData,
  }) : super(key: key);

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  Widget greetingWithIcon() {
    final hour = DateTime.now().hour;
    String greetingText;
    String assetPath;

    if (hour >= 5 && hour < 12) {
      greetingText = 'Good morning';
      assetPath = 'assets/icons/morning.png';
    } else if (hour >= 12 && hour < 17) {
      greetingText = 'Good afternoon';
      assetPath = 'assets/icons/afternoon.png';
    } else if (hour >= 17 && hour < 21) {
      greetingText = 'Good evening';
      assetPath = 'assets/icons/evening.png';
    } else {
      greetingText = 'Good night';
      assetPath = 'assets/icons/night.png';
    }

    return Row(
      children: [
        Text(
          greetingText,
          style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        SizedBox(width: 4),
        Image.asset(assetPath, width: 24, height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FutureBuilder(
          future: widget.futureProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircleAvatar(
                backgroundColor: AppColors.secondary,
                radius: 30,
                child: Icon(Icons.person, color: AppColors.text, size: 30),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return CircleAvatar(
                backgroundColor: AppColors.secondary,
                radius: 30,
                child: Icon(Icons.person, color: AppColors.text, size: 30),
              );
            }
            final profile = snapshot.data;
            String? photoUrl = profile?.photo;
            Widget? avatarChild;
            ImageProvider? imageProvider;
            if (photoUrl != null && photoUrl.isNotEmpty) {
              if (photoUrl.startsWith('data:image')) {
                // base64
                avatarChild = ClipOval(
                  child: Image.memory(
                    base64Decode(photoUrl.split(',').last),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, size: 30, color: Colors.grey),
                  ),
                );
                imageProvider = null;
              } else if (photoUrl.startsWith('http')) {
                imageProvider = NetworkImage(photoUrl);
                avatarChild = null;
              } else {
                imageProvider = NetworkImage(
                  'https://appabsensi.mobileprojp.com/public/$photoUrl',
                );
                avatarChild = null;
              }
            } else {
              // Tidak ada foto, tampilkan huruf pertama nama (sama seperti profile_page.dart)
              String initial = (profile?.name?.isNotEmpty ?? false)
                  ? profile!.name[0].toUpperCase()
                  : '?';
              avatarChild = Text(
                initial,
                style: GoogleFonts.lexend(
                  fontSize: 36, // samakan dengan profile_page.dart
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
              );
              imageProvider = null;
            }
            return CircleAvatar(
              backgroundColor: AppColors.secondary,
              radius: 30,
              backgroundImage: imageProvider,
              child: avatarChild,
            );
          },
        ),
        SizedBox(width: 16),
        FutureBuilder(
          future: widget.futureProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 48,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer(
                      duration: Duration(seconds: 3),
                      interval: Duration(seconds: 5),
                      color: Colors.grey.shade300,
                      colorOpacity: 1,
                      enabled: true,
                      direction: ShimmerDirection.fromLTRB(),
                      child: Container(
                        width: 100,
                        height: 16,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 6),
                      ),
                    ),
                    Shimmer(
                      duration: Duration(seconds: 3),
                      interval: Duration(seconds: 5),
                      color: Colors.grey.shade300,
                      colorOpacity: 1,
                      enabled: true,
                      direction: ShimmerDirection.fromLTRB(),
                      child: Container(
                        width: 60,
                        height: 14,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 6),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load profile',
                  style: GoogleFonts.lexend(fontSize: 12),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text(
                  'No profile data available',
                  style: GoogleFonts.lexend(fontSize: 12),
                ),
              );
            }
            final profile = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                greetingWithIcon(),
                Text(profile.name, style: GoogleFonts.lexend(fontSize: 12)),
                GestureDetector(
                  onTap: widget.showDialogDetailsAttended,
                  child: Row(
                    children: [
                      Text(
                        widget.hasAttendedToday ? 'Attended' : 'Not Attended',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: widget.hasAttendedToday
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: widget.hasAttendedToday
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        Spacer(),
        GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
            // Refresh data setelah kembali dari profile page
            if (widget.onRefreshData != null) {
              widget.onRefreshData!();
            }
          },
          child: Container(
            height: 32,
            width: 35,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.secondary),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outlined, size: 18),
          ),
        ),
        SizedBox(width: 4),
      ],
    );
  }
}
