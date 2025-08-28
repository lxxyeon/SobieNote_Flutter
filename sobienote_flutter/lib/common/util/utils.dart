import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../const/data.dart';

DateTime parseDateTime(String str) {
  return DateTime.parse(str);
}

Future<XFile> downloadImageToXFile(String imageUrl, {required int boardId}) async {
  final dio = Dio();
  final ext = p.extension(Uri.parse(imageUrl).path).toLowerCase();
  final dir = await getTemporaryDirectory();

  final filePath = '${dir.path}/board_image_$boardId$ext';
  final file = File(filePath);

  if (await file.exists()) {
    await file.delete();
  }

  final response = await dio.download(imageUrl, filePath);

  if (response.statusCode == 200) {
    return XFile(filePath);
  } else {
    throw Exception('Failed to download image');
  }
}

int? getAgeFromGrade(String? school, String? grade) {
  if (school == null || grade == null) return null;

  final grades = SCHOOL_GRADE_MAP[school];
  if (grades == null || !grades.contains(grade)) return null;

  if (grade.contains('세')) {
    return int.tryParse(grade.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  final year = int.tryParse(grade.replaceAll(RegExp(r'[^0-9]'), ''));

  if (school.contains('초등학교')) {
    return 7 + (year ?? 0);
  } else if (school.contains('중학교')) {
    return 13 + (year ?? 0);
  } else if (school.contains('고등학교')) {
    return 16 + (year ?? 0);
  }

  return null;
}

String? getGradeFromAge(String school, String age) {
  final parsedAge = int.tryParse(age);
  if (parsedAge == null) return null;

  if (school.contains('초등')) return '${parsedAge - 7}학년';
  if (school.contains('중')) return '${parsedAge - 13}학년';
  if (school.contains('고')) return '${parsedAge - 16}학년';
  return null;
}
