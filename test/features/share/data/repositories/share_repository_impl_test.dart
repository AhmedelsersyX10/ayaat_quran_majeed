import 'dart:io';
import 'dart:typed_data';
import 'package:ayaat_quran_majeed/core/errors/failure.dart';
import 'package:ayaat_quran_majeed/features/share/data/datasources/share_local_data_source.dart';
import 'package:ayaat_quran_majeed/features/share/data/repositories/share_repository_impl.dart';
import 'package:ayaat_quran_majeed/quran/data/data_sources/quran_metadata_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockShareLocalDataSource implements ShareLocalDataSource {
  String? sharedText;
  String? sharedSubject;
  String? sharedFilePath;
  bool saveGalleryResult = true;
  bool cleanCalled = false;
  Uint8List? savedBytes;
  String? savedFileName;

  @override
  Future<void> cleanOldShareFiles({
    Duration olderThan = const Duration(hours: 2),
  }) async {
    cleanCalled = true;
  }

  @override
  Future<File> saveImageToTemporaryFile(
    Uint8List imageBytes,
    String fileName,
  ) async {
    savedBytes = imageBytes;
    savedFileName = fileName;
    return File('/mock/temp/$fileName');
  }

  @override
  Future<bool> saveImageToGallery(Uint8List imageBytes, String fileName) async {
    savedBytes = imageBytes;
    savedFileName = fileName;
    return saveGalleryResult;
  }

  @override
  Future<void> shareFile(
    String filePath, {
    String? text,
    String? subject,
  }) async {
    sharedFilePath = filePath;
  }

  @override
  Future<void> sharePlainText(String text, {String? subject}) async {
    sharedText = text;
    sharedSubject = subject;
  }
}

void main() {
  late _MockShareLocalDataSource mockDataSource;
  late ShareRepositoryImpl repository;

  setUp(() {
    mockDataSource = _MockShareLocalDataSource();
    repository = ShareRepositoryImpl(
      localDataSource: mockDataSource,
      metadataService: const QuranMetadataService(),
    );
  });

  group('ShareRepositoryImpl Unit Tests', () {
    test(
      'shareText delegates to local data source with text and subject',
      () async {
        await repository.shareText(text: 'نص الآية', subject: 'موضوع');

        expect(mockDataSource.sharedText, 'نص الآية');
        expect(mockDataSource.sharedSubject, 'موضوع');
      },
    );

    test(
      'shareImage performs old file cleanup, caches image, shares it, and returns path',
      () async {
        final dummyBytes = Uint8List.fromList([1, 2, 3, 4]);
        final path = await repository.shareImage(
          imageBytes: dummyBytes,
          fileName: 'ayah_card.png',
          text: 'مشاركة بطاقة',
        );

        expect(mockDataSource.cleanCalled, isTrue);
        expect(mockDataSource.savedBytes, dummyBytes);
        expect(mockDataSource.savedFileName, 'ayah_card.png');
        expect(mockDataSource.sharedFilePath, '/mock/temp/ayah_card.png');
        expect(path, '/mock/temp/ayah_card.png');
      },
    );

    test('saveImageToGallery succeeds when data source returns true', () async {
      final dummyBytes = Uint8List.fromList([5, 6, 7]);
      await repository.saveImageToGallery(
        imageBytes: dummyBytes,
        fileName: 'gallery_card.png',
      );

      expect(mockDataSource.savedBytes, dummyBytes);
      expect(mockDataSource.savedFileName, 'gallery_card.png');
    });

    test(
      'saveImageToGallery throws ShareFailure when data source reports failure',
      () async {
        mockDataSource.saveGalleryResult = false;
        final dummyBytes = Uint8List.fromList([8, 9]);

        expect(
          () => repository.saveImageToGallery(
            imageBytes: dummyBytes,
            fileName: 'failed_card.png',
          ),
          throwsA(isA<ShareFailure>()),
        );
      },
    );

    test('cleanOldShareFiles forwards to local data source', () async {
      await repository.cleanOldShareFiles(olderThan: const Duration(hours: 3));
      expect(mockDataSource.cleanCalled, isTrue);
    });
  });
}
