import 'dart:ui';

import 'package:dart_either/dart_either.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:retrofit/http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../error/failures.dart';
import '../network/dio_client.dart';
import '../usecases/usecase.dart';

part 'location_service.freezed.dart';
part 'location_service.g.dart';

/// Provides an instance of [ILocationService] for interacting with the
/// province/city/district API.
@riverpod
ILocationService locationService(final Ref ref) {
  final dio = ref.watch(provinceDioProvider);
  return ILocationService(dio);
}

/// Provides an instance of [ILocationRepository] for fetching location data.
@riverpod
ILocationRepository locationRepository(final Ref ref) {
  final locationService = ref.watch(locationServiceProvider);
  return LocationRepositoryImpl(locationService);
}

/// Provides an instance of [SearchCitiesUseCase] for searching cities.
@riverpod
SearchCitiesUseCase searchCitiesUseCase(final Ref ref) {
  final locationRepository = ref.watch(locationRepositoryProvider);
  return SearchCitiesUseCase(locationRepository);
}

/// Provides an instance of [SearchDistrictsUseCase] for searching districts.
@riverpod
SearchDistrictsUseCase searchDistrictsUseCase(final Ref ref) {
  final locationRepository = ref.watch(locationRepositoryProvider);
  return SearchDistrictsUseCase(locationRepository);
}

/// Parameters for searching cities.
@freezed
sealed class SearchCitiesParams with _$SearchCitiesParams {
  /// Creates [SearchCitiesParams].
  ///
  /// [depth] determines the level of detail for related data (e.g., districts).
  const factory SearchCitiesParams({
    required final int depth,
  }) = _SearchCitiesParams;
}

/// Parameters for searching districts.
@freezed
sealed class SearchDistrictsParams with _$SearchDistrictsParams {
  /// Creates [SearchDistrictsParams].
  ///
  /// [depth] determines the level of detail for related data (e.g., wards).
  /// [code] is the code of the city to search districts within.
  const factory SearchDistrictsParams({
    required final int depth,
    required final int code,
  }) = _SearchDistrictsParams;
}

/// Use case for searching/fetching a list of cities.
class SearchCitiesUseCase implements UseCase<List<City>, SearchCitiesParams> {
  /// Creates a [SearchCitiesUseCase].
  const SearchCitiesUseCase(this._locationRepository);

  final ILocationRepository _locationRepository;

  /// Fetches a list of cities based on the provided [params].
  @override
  Future<Either<Failure, List<City>>> call(
    final SearchCitiesParams params,
  ) async => _locationRepository.getCities(params.depth);
}

typedef _DParams = SearchDistrictsParams;

/// Use case for searching/fetching a list of districts within a city.
class SearchDistrictsUseCase implements UseCase<List<District>, _DParams> {
  /// Creates a [SearchDistrictsUseCase].
  const SearchDistrictsUseCase(this._locationRepository);

  final ILocationRepository _locationRepository;

  /// Fetches a list of districts based on the provided [params].
  @override
  Future<Either<Failure, List<District>>> call(
    final SearchDistrictsParams params,
  ) async => _locationRepository.getDistricts(params.code, params.depth);
}

/// Repository interface for accessing location data (cities, districts).
abstract class ILocationRepository {
  /// Fetches a list of cities.
  ///
  /// [depth] controls the amount of nested data (e.g., districts) returned.
  Future<Either<Failure, List<City>>> getCities(final int depth);

  /// Fetches a list of districts for a given [cityCode].
  ///
  /// [depth] controls the amount of nested data (e.g., wards) returned.
  Future<Either<Failure, List<District>>> getDistricts(
    final int cityCode,
    final int depth,
  );
}

/// Implementation of [ILocationRepository].
final class LocationRepositoryImpl implements ILocationRepository {
  /// Creates a [LocationRepositoryImpl].
  const LocationRepositoryImpl(this._locationService);

  final ILocationService _locationService;

