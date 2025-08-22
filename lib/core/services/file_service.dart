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

/// Represents a file type filter for file selection dialogs.
@freezed
sealed class FileSelector with _$FileSelector {
  /// Creates a [FileSelector] instance.
  ///
  /// [label] is a human-readable description of the file type (e.g., "Images").
  /// [extensions] is a list of file extensions (e.g., ["jpg", "png"]).
  const factory FileSelector({
    required final String label,
    required final List<String> extensions,
  }) = _FileSelector;
}

/// Represents the result of a successful file selection.
@freezed
sealed class FileSelectorResult with _$FileSelectorResult {
  /// Creates a [FileSelectorResult] instance.
  ///
  /// [path] is the absolute path to the selected file.
  /// [name] is the name of the selected file.
  /// [data] is the byte content of the selected file.
  const factory FileSelectorResult({
    required final String path,
    required final String name,
    required final Uint8List data,
  }) = _FileSelectorResult;
}

/// Represents a file to be processed, typically for uploading.
@freezed
sealed class FileRequest with _$FileRequest {
  /// Creates a [FileRequest] instance.
  ///
  /// [name] is the name of the file.
  /// [data] is the byte content of the file.
  const factory FileRequest({
    required final String name,
    required final Uint8List data,
  }) = _FileRequest;
}

/// Provides an instance of [FileService].
@riverpod
FileService fileService(final Ref ref) {
  final nativeChannel = ref.watch(nativeChannelProvider);
  final imagePicker = ref.watch(imagePickerProvider);
  return FileService(nativeChannel, imagePicker);
}

/// Provides an instance of [image_picker.ImagePicker].
@riverpod
image_picker.ImagePicker imagePicker(
  final Ref ref,
) => image_picker.ImagePicker();

/// Interface for file service operations like uploading files and images.
abstract class IFileService {
  /// Allows the user to select a file based on the provided [allowance].
  ///
  /// [allowance] is a list of [FileSelector] defining acceptable file types.
  /// Returns a [FileSelectorResult] on success, or a [Failure] on error.
  Future<Either<Failure, FileSelectorResult>> uploadFile(
    final List<FileSelector> allowance,
  );

  /// Allows the user to select an image from the gallery.
  ///
  /// Returns a [FileSelectorResult] on success, or a [Failure] on error.
  Future<Either<Failure, FileSelectorResult>> uploadImage();
}

/// Concrete implementation of [IFileService].
///
/// Handles file and image picking, including permission checks on Android.
final class FileService implements IFileService {
  /// Creates a [FileService].
  ///
  /// Requires an [INativeChannel] for platform-specific operations (like
  /// permission handling and URI resolution on Android) and an
  /// [image_picker.ImagePicker] for image selection.
  const FileService(this._nativeChannel, this._imagePicker);

  final INativeChannel _nativeChannel;

  final image_picker.ImagePicker _imagePicker;

  /// Checks and requests storage permission on Android if necessary.
  ///
  /// Returns `true` if permission is granted, `false` otherwise.
  /// Throws an exception if checking or requesting permission fails internally.
  Future<Either<Failure, bool>> _checkPermission() async {
    var permission = (await _nativeChannel.checkStoragePermission()).fold(
      ifLeft: (final error) {
        final message = 'Failed to check storage permission: $error';
        return throw Exception(message);
      },
      ifRight: (final value) => value,
    );
    if (!permission) {
      permission = (await _nativeChannel.requestStoragePermission()).fold(
        ifLeft: (final error) {
          final message = 'Failed to request storage permission: $error';
          return throw Exception(message);
        },
        ifRight: (final value) => value,
      );
    }
    return Right(permission);
  }

