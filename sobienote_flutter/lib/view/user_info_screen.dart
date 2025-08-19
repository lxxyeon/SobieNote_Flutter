import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sobienote_flutter/common/const/colors.dart';
import 'package:sobienote_flutter/common/util/save_share.dart';
import 'package:sobienote_flutter/component/default_layout.dart';

import '../common/const/text_style.dart';
import '../user/user_provider.dart';

class UserInfoScreen extends ConsumerStatefulWidget {
  static String get routeName => 'user-info';

  const UserInfoScreen({super.key});

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  File? _profileImage;
  ImagePicker imagePicker = ImagePicker();
  bool isYouth = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImageOnInit();
  }

  Future<File?> loadProfileImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();

    final profileImages =
        files.where((file) {
          return file is File &&
              RegExp(r'profile_\d+\.jpg$').hasMatch(file.path.split('/').last);
        }).toList();

    if (profileImages.isEmpty) return null;

    profileImages.sort((a, b) => b.path.compareTo(a.path));
    return profileImages.first as File;
  }

  Future<void> _loadProfileImageOnInit() async {
    final file = await loadProfileImage();
    if (file != null) {
      setState(() => _profileImage = file);
    }
  }

  Future<void> pickAndCropImage(ImageSource source) async {
    final XFile? pickedFile = await imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '이미지 자르기',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            hideBottomControls: true,
            cropFrameStrokeWidth: 2,
            cropStyle: CropStyle.circle,
          ),
        ],
      );
      if (croppedFile != null) {
        final saved = await saveImageToLocalDirectory(XFile(croppedFile.path));
        setState(() => _profileImage = saved);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfoAsync = ref.watch(userInfoProvider);
    final textStyle = const TextStyle(fontSize: 17);

    void showImageSourceDialog() {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text('사진 업로드 설정'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () async {
                  Navigator.pop(context);
                  final status = await Permission.camera.request();
                  if (status.isGranted) {
                    await pickAndCropImage(ImageSource.camera);
                  } else {
                    print('카메라 권한이 거부됨');
                  }
                },
                child: Text('사진 찍을래요'),
              ),
              CupertinoActionSheetAction(
                onPressed: () async {
                  Navigator.pop(context);
                  final androidInfo = await DeviceInfoPlugin().androidInfo;
                  final status =
                      androidInfo.version.sdkInt >= 33
                          ? await Permission.photos.request()
                          : await Permission.storage.request();

                  if (status.isGranted) {
                    await pickAndCropImage(ImageSource.gallery);
                  }
                },
                child: Text('앨범에서 선택할래요'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              isDefaultAction: true,
              child: Text('취소', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          );
        },
      );
    }

    return DefaultLayout(
      backgroundColor: LIGHT_TEAL,
      appBar: AppBar(
        title: Text('사용자 정보', style: kTitleTextStyle),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      child: userInfoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('불러오기 실패: $err')),
        data:
            (user) => Column(
              children: [
                Stack(
                  children: [
                    // 원형 프로필 이미지
                    CircleAvatar(
                      radius: 70,
                      backgroundImage:
                          _profileImage != null
                              ? FileImage(_profileImage!)
                              : AssetImage('assets/images/icon.png')
                                  as ImageProvider,
                    ),
                    // 오른쪽 아래 카메라 아이콘 버튼
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.camera_alt),
                            iconSize: 20,
                            color: Colors.black,
                            visualDensity: VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity,
                            ),
                            onPressed: () {
                              showImageSourceDialog();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                _buildInfoBox([
                  _buildInfoRow('닉네임', user.nickName, textStyle),
                  _buildDivider(),
                  _buildInfoRow('이메일', user.email, textStyle),
                ]),
                const SizedBox(height: 30),
                // Container(
                //   margin: const EdgeInsets.symmetric(horizontal: 15),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text('우리동네 Youth-Up 참가자인가요?', style: textStyle),
                //       CupertinoSwitch(
                //         value: isYouth,
                //         onChanged: (bool val) {
                //           setState(() {
                //             isYouth = val;
                //           });
                //         },
                //       ),
                //     ],
                //   ),
                // ),
                // const SizedBox(height: 30),
                // if (isYouth)
                //   _buildInfoBox([
                //     _buildInfoRow('이름', user.name, textStyle),
                //     _buildDivider(),
                //     _buildInfoRow('나이', user.age, textStyle),
                //     _buildDivider(),
                //     _buildInfoRow('소속', user.school, textStyle),
                //   ]),
              ],
            ),
      ),
    );
  }

  Widget _buildInfoBox(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: GRAY_06),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: GRAY_09,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  Widget _buildInfoRow(String label, String? value, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          if (value != null) Text(value, style: style),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Divider(color: GRAY_06);
}
