import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sobienote_flutter/common/const/colors.dart';
import 'package:sobienote_flutter/user/request/sign_up_form.dart';
import 'package:sobienote_flutter/widget/gender_selector.dart';

import '../common/util/utils.dart';
import '../user/model/user_model.dart';
import '../user/user_provider.dart';
import '../widget/school_grade_picker.dart';

class SignUpBottomSheet extends ConsumerStatefulWidget {
  final BuildContext parentContext;

  const SignUpBottomSheet({super.key, required this.parentContext});

  @override
  ConsumerState<SignUpBottomSheet> createState() => _SignUpBottomSheetState();
}

class _SignUpBottomSheetState extends ConsumerState<SignUpBottomSheet> {
  int _currentStep = 0;
  bool isGangwon = false;
  bool _isValid = false;
  bool _isLoading = false;

  final _nicknameController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwConfirmController = TextEditingController();
  final _emailController = TextEditingController();

  final _nameController = TextEditingController();
  String? selectedSchool;
  String? selectedGrade;
  final TextEditingController schoolGradeController = TextEditingController();
  Gender _selectedGender = Gender.FEMALE;

  Future<void> _nextStep() async {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
        _isValid = false;
      });
      _validate();
    } else {
      setState(() {
        _isLoading = true;
      });

      bool isSuccess = false;
      try {
        isSuccess = await ref.read(userProvider.notifier).signUp(
          form: _nameController.text.isNotEmpty &&
              selectedSchool != null &&
              selectedGrade != null
              ? SignUpForm(
            name: _nicknameController.text,
            password: _pwController.text,
            email: _emailController.text,
            studentName: _nameController.text,
            schoolName: selectedSchool,
            age: getAgeFromGrade(selectedSchool, selectedGrade).toString(),
            gender: _selectedGender,
          )
              : SignUpForm(
            name: _nicknameController.text,
            password: _pwController.text,
            email: _emailController.text,
          ),
        );
      } catch (e) {
        isSuccess = false;
      }

      setState(() {
        _isLoading = false;
      });

      if (!isGangwon) {
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text('인증메일을 전송하였습니다.'),
              content: Text('메일을 확인하여 인증을 완료해주세요.'),
              actions: [
                CupertinoDialogAction(
                  child: Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(3, (index) {
        final isActive = index <= _currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.teal : Colors.grey[300],
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('닉네임을 입력해 주세요', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            Text('소비채집에서 사용할 닉네임을 입력해 주세요.', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            TextField(
              controller: _nicknameController,
              onChanged: (_) => _validate(),
              decoration: InputDecoration(
                hintText: '닉네임',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
              ),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('비밀번호를 입력해 주세요', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            Text(
              '영어, 숫자, 특수문자를 포함하여 8~20자리까지\n입력해주세요.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: true,
              controller: _pwController,
              onChanged: (_) => _validate(),
              decoration: InputDecoration(
                hintText: '비밀번호',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
              ),
            ),
            const SizedBox(height: 5),
            TextField(
              obscureText: true,
              controller: _pwConfirmController,
              onChanged: (_) => _validate(),
              decoration: InputDecoration(
                hintText: '비밀번호 확인',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
              ),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이메일을 입력해 주세요', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            Text('로그인 시 사용할 이메일을 입력해주세요', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              onChanged: (_) => _validate(),
              decoration: InputDecoration(
                hintText: 'abc@naver.com',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('강원청소년활동진흥센터인가요?', style: TextStyle(fontSize: 16)),
                CupertinoSwitch(
                  value: isGangwon,
                  onChanged: (bool) {
                    setState(() {
                      isGangwon = !isGangwon;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isGangwon)
              Column(
                children: [
                  TextField(
                    controller: schoolGradeController,
                    readOnly: true,
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
                    decoration: InputDecoration(
                      hintText:
                          (selectedSchool == null || selectedGrade == null)
                              ? '학교/학년 선택'
                              : '$selectedSchool $selectedGrade',
                      suffixIcon: Icon(Icons.arrow_drop_down),
                      filled: true,
                      fillColor: TEAL,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: '이름',
                      filled: true,
                      fillColor: TEAL,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GenderSelector(
                    onChanged: (genderLabel) {
                      setState(() {
                        _selectedGender =
                            genderLabel == '여성' ? Gender.FEMALE : Gender.MALE;
                      });
                    },
                  ),
                ],
              ),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height * 0.9,
      child: Padding(
        padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(24)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              _buildStepIndicator(),
              const SizedBox(height: 60),
              _buildStepContent(),
              const SizedBox(height: 60),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DARK_TEAL,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: _isValid ? _nextStep : null,
                  child: Text(
                    _currentStep == 2 ? '완료' : '다음',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validate() {
    setState(() {
      if (_currentStep == 0) {
        _isValid = _nicknameController.text.trim().isNotEmpty;
      } else if (_currentStep == 1) {
        final pw = _pwController.text;
        final confirm = _pwConfirmController.text;
        _isValid =
            RegExp(
              r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$%^&*()_+~])[A-Za-z\d!@#\$%^&*()_+~]{8,20}$',
            ).hasMatch(pw) &&
            pw == confirm;
      } else if (_currentStep == 2) {
        final email = _emailController.text.trim();
        _isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      }
    });
  }
}