  @override
  Future<Either<Failure, FileSelectorResult>> uploadFile(
    final List<FileSelector> allowance,
  ) async {
    if (Platform.isAndroid) {
      final permission = (await _checkPermission()).fold(
        ifLeft: (final error) {
          final message = 'Failed to check storage permission: $error';
          return throw Exception(message);
        },
        ifRight: (final value) => value,
      );
      if (!permission) {
        return const Left(StorageFailure('Storage permission denied'));
      }
    }
    var result =
        (await file_selector.openFile(
          acceptedTypeGroups: [
            ...allowance.map(
              (final e) => file_selector.XTypeGroup(
                label: e.label,
                extensions: e.extensions,
                uniformTypeIdentifiers: e.extensions,
              ),
            ),
          ],
        ))?.path;
    if (result == null) {
      return const Left(StorageFailure('File selection failed'));
    } else {
      if (Platform.isAndroid) {
        result = (await _nativeChannel.resolveUri(result)).fold(
          ifLeft: (final error) {
            final message = 'Failed to resolve URI: $error';
            return throw Exception(message);
          },
          ifRight: (final value) => value,
        );
      }
      return Right(
        FileSelectorResult(
          name: p.basename(result),
          path: result,
          data: await File(result).readAsBytes(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, FileSelectorResult>> uploadImage() async {
    if (Platform.isAndroid) {
      final permission = (await _checkPermission()).fold(
        ifLeft: (final error) {
          final message = 'Failed to check storage permission: $error';
          return throw Exception(message);
        },
        ifRight: (final value) => value,
      );
      if (!permission) {
        return const Left(StorageFailure('Storage permission denied'));
      }
    }
    final pickedFile = await _imagePicker.pickImage(
      source: image_picker.ImageSource.gallery,
    );
    if (pickedFile == null) {
      return const Left(StorageFailure('Image selection failed'));
    } else {
      var path = pickedFile.path;
      if (Platform.isAndroid) {
        path = (await _nativeChannel.resolveUri(path)).fold(
          ifLeft: (final error) {
            final message = 'Failed to resolve URI: $error';
            return throw Exception(message);
          },
          ifRight: (final value) => value,
        );
      }
      return Right(
        FileSelectorResult(
          name: p.basename(path),
          path: path,
          data: await pickedFile.readAsBytes(),
        ),
      );
    }
  }
}

/// Provides an instance of [INativeChannel].
///
/// Initializes a [MethodChannel] for Android to communicate with native code.
/// For other platforms, the channel will be null.
@riverpod
INativeChannel nativeChannel(final Ref ref) {
  var methodChannel = null as MethodChannel?;
  if (Platform.isAndroid) {
    methodChannel = const MethodChannel('com.haruma.jobsit.it.MethodChannel');
  }
  return NativeChannel(methodChannel);
}

/// Interface for platform-specific native operations.
///
/// This is primarily used for Android to handle storage permissions
/// and resolve content URIs to absolute file paths.
abstract class INativeChannel {
  /// Requests storage permission from the user (primarily for Android).
  ///
  /// Returns `true` if permission is granted, `false` otherwise, or a
  /// [Failure] on error.
  Future<Either<Failure, bool>> requestStoragePermission();

  /// Checks if storage permission has already been granted.
  ///
  /// Returns `true` if permission is granted, `false` otherwise, or a
  /// [Failure] on error.
  Future<Either<Failure, bool>> checkStoragePermission();

  /// Resolves a content URI to an absolute file path (primarily for Android).
  ///
  /// [path] The URI (often a content URI) to resolve.
  /// Returns the absolute file path on success, or a [Failure] on error.
  Future<Either<Failure, String>> resolveUri(final String path);
}

/// Concrete implementation of [INativeChannel].
///
/// Uses a [MethodChannel] to invoke native Android methods.
final class NativeChannel implements INativeChannel {
  /// Creates a [NativeChannel].
  ///
  /// It can be null if not on Android or if native integration is not needed.
  const NativeChannel(this._channel);

  final MethodChannel? _channel;

  @override
  Future<Either<Failure, bool>> requestStoragePermission() async {
    try {
      final result = await _channel?.invokeMethod<bool>(
        'requestStoragePermission',
      );
      return Right(result!);
    } on PlatformException catch (e) {
      return Left(
        StorageFailure(
          'Storage permission request failed: ${e.message}',
        ),
      );
    } catch (e) {
      return Left(StorageFailure('Storage permission request failed: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkStoragePermission() async {
    try {
      final result = await _channel?.invokeMethod<bool>(
        'checkStoragePermission',
      );
      return Right(result!);
    } on PlatformException catch (e) {
      return Left(
        StorageFailure(
          'Storage permission request failed: ${e.message}',
        ),
      );
    } catch (e) {
      return Left(
        StorageFailure('Check storage permission request failed: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> resolveUri(final String path) async {
    try {
      final result = await _channel?.invokeMethod<String>(
        'resolveUri',
        {'path': path},
      );
      return Right(result!);
    } on PlatformException catch (e) {
      return Left(
        StorageFailure('Storage permission request failed: ${e.message}'),
      );
    } catch (e) {
      return Left(StorageFailure('Resolve URI request failed: $e'));
    }
  }
}