  @override
  Future<Either<Failure, List<City>>> getCities(final int depth) async {
    try {
      final response = await _locationService.getCities(depth);
      return Right(response.map((final e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<District>>> getDistricts(
    final int cityCode,
    final int depth,
  ) async {
    try {
      final response = await _locationService.getDistricts(cityCode, depth);
      return Right(response.districts.map((final e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

/// API response model for a city.
@freezed
sealed class CityResponse with _$CityResponse {
  /// Creates a [CityResponse].
  const factory CityResponse({
    required final int code,
    required final String name,
    required final String codename,
    @JsonKey(name: 'division_type') required final String divisionType,
    @JsonKey(name: 'phone_code') required final int phoneCode,
    required final List<DistrictResponse> districts,
  }) = _CityResponse;

  /// Creates a [CityResponse] from a JSON map.
  factory CityResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$CityResponseFromJson(json);
}

/// API response model for a city when fetching districts.
/// This structure is specific to the districts endpoint.
@freezed
sealed class DistrictCityResponse with _$DistrictCityResponse {
  /// Creates a [DistrictCityResponse].
  const factory DistrictCityResponse({
    required final int code,
    required final String name,
    required final String codename,
    @JsonKey(name: 'division_type') required final String divisionType,
    @JsonKey(name: 'phone_code') required final int phoneCode,
    @JsonKey(name: 'districts') required final List<DistrictResponse> districts,
  }) = _DistrictCityResponse;

  /// Creates a [DistrictCityResponse] from a JSON map.
  factory DistrictCityResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$DistrictCityResponseFromJson(json);
}

/// API response model for a district.
@freezed
sealed class DistrictResponse with _$DistrictResponse {
  /// Creates a [DistrictResponse].
  const factory DistrictResponse({
    required final int code,
    required final String name,
    required final String codename,
    @JsonKey(name: 'division_type') required final String divisionType,
    @JsonKey(name: 'province_code') required final int provinceCode,
    required final List<WardResponse> wards,
  }) = _DistrictResponse;

  /// Creates a [DistrictResponse] from a JSON map.
  factory DistrictResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$DistrictResponseFromJson(json);
}

/// API response model for a ward.
@freezed
sealed class WardResponse with _$WardResponse {
  /// Creates a [WardResponse].
  const factory WardResponse({
    required final int code,
    required final String name,
    required final String codename,
    @JsonKey(name: 'division_type') required final String divisionType,
    @JsonKey(name: 'short_codename') required final String shortCodename,
  }) = _WardResponse;

  /// Creates a [WardResponse] from a JSON map.
  factory WardResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$WardResponseFromJson(json);
}

/// Retrofit service definition for location-based API calls.
@RestApi()
abstract class ILocationService {
  /// Creates an [ILocationService] instance.
  factory ILocationService(final Dio dio) = _ILocationService;

  /// Fetches a list of cities.
  ///
  /// [depth] determines the level of detail (e.g., including districts).
  @GET('/')
  Future<List<CityResponse>> getCities(@Query('depth') final int depth);

  /// Fetches districts for a specific city.
  ///
  /// [cityCode] is the code of the city.
  /// [depth] determines the level of detail (e.g., including wards).
  @GET('/p/{cityCode}')
  Future<DistrictCityResponse> getDistricts(
    @Path() final int cityCode,
    @Query('depth') final int depth,
  );
}

/// Represents a city entity.
@freezed
@keepToString
abstract class City with _$City {
  /// Creates a [City] instance.
  const factory City({
    required final int code,
    required final String name,
    required final String codename,
    required final String divisionType,
    required final int phoneCode,
    required final List<District> districts,
  }) = _City;
}

/// Represents a district entity.
@freezed
sealed class District with _$District {
  /// Creates a [District] instance.
  const factory District({
    required final int code,
    required final String name,
    required final String codename,
    required final String divisionType,
    required final int provinceCode,
    required final List<Ward> wards,
  }) = _District;
}

/// Represents a ward entity.
@freezed
sealed class Ward with _$Ward {
  /// Creates a [Ward] instance.
  const factory Ward({
    required final int code,
    required final String name,
    required final String codename,
    required final String divisionType,
    required final String shortCodename,
  }) = _Ward;
}

/// Extension methods for [WardResponse].
extension WardResponseExtension on WardResponse {
  /// Converts a [WardResponse] to a [Ward] entity.
  Ward toEntity() => Ward(
    code: code,
    name: name,
    codename: codename,
    divisionType: divisionType,
    shortCodename: shortCodename,
  );
}

/// Extension methods for [DistrictResponse].
extension DistrictResponseExtension on DistrictResponse {
  /// Converts a [DistrictResponse] to a [District] entity.
  District toEntity() => District(
    code: code,
    name: name,
    codename: codename,
    divisionType: divisionType,
    provinceCode: provinceCode,
    wards: wards.map((final e) => e.toEntity()).toList(),
  );
}

/// Extension methods for [CityResponse].
extension CityResponseExtension on CityResponse {
  /// Converts a [CityResponse] to a [City] entity.
  City toEntity() => City(
    code: code,
    name: name,
    codename: codename,
    divisionType: divisionType,
    phoneCode: phoneCode,
    districts: districts.map((final e) => e.toEntity()).toList(),
  );
}
