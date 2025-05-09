import 'dart:io';

import 'package:dart_either/dart_either.dart';
import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../error/failures.dart';

part 'file_service.freezed.dart';
part 'file_service.g.dart';

@freezed
sealed class FileSelector with _$FileSelector {
  const factory FileSelector({required String label, required List<String> extensions}) = _FileSelector;
}

@freezed
sealed class FileSelectorResult with _$FileSelectorResult {
  const factory FileSelectorResult({required String path, required String name, required Uint8List data}) =
      _FileSelectorResult;
}

@freezed
sealed class FileRequest with _$FileRequest {
  const factory FileRequest({required String name, required Uint8List data}) = _FileRequest;
}

@riverpod
FileService fileService(Ref ref) {
  final nativeChannel = ref.watch(nativeChannelProvider);
  final imagePicker = ref.watch(imagePickerProvider);
  return FileService(nativeChannel, imagePicker);
}

@riverpod
image_picker.ImagePicker imagePicker(Ref ref) {
  return image_picker.ImagePicker();
}

abstract class IFileService {
  Future<Either<Failure, FileSelectorResult>> uploadFile(List<FileSelector> allowance);
  Future<Either<Failure, FileSelectorResult>> uploadImage();
}

final class FileService implements IFileService {
  const FileService(this._nativeChannel, this._imagePicker);

  final INativeChannel _nativeChannel;

  final image_picker.ImagePicker _imagePicker;

  Future<Either<Failure, bool>> _checkPermission() async {
    var permission = (await _nativeChannel.checkStoragePermission()).fold(
      ifLeft: (error) => throw Exception('Failed to check storage permission: $error'),
      ifRight: (value) => value,
    );
    if (!permission) {
      permission = (await _nativeChannel.requestStoragePermission()).fold(
        ifLeft: (error) => throw Exception('Failed to request storage permission: $error'),
        ifRight: (value) => value,
      );
    }
    return Right(permission);
  }

  @override
  Future<Either<Failure, FileSelectorResult>> uploadFile(List<FileSelector> allowance) async {
    if (Platform.isAndroid) {
      var permission = (await _checkPermission()).fold(
        ifLeft: (error) => throw Exception('Failed to check storage permission: $error'),
        ifRight: (value) => value,
      );
      if (!permission) {
        return const Left(StorageFailure('Storage permission denied'));
      }
    }
    var result =
        (await file_selector.openFile(
          acceptedTypeGroups: [
            ...allowance.map((e) => file_selector.XTypeGroup(label: e.label, extensions: e.extensions)),
          ],
        ))?.path;
    if (result == null) {
      return const Left(StorageFailure('File selection failed'));
    } else {
      if (Platform.isAndroid) {
        result = (await _nativeChannel.resolveUri(
          result,
        )).fold(ifLeft: (error) => throw Exception('Failed to resolve URI: $error'), ifRight: (value) => value);
      }
      return Right(FileSelectorResult(name: p.basename(result), path: result, data: await File(result).readAsBytes()));
    }
  }

  @override
  Future<Either<Failure, FileSelectorResult>> uploadImage() async {
    if (Platform.isAndroid) {
      var permission = (await _checkPermission()).fold(
        ifLeft: (error) => throw Exception('Failed to check storage permission: $error'),
        ifRight: (value) => value,
      );
      if (!permission) {
        return const Left(StorageFailure('Storage permission denied'));
      }
    }
    var pickedFile = await _imagePicker.pickImage(source: image_picker.ImageSource.gallery);
    if (pickedFile == null) {
      return const Left(StorageFailure('Image selection failed'));
    } else {
      var path = pickedFile.path;
      if (Platform.isAndroid) {
        path = (await _nativeChannel.resolveUri(
          path,
        )).fold(ifLeft: (error) => throw Exception('Failed to resolve URI: $error'), ifRight: (value) => value);
      }
      return Right(FileSelectorResult(name: p.basename(path), path: path, data: await pickedFile.readAsBytes()));
    }
  }
}

@riverpod
INativeChannel nativeChannel(Ref ref) {
  var methodChannel = null as MethodChannel?;
  if (Platform.isAndroid) {
    methodChannel = const MethodChannel('com.haruma.jobsit.it.MethodChannel');
  }
  return NativeChannel(methodChannel);
}

abstract class INativeChannel {
  Future<Either<Failure, bool>> requestStoragePermission();
  Future<Either<Failure, bool>> checkStoragePermission();
  Future<Either<Failure, String>> resolveUri(String path);
}

final class NativeChannel implements INativeChannel {
  const NativeChannel(this._channel);

  final MethodChannel? _channel;

  @override
  Future<Either<Failure, bool>> requestStoragePermission() async {
    try {
      final result = await _channel?.invokeMethod<bool>('requestStoragePermission');
      return Right(result!);
    } on PlatformException catch (e) {
      return Left(StorageFailure('Storage permission request failed: ${e.message}'));
    } catch (e) {
      return Left(StorageFailure('Storage permission request failed: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkStoragePermission() async {
    try {
      final result = await _channel?.invokeMethod<bool>('checkStoragePermission');
      return Right(result!);
    } on PlatformException catch (e) {
      return Left(StorageFailure('Storage permission request failed: ${e.message}'));
    } catch (e) {
      return Left(StorageFailure('Check storage permission request failed: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> resolveUri(String path) async {
    try {
      final result = await _channel?.invokeMethod<String>('resolveUri', {'path': path});
      return Right(result!);
    } on PlatformException catch (e) {
      return Left(StorageFailure('Storage permission request failed: ${e.message}'));
    } catch (e) {
      return Left(StorageFailure('Resolve URI request failed: $e'));
    }
  }
}
