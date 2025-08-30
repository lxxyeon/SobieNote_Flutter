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
import 'package:sobienote_flutter/user/request/student_update_form.dart';
import 'package:sobienote_flutter/widget/gender_selector.dart';

import '../common/const/text_style.dart';
import '../common/util/utils.dart';
import '../user/model/user_model.dart';
import '../user/user_provider.dart';
import '../widget/info_box.dart';
import '../widget/info_row.dart';
import '../widget/school_grade_picker.dart';

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
  bool initialized = false;
  String? selectedSchool;
  String? selectedGrade;
  final TextEditingController schoolGradeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  Gender gender = Gender.FEMALE;

  @override
  void initState() {
    super.initState();
    _loadProfileImageOnInit();
  }

  Future<File?> loadProfileImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();

    final profileImages =
        files
            .where(
              (file) =>
                  file is File &&
                  RegExp(
                    r'profile_\d+\.jpg$',
                  ).hasMatch(file.path.split('/').last),
            )
            .toList();

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
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
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
            title: const Text('사진 업로드 설정'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () async {
                  Navigator.pop(context);
                  final status = await Permission.camera.request();
                  if (status.isGranted) {
                    await pickAndCropImage(ImageSource.camera);
                  }
                },
                child: const Text('사진 찍을래요'),
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
                child: const Text('앨범에서 선택할래요'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              isDefaultAction: true,
              child: const Text(
                '취소',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
        data: (user) {
          if (!initialized &&
              user.name != null &&
              user.age != null &&
              user.school != null) {
            initialized = true;
            isYouth = true;
            nameController.text = user.name!;
            selectedSchool = user.school;
            selectedGrade = getGradeFromAge(user.school!, user.age!);
            gender = user.gender ?? Gender.FEMALE;
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage:
                          _profileImage != null
                              ? FileImage(_profileImage!)
                              : const AssetImage('assets/images/icon.png')
                                  as ImageProvider,
                    ),
                    // Positioned(
                    //   bottom: 0,
                    //   right: 0,
                    //   child: GestureDetector(
                    //     child: Container(
                    //       padding: const EdgeInsets.all(6),
                    //       decoration: const BoxDecoration(
                    //         shape: BoxShape.circle,
                    //         color: Colors.white,
                    //       ),
                    //       child: IconButton(
                    //         icon: const Icon(Icons.camera_alt),
                    //         iconSize: 20,
                    //         color: Colors.black,
                    //         visualDensity: const VisualDensity(
                    //           horizontal: VisualDensity.minimumDensity,
                    //           vertical: VisualDensity.minimumDensity,
                    //         ),
                    //         onPressed: showImageSourceDialog,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 50),

                InfoBox(
                  children: [
                    InfoRow(
                      label: '닉네임',
                      trailing: Text(user.nickName, style: textStyle),
                      labelStyle: textStyle,
                    ),
                    const Divider(color: GRAY_06),
                    InfoRow(
                      label: '이메일',
                      trailing: Text(user.email, style: textStyle),
                      labelStyle: textStyle,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('강원청소년활동진흥센터인가요?', style: textStyle),
                      CupertinoSwitch(
                        value: isYouth,
                        onChanged: (val) => setState(() => isYouth = val),
                      ),
                    ],
                  ),
                ),

                if (isYouth) ...[
                  const SizedBox(height: 24),
                  InfoBox(
                    children: [
                      InfoRow(
                        label: '이름',
                        trailing: SizedBox(
                          width: 150,
                          height: 25,
                          child: TextField(
                            controller: nameController,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: '이름',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color:
                                    nameController.text.isEmpty
                                        ? GRAY_05
                                        : Colors.black,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ),
                      const Divider(color: GRAY_06),
                      InfoRow(
                        label: '학교',
                        trailing: GestureDetector(
                          onTap: () async {
                            final result = await showSchoolGradePicker(
                              context,
                              selectedSchool: selectedSchool,
                              selectedGrade: selectedGrade,
                            );
                            if (result != null) {
                              setState(() {
                                selectedSchool = result['school'];
                                selectedGrade = result['grade'];
                              });
                            }
                          },
                          child: Text(
                            selectedSchool ?? '학교 선택',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  selectedSchool == null
                                      ? GRAY_05
                                      : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const Divider(color: GRAY_06),
                      InfoRow(
                        label: '학년',
                        trailing: GestureDetector(
                          onTap: () async {
                            final result = await showSchoolGradePicker(
                              context,
                              selectedSchool: selectedSchool,
                              selectedGrade: selectedGrade,
                            );
                            if (result != null) {
                              setState(() {
                                selectedSchool = result['school'];
                                selectedGrade = result['grade'];
                              });
                            }
                          },
                          child: Text(
                            selectedGrade ?? '학년 선택',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  selectedGrade == null
                                      ? GRAY_05
                                      : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: GenderSelector(
                      initialGender: user.gender == Gender.MALE ? '남성' : '여성',
                      onChanged: (genderLabel) {
                        setState(() {
                          gender =
                              genderLabel == '여성' ? Gender.FEMALE : Gender.MALE;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>((
                                Set<WidgetState> states,
                              ) {
                                if (states.contains(WidgetState.disabled)) {
                                  return Colors.grey;
                                }
                                return DARK_TEAL;
                              }),
                          foregroundColor:
                              WidgetStateProperty.resolveWith<Color>((
                                Set<WidgetState> states,
                              ) {
                                if (states.contains(WidgetState.disabled)) {
                                  return Colors.grey.shade700;
                                }
                                return GRAY_09;
                              }),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              side: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        onPressed:
                            _isFormValid
                                ? () async {
                                  final resp = await ref
                                      .read(userProvider.notifier)
                                      .updateStudent(
                                        request: StudentUpdateForm(
                                          schoolName: selectedSchool!,
                                          age:
                                              getAgeFromGrade(
                                                selectedSchool!,
                                                selectedGrade!,
                                              ).toString(),
                                          studentName: nameController.text,
                                          gender: gender,
                                        ),
                                      );
                                  if (!mounted) return;
                                  ref.invalidate(userInfoProvider);
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (_) {
                                      return CupertinoAlertDialog(
                                        title: const Text('수정 완료'),
                                        content: Text(
                                          resp ? '학생 정보가 수정되었습니다.' :  '학생 정보 수정에 실패했습니다.',
                                        ),
                                        actions: [
                                          CupertinoDialogAction(
                                            child: const Text('확인'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                                : null,
                        child: const Text(
                          '수정하기',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  bool get _isFormValid {
    return selectedSchool != null &&
        selectedGrade != null &&
        nameController.text.trim().isNotEmpty;
  }
}
