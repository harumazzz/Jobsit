import 'dart:ui';

import 'package:dart_either/dart_either.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../error/failures.dart';
import '../network/dio_client.dart';
import '../usecases/usecase.dart';

part 'location_service.freezed.dart';
part 'location_service.g.dart';

@riverpod
ILocationService locationService(Ref ref) {
  final dio = ref.watch(provinceDioProvider);
  return ILocationService(dio);
}

@riverpod
ILocationRepository locationRepository(Ref ref) {
  final locationService = ref.watch(locationServiceProvider);
  return LocationRepositoryImpl(locationService);
}

@riverpod
SearchCitiesUseCase searchCitiesUseCase(Ref ref) {
  final locationRepository = ref.watch(locationRepositoryProvider);
  return SearchCitiesUseCase(locationRepository);
}

@riverpod
SearchDistrictsUseCase searchDistrictsUseCase(Ref ref) {
  final locationRepository = ref.watch(locationRepositoryProvider);
  return SearchDistrictsUseCase(locationRepository);
}

@freezed
sealed class SearchCitiesParams with _$SearchCitiesParams {
  const factory SearchCitiesParams({required int depth}) = _SearchCitiesParams;
}

@freezed
sealed class SearchDistrictsParams with _$SearchDistrictsParams {
  const factory SearchDistrictsParams({required int depth, required int code}) = _SearchDistrictsParams;
}

final class SearchCitiesUseCase implements UseCase<List<City>, SearchCitiesParams> {
  const SearchCitiesUseCase(this._locationRepository);

  final ILocationRepository _locationRepository;

  @override
  Future<Either<Failure, List<City>>> call(SearchCitiesParams params) async {
    return await _locationRepository.getCities(params.depth);
  }
}

final class SearchDistrictsUseCase implements UseCase<List<District>, SearchDistrictsParams> {
  const SearchDistrictsUseCase(this._locationRepository);

  final ILocationRepository _locationRepository;

  @override
  Future<Either<Failure, List<District>>> call(SearchDistrictsParams params) async {
    return await _locationRepository.getDistricts(params.code, params.depth);
  }
}

abstract class ILocationRepository {
  Future<Either<Failure, List<City>>> getCities(int depth);
  Future<Either<Failure, List<District>>> getDistricts(int cityCode, int depth);
}

final class LocationRepositoryImpl implements ILocationRepository {
  const LocationRepositoryImpl(this._locationService);

  final ILocationService _locationService;

  @override
  Future<Either<Failure, List<City>>> getCities(int depth) async {
    try {
      final response = await _locationService.getCities(depth);
      return Right(response.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<District>>> getDistricts(int cityCode, int depth) async {
    try {
      final response = await _locationService.getDistricts(cityCode, depth);
      return Right(response.districts.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

@freezed
sealed class CityResponse with _$CityResponse {
  const factory CityResponse({
    required int code,
    required String name,
    required String codename,
    @JsonKey(name: 'division_type') required String divisionType,
    @JsonKey(name: 'phone_code') required int phoneCode,
    required List<DistrictResponse> districts,
  }) = _CityResponse;

  factory CityResponse.fromJson(Map<String, dynamic> json) => _$CityResponseFromJson(json);
}

@freezed
sealed class DistrictCityResponse with _$DistrictCityResponse {
  const factory DistrictCityResponse({
    required int code,
    required String name,
    required String codename,
    @JsonKey(name: 'division_type') required String divisionType,
    @JsonKey(name: 'phone_code') required int phoneCode,
    @JsonKey(name: 'districts') required List<DistrictResponse> districts,
  }) = _DistrictCityResponse;

  factory DistrictCityResponse.fromJson(Map<String, dynamic> json) => _$DistrictCityResponseFromJson(json);
}

@freezed
sealed class DistrictResponse with _$DistrictResponse {
  const factory DistrictResponse({
    required int code,
    required String name,
    required String codename,
    @JsonKey(name: 'division_type') required String divisionType,
    @JsonKey(name: 'province_code') required int provinceCode,
    required List<WardResponse> wards,
  }) = _DistrictResponse;

  factory DistrictResponse.fromJson(Map<String, dynamic> json) => _$DistrictResponseFromJson(json);
}

@freezed
sealed class WardResponse with _$WardResponse {
  const factory WardResponse({
    required int code,
    required String name,
    required String codename,
    @JsonKey(name: 'division_type') required String divisionType,
    @JsonKey(name: 'short_codename') required String shortCodename,
  }) = _WardResponse;

  factory WardResponse.fromJson(Map<String, dynamic> json) => _$WardResponseFromJson(json);
}

@RestApi()
abstract class ILocationService {
  factory ILocationService(Dio dio) = _ILocationService;

  @GET('/')
  Future<List<CityResponse>> getCities(@Query('depth') int depth);

  @GET('/p/{cityCode}')
  Future<DistrictCityResponse> getDistricts(@Path() int cityCode, @Query('depth') int depth);
}

@freezed
@keepToString
abstract class City with _$City {
  const factory City({
    required int code,
    required String name,
    required String codename,
    required String divisionType,
    required int phoneCode,
    required List<District> districts,
  }) = _City;
}

@freezed
sealed class District with _$District {
  const factory District({
    required int code,
    required String name,
    required String codename,
    required String divisionType,
    required int provinceCode,
    required List<Ward> wards,
  }) = _District;
}

@freezed
sealed class Ward with _$Ward {
  const factory Ward({
    required int code,
    required String name,
    required String codename,
    required String divisionType,
    required String shortCodename,
  }) = _Ward;
}

extension WardResponseExtension on WardResponse {
  Ward toEntity() {
    return Ward(code: code, name: name, codename: codename, divisionType: divisionType, shortCodename: shortCodename);
  }
}

extension DistrictResponseExtension on DistrictResponse {
  District toEntity() {
    return District(
      code: code,
      name: name,
      codename: codename,
      divisionType: divisionType,
      provinceCode: provinceCode,
      wards: wards.map((e) => e.toEntity()).toList(),
    );
  }
}

extension CityResponseExtension on CityResponse {
  City toEntity() {
    return City(
      code: code,
      name: name,
      codename: codename,
      divisionType: divisionType,
      phoneCode: phoneCode,
      districts: districts.map((e) => e.toEntity()).toList(),
    );
  }
}
