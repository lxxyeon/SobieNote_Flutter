import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sobienote_flutter/board/response/board_response.dart';
import 'package:sobienote_flutter/common/response/base_response.dart';
import 'package:sobienote_flutter/common/util/utils.dart';
import 'package:sobienote_flutter/component/tag_selector.dart';

import '../board/board_provider.dart';
import '../board/form/board_form_model.dart';
import '../board/request/board_request.dart';
import '../board/response/board_post_response.dart';
import '../common/const/colors.dart';
import '../common/const/tags_data.dart';
import '../common/const/text_style.dart';
import '../common/util/save_share.dart';
import '../images/image_provider.dart';
import '../images/model/board_image.dart';

class BoardSelection extends ConsumerStatefulWidget {
  final int? boardId;

  const BoardSelection({super.key, this.boardId});

  @override
  ConsumerState<BoardSelection> createState() => _BoardSelectionState();
}

class _BoardSelectionState extends ConsumerState<BoardSelection> {
  BoardResponse? _boardData;
  BoardImage? _boardImage;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _loadBoardDetail(widget.boardId);
  }

  Future<void> _loadBoardDetail(int? boardId) async {
    if (boardId == null) return;
    final board = ref.read(boardProvider);
    final imageRepo = ref.read(imagesRepositoryProvider);
    final boardData = await board.getBoard(boardId);
    final imageData = await imageRepo.getBoardImage(boardId);
    setState(() {
      _boardData = boardData;
      _boardImage = imageData.data;
    });
  }

  void _showDeleteDialog() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final board = ref.read(boardProvider);
        return CupertinoAlertDialog(
          title: Text('소비기록을 삭제하겠습니까?'),
          content: Text('소비기록이 삭제됩니다.'),
          actions: [
            CupertinoDialogAction(
              child: Text('확인'),
              onPressed: () async {
                final res = await board.deleteBoard(widget.boardId!);
                if (res.data) {
                  ref.invalidate(
                    imagesProvider((
                      parseDateTime(_boardData!.createdDate).year,
                      parseDateTime(_boardData!.createdDate).month,
                    )),
                  );
                  context.go(
                    '/?refresh=${DateTime.now().millisecondsSinceEpoch}',
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                AppBar(
                  title: Text('소비기록', style: kTitleTextStyle),
                  centerTitle: true,
                  forceMaterialTransparency: true,
                  actions: [
                    if (widget.boardId != null)
                      GestureDetector(
                        onTap: _showDeleteDialog,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text('삭제'),
                        ),
                      ),
                  ],
                ),
                BoardContentSection(
                  key: ValueKey(widget.boardId),
                  boardData: _boardData,
                  boardImage: _boardImage,
                  isDetail: widget.boardId != null,
                  boardId: widget.boardId,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class BoardContentSection extends ConsumerStatefulWidget {
  final BoardResponse? boardData;
  final BoardImage? boardImage;
  final bool isDetail;
  final int? boardId;

  const BoardContentSection({
    super.key,
    this.boardData,
    this.boardImage,
    this.isDetail = false,
    this.boardId,
  });

  @override
  ConsumerState<BoardContentSection> createState() =>
      _BoardContentSectionState();
}

class _BoardContentSectionState extends ConsumerState<BoardContentSection> {
  late BoardFormModel _form;
  late Future<void> _imageInitFuture;
  final ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final board = widget.boardData;
    _form = BoardFormModel();
    if (board != null) {
      _form.detailController.text = board.contents;
      _form.category = categories.indexOf(board.categories);
      _form.emotion = emotions.indexOf(board.emotions);
      _form.factor = factors.indexOf(board.factors);
      _form.satisfaction = satisfactions.indexOf(
        board.satisfactions.toString(),
      );
      _imageInitFuture = _initImage();
    } else {
      _imageInitFuture = Future.value();
    }
    _form.detailController.addListener(() => setState(() {}));
  }

  Future<void> _initImage() async {
    if (widget.boardImage != null) {
      final downloaded = await downloadImageToXFile(
        _form.imageFile!.path,
        boardId: widget.boardId!,
      );
      setState(() {
        _form.imageFile = downloaded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _imageInitFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 100),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Column(
          children: [
            _renderImagePreview(),
            const SizedBox(height: 52),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TagSelector(
                    title: '오늘은 무엇을 샀나요?',
                    tagList: categories,
                    selectedIndex: _form.category,
                    onTagSelected: (i) => setState(() => _form.category = i),
                  ),
                  const SizedBox(height: 48),
                  TagSelector(
                    title: '사고 나서 어떤 기분이 들었나요?',
                    tagList: emotions,
                    selectedIndex: _form.emotion,
                    onTagSelected: (i) => setState(() => _form.emotion = i),
                  ),
                  const SizedBox(height: 48),
                  TagSelector(
                    title: '이 물건이 갖고 있는 가치나\n의미는 무엇인가요?',
                    tagList: factors,
                    selectedIndex: _form.factor,
                    onTagSelected: (i) => setState(() => _form.factor = i),
                  ),
                  const SizedBox(height: 48),
                  TagSelector(
                    title: '이 달의 소비 목표를 이루는데\n얼마나 기여했나요?',
                    tagList: satisfactions,
                    selectedIndex: _form.satisfaction,
                    onTagSelected:
                        (i) => setState(() => _form.satisfaction = i),
                  ),
                  const SizedBox(height: 48),
                  _renderDetail(),
                  const SizedBox(height: 48),
                  _renderSubmitButton(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _renderImagePreview() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: SizedBox(
        width: 250,
        height: 250,
        child: Container(
          decoration: BoxDecoration(
            color: GRAY_09,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                _form.imageFile != null
                    ? Image.file(
                      File(_form.imageFile!.path),
                      fit: BoxFit.cover,
                      width: 250,
                      height: 250,
                    )
                    : widget.boardImage != null
                    ? Image.network(
                      widget.boardImage!.imagePath,
                      fit: BoxFit.cover,
                      width: 250,
                      height: 250,
                    )
                    : Image.asset(
                      'assets/images/imagePickerImg_G.png',
                      fit: BoxFit.cover,
                      width: 250,
                      height: 250,
                    ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
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
                  await _pickAndCropImage(ImageSource.camera);
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
                  await _pickAndCropImage(ImageSource.gallery);
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

  Future<void> _pickAndCropImage(ImageSource source) async {
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
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() => _form.imageFile = XFile(croppedFile.path));
      }
    }
  }

  Widget _renderSubmitButton() {
    final board = ref.read(boardProvider);
    final isEdit = widget.isDetail;
    final buttonText = isEdit ? '수정하기' : '기록하기';
    final boardAction =
        isEdit
            ? () async =>
                board.patchBoard(widget.boardId!, await buildBoardRequest())
            : () async => board.postBoard(await buildBoardRequest());

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: DARK_TEAL,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () async {
          await _handleSubmit(boardAction, isEdit);
        },
        child: Text(buttonText, style: TextStyle(color: GRAY_09, fontWeight: FontWeight.bold)),
      ),
    );
  }

  bool _isSubmitting = false;

  Future<void> _handleSubmit(
    Future<BaseResponse<BoardPostResponse>> Function() boardAction,
    bool isEdit,
  ) async {
    if (_isSubmitting) return;
    _isSubmitting = true;

    if ((_form.imageFile == null && widget.boardImage == null) ||
        _form.category == null ||
        _form.emotion == null ||
        _form.factor == null ||
        _form.satisfaction == null ||
        _form.detailController.text.isEmpty) {
      _showMissingDataDialog();
      _isSubmitting = false;
      return;
    }

    try {
      final resp = await boardAction();
      if (resp.success) {
        await showDialog(
          context: context,
          builder:
              (_) => CupertinoAlertDialog(
                title: Text(isEdit ? '수정이 완료되었습니다.' : '기록이 완료되었습니다.'),
                actions: [
                  CupertinoDialogAction(
                    child: Text('확인'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
        );

        if (!isEdit) {
          setState(() {
            _form.imageFile = null;
            _form.category = null;
            _form.emotion = null;
            _form.factor = null;
            _form.satisfaction = null;
            _form.detailController.clear();
          });
        }

        ref.invalidate(
          imagesProvider((DateTime.now().year, DateTime.now().month)),
        );

        context.go('/?refresh=${DateTime.now().millisecondsSinceEpoch}');
      }
    } catch (e) {
      print(e);
    } finally {
      _isSubmitting = false;
    }
  }

  void _showMissingDataDialog() {
    String text = '입력값이 부족합니다.';
    if (_form.imageFile == null && widget.boardImage == null)
      text = '사진을 추가해주세요';
    else if (_form.category == null)
      text = '카테고리를 기록해주세요';
    else if (_form.emotion == null)
      text = '감정을 기록해주세요';
    else if (_form.factor == null)
      text = '가치를 기록해주세요';
    else if (_form.satisfaction == null)
      text = '만족도를 기록해주세요';
    else if (_form.detailController.text.isEmpty)
      text = '상세 기록 내용을 기록해주세요';

    _showConfirmDialog(text);
  }

  Future<void> _showConfirmDialog(String message) async {
    await showDialog(
      context: context,
      builder:
          (_) => CupertinoAlertDialog(
            title: Text(message),
            actions: [
              CupertinoDialogAction(
                child: Text('확인'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  Future<BoardRequest> buildBoardRequest() async {
    late final file;
    if (_form.imageFile == null) {
      file = await downloadNetworkImageToFile(widget.boardImage!.imagePath);
    }
    return BoardRequest(
      contents: _form.detailController.text,
      categories: categories[_form.category!],
      emotions: emotions[_form.emotion!],
      factors: factors[_form.factor!],
      satisfactions: int.parse(satisfactions[_form.satisfaction!]),
      file: _form.imageFile != null ? File(_form.imageFile!.path) : file,
    );
  }

  Widget _renderDetail() {
    return Column(
      children: [
        Text(
          '오늘의 소비에 대해 더 자세히 기록해 볼까요?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: GRAY_00,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: TextField(
            maxLines: 3,
            minLines: 2,
            controller: _form.detailController,
            decoration: InputDecoration(
              hintText: '물건의 특징이나 구매 동기 등을 적어보세요!',
              hintStyle: TextStyle(color: GRAY_06),
              counterStyle:
                  _form.detailController.text.length == 40
                      ? TextStyle(color: Colors.red)
                      : TextStyle(color: FONT_GRAY),
            ),
            maxLength: 40,
          ),
        ),
      ],
    );
  }
}
