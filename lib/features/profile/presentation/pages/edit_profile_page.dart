import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_constant.dart';
import '../../../../core/services/file_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/input_converter.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/domain/entities/user.dart' show University;
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../jobs/domain/entities/job.dart';
import '../../../jobs/presentation/pages/job_detail_page.dart';
import '../../../jobs/presentation/providers/job_provider.dart';

class PersonalInfoEditPage extends HookConsumerWidget {
  const PersonalInfoEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.read(authControllerProvider) is! AuthAuthorized) {
      return Center(child: Text(context.t.auth.notAllowedToView));
    }
    final currentState = ref.read(authControllerProvider) as AuthAuthorized;
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final image = useState<FileSelectorResult?>(null);
    final firstNameController = useTextEditingController(text: currentState.user.userInfo.firstName);
    final lastNameController = useTextEditingController(text: currentState.user.userInfo.lastName);
    final emailController = useTextEditingController(text: currentState.user.userInfo.email);
    final phoneController = useTextEditingController(text: currentState.user.userInfo.phone);
    final addressController = useTextEditingController(text: currentState.user.userInfo.address);
    final selectedUniversity = useState<University?>(
      currentState.user.jobInfo.university != null
          ? (ref.read(universityControllerProvider) as UniversityLoaded).universities.firstWhere(
            (university) => university.id == currentState.user.jobInfo.university!.id,
          )
          : null,
    );
    final firstNameFocusNode = useFocusNode();
    final lastNameFocusNode = useFocusNode();
    final emailFocusNode = useFocusNode();
    final dateFocusNode = useFocusNode();
    final phoneFocusNode = useFocusNode();
    final genderFocusNode = useFocusNode();
    final cityFocusNode = useFocusNode();
    final districtFocusNode = useFocusNode();
    final addressFocusNode = useFocusNode();
    final universityFocusNode = useFocusNode();
    final genderOptions = [context.t.profile.male, context.t.profile.female];
    final cityOptions = (ref.read(citiesControllerProvider) as CitiesLoaded).cities;
    final selectedGender = useState(
      currentState.user.userInfo.gender ? context.t.profile.male : context.t.profile.female,
    );
    final selectedCity = useState<City?>(
      currentState.user.userInfo.city != null
          ? (ref.read(citiesControllerProvider) as CitiesLoaded).cities.firstWhere(
            (city) => city.name.contains(currentState.user.userInfo.city!),
          )
          : null,
    );
    final selectedDistrict = useState<District?>(null);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = ref.read(districtsControllerProvider);
      if (state is DistrictsInitial && selectedCity.value != null) {
        await ref.read(districtsControllerProvider.notifier).getDistricts(code: selectedCity.value!.code);
        if (currentState.user.userInfo.district != null) {
          final districtsState = ref.read(districtsControllerProvider);
          if (districtsState is DistrictsLoaded) {
            try {
              final district = districtsState.districts.firstWhere(
                (district) => district.name.contains(currentState.user.userInfo.district!),
              );
              selectedDistrict.value = district;
            } catch (e) {
              debugPrint('District not found: $e');
            }
          }
        }
      }
      if (state is DistrictsLoaded && selectedCity.value != null) {
        if (currentState.user.userInfo.district != null) {
          try {
            final district = state.districts.firstWhere(
              (district) => district.name.contains(currentState.user.userInfo.district!),
            );
            selectedDistrict.value = district;
          } catch (e) {
            debugPrint('District not found: $e');
          }
        }
      }
    });
    if (selectedCity.value != null && ref.watch(districtsControllerProvider) is! DistrictsLoaded) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)));
    }
    final selectedDate = useState<DateTime?>(
      currentState.user.userInfo.birthDate != null
          ? DateFormat('dd-MM-yyyy').parse(currentState.user.userInfo.birthDate!)
          : DateTime.now(),
    );
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: const Color(0xFff5fafd),
        title: Text(context.t.profile.personalInformation, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 86.0,
                        height: 86.0,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).primaryColor, width: 2.0),
                        ),
                        child:
                            image.value != null
                                ? ClipOval(
                                  child: Image.memory(image.value!.data, fit: BoxFit.cover, width: 86.0, height: 86.0),
                                )
                                : currentState.user.userInfo.avatar != null
                                ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: queryImage(currentState.user.userInfo.avatar!),
                                    fit: BoxFit.cover,
                                    width: 86.0,
                                    height: 86.0,
                                  ),
                                )
                                : const Icon(IconlyLight.profile, size: 48.0, color: Colors.grey),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                          child: IconButton(
                            icon: Icon(IconlyLight.edit, color: Theme.of(context).colorScheme.onPrimary, size: 16.0),
                            onPressed: () async {
                              final result = await ref.read(fileServiceProvider).uploadImage();
                              result.fold(
                                ifLeft: (_) => null,
                                ifRight: (value) {
                                  if (value.data.length > 512 * 1024) {
                                    NotificationService.error(
                                      context: context,
                                      message: context.t.validation.file.avatarSize,
                                    );
                                    return;
                                  }
                                  if (!RegExp(r'\.(jpg|png)$', caseSensitive: false).hasMatch(value.path)) {
                                    NotificationService.error(
                                      context: context,
                                      message: context.t.validation.format.mismatchImage,
                                    );
                                    return;
                                  }
                                  image.value = value;
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  context.t.auth.firstName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                FormBuilderTextField(
                  name: 'first_name',
                  controller: firstNameController,
                  focusNode: firstNameFocusNode,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: (value) => InputConverter.validateFirstName(value, context),
                  onSubmitted: (_) async {
                    firstNameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(lastNameFocusNode);
                  },
                ),
                const SizedBox(height: 16.0),
                Text(
                  context.t.auth.lastName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                FormBuilderTextField(
                  name: 'last_name',
                  controller: lastNameController,
                  focusNode: lastNameFocusNode,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: (value) => InputConverter.validateLastName(value, context),
                  onSubmitted: (_) async {
                    lastNameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(emailFocusNode);
                  },
                ),
                const SizedBox(height: 16.0),
                Text(
                  context.t.auth.email,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                FormBuilderTextField(
                  name: 'email',
                  controller: emailController,
                  focusNode: emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: (value) => InputConverter.validateEmail(value, context),
                  onSubmitted: (_) async {
                    emailFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(dateFocusNode);
                  },
                ),
                const SizedBox(height: 16.0),
                Text(
                  context.t.auth.dateOfBirth,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                FormBuilderDateTimePicker(
                  name: 'date_of_birth',
                  focusNode: dateFocusNode,
                  initialValue: selectedDate.value,
                  inputType: InputType.date,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    suffixIcon: Icon(IconlyLight.calendar),
                  ),
                  onChanged: (value) async => selectedDate.value = value,
                  onFieldSubmitted: (_) async {
                    dateFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(phoneFocusNode);
                  },
                ),
                const SizedBox(height: 16.0),
                Text(
                  context.t.auth.phone,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                FormBuilderTextField(
                  name: 'phone',
                  controller: phoneController,
                  focusNode: phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: (value) => InputConverter.validatePhone(value, context),
                  onSubmitted: (_) async {
                    phoneFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(genderFocusNode);
                  },
                ),
                const SizedBox(height: 16.0),
                Text(
                  context.t.auth.gender,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return MenuAnchor(
                      style: MenuStyle(
                        minimumSize: WidgetStatePropertyAll(Size(constraints.maxWidth + 8, 0)),
                        maximumSize: WidgetStatePropertyAll(Size(constraints.maxWidth + 8, double.infinity)),
                        elevation: WidgetStateProperty.all(4.0),
                      ),
                      crossAxisUnconstrained: false,
                      alignmentOffset: const Offset(0, 8),
                      builder: (context, controller, child) {
                        return FormBuilderField(
                          name: 'gender',
                          focusNode: genderFocusNode,
                          validator: (value) => null,
                          builder: (FormFieldState<dynamic> field) {
                            return InputDecorator(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  controller.open();
                                },
                                child: Text(selectedGender.value),
                              ),
                            );
                          },
                        );
                      },
                      menuChildren: [
                        ...genderOptions.map((gender) {
                          return MenuItemButton(
                            onPressed: () async {
                              selectedGender.value = gender;
                              genderFocusNode.unfocus();
                              FocusScope.of(context).requestFocus(cityFocusNode);
                            },
                            child: Text(gender),
                          );
                        }),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                Text(
                  context.t.auth.city,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return MenuAnchor(
                      style: MenuStyle(
                        minimumSize: WidgetStatePropertyAll(Size(constraints.maxWidth + 8, 0)),
                        maximumSize: WidgetStatePropertyAll(Size(constraints.maxWidth + 8, double.infinity)),
                        elevation: WidgetStateProperty.all(4.0),
                      ),
                      crossAxisUnconstrained: false,
                      alignmentOffset: const Offset(0, 8),
                      builder: (context, controller, child) {
                        return FormBuilderField(
                          name: 'city',
                          focusNode: cityFocusNode,
                          validator: (value) => null,
                          builder: (FormFieldState<dynamic> field) {
                            return InputDecorator(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  controller.open();
                                },
                                child: Text(
                                  selectedCity.value != null ? selectedCity.value!.name : context.t.auth.selectCity,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      menuChildren: [
                        ...cityOptions.map((city) {
                          return MenuItemButton(
                            onPressed: () async {
                              selectedDistrict.value = null;
                              await ref.read(districtsControllerProvider.notifier).reset();
                              selectedCity.value = city;
                              await ref
                                  .read(districtsControllerProvider.notifier)
                                  .getDistricts(code: selectedCity.value!.code);

                              cityFocusNode.unfocus();
                              if (context.mounted) {
                                FocusScope.of(context).requestFocus(districtFocusNode);
                              }
                            },
                            child: Text(city.name),
                          );
                        }),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                Text(
                  context.t.auth.district,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final state = ref.watch(districtsControllerProvider);
                    return MenuAnchor(
                      style: MenuStyle(
                        minimumSize: WidgetStatePropertyAll(Size(constraints.maxWidth + 8, 0)),
                        maximumSize: WidgetStatePropertyAll(Size(constraints.maxWidth + 8, double.infinity)),
                        elevation: WidgetStateProperty.all(4.0),
                      ),
                      crossAxisUnconstrained: false,
                      alignmentOffset: const Offset(0, 8),
                      builder: (context, controller, child) {
                        return FormBuilderField(
                          name: 'district',
                          focusNode: districtFocusNode,
                          validator: (value) => null,
                          builder: (FormFieldState<dynamic> field) {
                            final String displayText;
                            var isEnabled = true;
                            if (selectedCity.value == null) {
                              displayText = context.t.auth.selectCity;
                              isEnabled = false;
                            } else if (state is! DistrictsLoaded) {
                              displayText = context.t.auth.loadingDistrict;
                              isEnabled = false;
                            } else if (selectedDistrict.value != null) {
                              displayText = selectedDistrict.value!.name;
                            } else {
                              displayText = context.t.auth.selectDistrict;
                            }
                            return InputDecorator(
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                                contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                                enabled: isEnabled,
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  if (isEnabled) {
                                    controller.open();
                                  }
                                },
                                child: Text(displayText, style: isEnabled ? null : const TextStyle(color: Colors.grey)),
                              ),
                            );
                          },
                        );
                      },
                      menuChildren: [
                        ...(state is DistrictsLoaded ? state.districts : []).map((district) {
                          return MenuItemButton(
                            onPressed: () async {
                              selectedDistrict.value = district;
                              districtFocusNode.unfocus();
                              FocusScope.of(context).requestFocus(addressFocusNode);
                            },
                            child: Text(district.name),
                          );
                        }),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                Text(
                  context.t.auth.address,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                FormBuilderTextField(
                  name: 'address',
                  controller: addressController,
                  focusNode: addressFocusNode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: (value) => InputConverter.validateAddress(value, context),
                  onSubmitted: (_) async {
                    addressFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(universityFocusNode);
                  },
                ),
                const SizedBox(height: 16.0),
                Text(
                  context.t.auth.university,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final state = ref.watch(universityControllerProvider);
                    return MenuAnchor(
                      style: MenuStyle(
                        minimumSize: WidgetStatePropertyAll(Size(constraints.maxWidth + 8, 0)),
                        maximumSize: WidgetStatePropertyAll(Size(constraints.maxWidth + 8, double.infinity)),
                        elevation: WidgetStateProperty.all(4.0),
                      ),
                      crossAxisUnconstrained: false,
                      alignmentOffset: const Offset(0, 8),
                      menuChildren: [
                        ...(state is UniversityLoaded ? state.universities : []).map((university) {
                          return MenuItemButton(
                            onPressed: () async {
                              selectedUniversity.value = university;
                              universityFocusNode.unfocus();
                            },
                            child: Text(university.name),
                          );
                        }),
                      ],
                      builder: (context, controller, child) {
                        return FormBuilderField(
                          name: 'university',
                          focusNode: universityFocusNode,
                          validator: (value) => null,
                          builder: (FormFieldState<dynamic> field) {
                            return InputDecorator(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  controller.open();
                                },
                                child: Text(
                                  selectedUniversity.value != null
                                      ? selectedUniversity.value!.name
                                      : context.t.auth.selectUniversity,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            return _CustomNavbar(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  await ref
                      .read(authControllerProvider.notifier)
                      .updateUserInfo(
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        phone: phoneController.text,
                        birthDay: DateFormat('dd-MM-yyyy').format(selectedDate.value!),
                        gender: genderOptions.indexOf(selectedGender.value),
                        location:
                            '${selectedCity.value?.name}, ${selectedDistrict.value?.name}, ${addressController.text}',
                        avatar: image.value,
                        city: selectedCity.value!.name,
                        district: selectedDistrict.value!.name,
                        university: selectedUniversity.value!,
                      );
                  if (context.mounted) {
                    NotificationService.success(context: context, message: context.t.profile.updateSuccess);
                    context.pop();
                  }
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class JobInfoEditPage extends HookConsumerWidget {
  const JobInfoEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.read(authControllerProvider) is! AuthAuthorized) {
      return Center(child: Text(context.t.auth.notAllowedToView));
    }
    final currentState = ref.read(authControllerProvider) as AuthAuthorized;
    final jobInfo = currentState.user.jobInfo;

    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final jobWantedController = useTextEditingController(text: jobInfo.desiredJob);
    final coverLetterController = useTextEditingController(text: jobInfo.referenceLetter);
    final cvPlaceholderController = useTextEditingController(
      text: jobInfo.cv != null ? jobInfo.cv!.split('/').last : context.t.job.cvPlaceholder,
    );

    final jobWantedFocusNode = useFocusNode();
    final positionFocusNode = useFocusNode();
    final majorFocusNode = useFocusNode();
    final jobTypeFocusNode = useFocusNode();
    final locationFocusNode = useFocusNode();
    final cvFocusNode = useFocusNode();
    final coverLetterFocusNode = useFocusNode();

    final cv = useState<FileSelectorResult?>(null);
    final selectedPositions = useState<Set<Position>>(
      jobInfo.positions.map((p) => Position(id: p.id, name: p.name)).toSet(),
    );
    final selectedMajors = useState<Set<Major>>(jobInfo.majors.map((m) => Major(id: m.id, name: m.name)).toSet());
    final selectedJobTypes = useState<Set<Schedule>>(
      jobInfo.schedules.map((s) => Schedule(id: s.id, name: s.name)).toSet(),
    );
    final selectedCity = useState<City?>(
      jobInfo.desiredWorkingProvince != null
          ? (ref.read(citiesControllerProvider) as CitiesLoaded).cities.firstWhere(
            (city) => city.name.contains(jobInfo.desiredWorkingProvince!),
          )
          : null,
    );

    final positionOverlayEntry = useState<OverlayEntry?>(null);
    final majorOverlayEntry = useState<OverlayEntry?>(null);
    final jobTypeOverlayEntry = useState<OverlayEntry?>(null);
    final locationOverlayEntry = useState<OverlayEntry?>(null);

    final positionKey = useMemoized(GlobalKey<FormFieldState>.new);
    final majorKey = useMemoized(GlobalKey<FormFieldState>.new);
    final jobTypeKey = useMemoized(GlobalKey<FormFieldState>.new);
    final locationKey = useMemoized(GlobalKey<FormFieldState>.new);

    Future<void> hideAllDropdowns() async {
      if (positionOverlayEntry.value != null) {
        positionOverlayEntry.value!.remove();
        positionOverlayEntry.value = null;
      }
      if (majorOverlayEntry.value != null) {
        majorOverlayEntry.value!.remove();
        majorOverlayEntry.value = null;
      }
      if (jobTypeOverlayEntry.value != null) {
        jobTypeOverlayEntry.value!.remove();
        jobTypeOverlayEntry.value = null;
      }
      if (locationOverlayEntry.value != null) {
        locationOverlayEntry.value!.remove();
        locationOverlayEntry.value = null;
      }
    }

    useEffect(
      () {
        return hideAllDropdowns;
      },
      () {
        return const [];
      }(),
    );

    useEffect(
      () {
        Future.microtask(() async {
          await ref.read(positionControllerProvider.notifier).getPositions();
          await ref.read(majorControllerProvider.notifier).getMajors();
          await ref.read(scheduleControllerProvider.notifier).getSchedules();
          await ref.read(citiesControllerProvider.notifier).fetchCities();
        });
        return null;
      },
      () {
        return const [];
      }(),
    );

    final positionState = ref.watch(positionControllerProvider);
    final positions = switch (positionState) {
      PositionLoaded(positions: final positions) => positions,
      _ => <Position>[],
    };

    final majorState = ref.watch(majorControllerProvider);
    final majors = switch (majorState) {
      MajorLoaded(majors: final majors) => majors,
      _ => <Major>[],
    };

    final jobTypeState = ref.watch(scheduleControllerProvider);
    final jobTypes = switch (jobTypeState) {
      ScheduleLoaded(schedules: final schedules) => schedules,
      _ => <Schedule>[],
    };

    final citiesState = ref.watch(citiesControllerProvider);
    final cities = switch (citiesState) {
      CitiesLoaded(cities: final citiesList) => citiesList,
      _ => <City>[],
    };

    useEffect(
      () {
        if (citiesState is CitiesLoaded && jobInfo.desiredWorkingProvince != null && selectedCity.value?.code == -1) {
          try {
            final city = cities.firstWhere((c) => c.name == jobInfo.desiredWorkingProvince);
            selectedCity.value = city;
          } catch (e) {
            debugPrint('City not found in initial load: $e');
            selectedCity.value = null;
          }
        }
        return null;
      },
      () {
        return [citiesState, jobInfo.desiredWorkingProvince];
      }(),
    );

    if (positionState is! PositionLoaded ||
        majorState is! MajorLoaded ||
        jobTypeState is! ScheduleLoaded ||
        citiesState is! CitiesLoaded) {
      return Scaffold(
        appBar: AppBar(
          surfaceTintColor: const Color(0xFff5fafd),
          title: Text(context.t.job.information, style: const TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: const Color(0xFff5fafd),
        title: Text(context.t.job.information, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20.0),
                  Text(
                    context.t.job.wanted,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  FormBuilderTextField(
                    name: 'job_wanted',
                    controller: jobWantedController,
                    focusNode: jobWantedFocusNode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    ),
                    onSubmitted: (_) async {
                      jobWantedFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(positionFocusNode);
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    context.t.job.position,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  FormBuilderField(
                    key: positionKey,
                    name: 'position',
                    focusNode: positionFocusNode,
                    validator: (value) => null,
                    builder: (FormFieldState<dynamic> field) {
                      return InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (positionOverlayEntry.value != null) {
                                  await hideAllDropdowns();
                                  return;
                                }
                                await hideAllDropdowns();
                                final RenderBox renderBox = positionKey.currentContext!.findRenderObject() as RenderBox;
                                final Size size = renderBox.size;
                                final Offset position = renderBox.localToGlobal(Offset.zero);
                                positionOverlayEntry.value = OverlayEntry(
                                  builder:
                                      (context) => Positioned(
                                        top: position.dy + size.height,
                                        left: position.dx,
                                        width: size.width,
                                        child: Card(
                                          elevation: 8,
                                          margin: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          child: Container(
                                            constraints: const BoxConstraints(maxHeight: 300),
                                            child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true,
                                              itemCount: positions.length,
                                              itemBuilder: (context, index) {
                                                final position = positions[index];
                                                return ListTile(
                                                  title: Text(position.name),
                                                  onTap: () async {
                                                    final newSelection = Set<Position>.from(selectedPositions.value);
                                                    newSelection.add(position);
                                                    selectedPositions.value = newSelection;
                                                    await hideAllDropdowns();
                                                  },
                                                  dense: true,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                );
                                if (context.mounted) {
                                  Overlay.of(context).insert(positionOverlayEntry.value!);
                                }
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [Icon(IconlyLight.arrowDown2, size: 16)],
                              ),
                            ),
                            if (selectedPositions.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      ...selectedPositions.value.map(
                                        (item) => Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Chip(
                                            label: Text(item.name, style: const TextStyle(fontSize: 12)),
                                            deleteIcon: const Icon(Icons.close_outlined, size: 14),
                                            color: WidgetStateProperty.all(
                                              Theme.of(context).colorScheme.primaryContainer.withAlpha(160),
                                            ),
                                            onDeleted: () {
                                              final newItems = Set<Position>.from(selectedPositions.value)
                                                ..remove(item);
                                              selectedPositions.value = newItems;
                                            },
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    context.t.job.major,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  FormBuilderField(
                    key: majorKey,
                    name: 'major',
                    focusNode: majorFocusNode,
                    validator: (value) => null,
                    builder: (FormFieldState<dynamic> field) {
                      return InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (majorOverlayEntry.value != null) {
                                  await hideAllDropdowns();
                                  return;
                                }
                                await hideAllDropdowns();
                                final RenderBox renderBox = majorKey.currentContext!.findRenderObject() as RenderBox;
                                final Size size = renderBox.size;
                                final Offset position = renderBox.localToGlobal(Offset.zero);
                                majorOverlayEntry.value = OverlayEntry(
                                  builder:
                                      (context) => Positioned(
                                        top: position.dy + size.height,
                                        left: position.dx,
                                        width: size.width,
                                        child: Card(
                                          elevation: 8,
                                          margin: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          child: Container(
                                            constraints: const BoxConstraints(maxHeight: 300),
                                            child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true,
                                              itemCount: majors.length,
                                              itemBuilder: (context, index) {
                                                final major = majors[index];
                                                return ListTile(
                                                  title: Text(major.name),
                                                  onTap: () async {
                                                    final newSelection = Set<Major>.from(selectedMajors.value);
                                                    newSelection.add(major);
                                                    selectedMajors.value = newSelection;
                                                    await hideAllDropdowns();
                                                  },
                                                  dense: true,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                );
                                if (context.mounted) {
                                  Overlay.of(context).insert(majorOverlayEntry.value!);
                                }
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [Icon(IconlyLight.arrowDown2, size: 16)],
                              ),
                            ),
                            if (selectedMajors.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      ...selectedMajors.value.map(
                                        (item) => Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Chip(
                                            label: Text(item.name, style: const TextStyle(fontSize: 12)),
                                            deleteIcon: const Icon(Icons.close_outlined, size: 14),
                                            color: WidgetStateProperty.all(
                                              Theme.of(context).colorScheme.primaryContainer.withAlpha(160),
                                            ),
                                            onDeleted: () {
                                              final newItems = Set<Major>.from(selectedMajors.value)..remove(item);
                                              selectedMajors.value = newItems;
                                            },
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    context.t.job.type,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  FormBuilderField(
                    key: jobTypeKey,
                    name: 'job_type',
                    focusNode: jobTypeFocusNode,
                    validator: (value) => null,
                    builder: (FormFieldState<dynamic> field) {
                      return InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (jobTypeOverlayEntry.value != null) {
                                  await hideAllDropdowns();
                                  return;
                                }
                                await hideAllDropdowns();
                                final RenderBox renderBox = jobTypeKey.currentContext!.findRenderObject() as RenderBox;
                                final Size size = renderBox.size;
                                final Offset position = renderBox.localToGlobal(Offset.zero);
                                jobTypeOverlayEntry.value = OverlayEntry(
                                  builder:
                                      (context) => Positioned(
                                        top: position.dy + size.height,
                                        left: position.dx,
                                        width: size.width,
                                        child: Card(
                                          elevation: 8,
                                          margin: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          child: Container(
                                            constraints: const BoxConstraints(maxHeight: 300),
                                            child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true,
                                              itemCount: jobTypes.length,
                                              itemBuilder: (context, index) {
                                                final jobType = jobTypes[index];
                                                return ListTile(
                                                  title: Text(jobType.name),
                                                  onTap: () async {
                                                    final newSelection = Set<Schedule>.from(selectedJobTypes.value);
                                                    newSelection.add(jobType);
                                                    selectedJobTypes.value = newSelection;
                                                    await hideAllDropdowns();
                                                  },
                                                  dense: true,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                );
                                if (context.mounted) {
                                  Overlay.of(context).insert(jobTypeOverlayEntry.value!);
                                }
                              },
                              child: const Row(children: [Icon(IconlyLight.arrowDown2, size: 16)]),
                            ),
                            if (selectedJobTypes.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      ...selectedJobTypes.value.map(
                                        (item) => Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Chip(
                                            label: Text(item.name, style: const TextStyle(fontSize: 12)),
                                            deleteIcon: const Icon(Icons.close_outlined, size: 14),
                                            color: WidgetStateProperty.all(
                                              Theme.of(context).colorScheme.primaryContainer.withAlpha(160),
                                            ),
                                            onDeleted: () async {
                                              final newItems = Set<Schedule>.from(selectedJobTypes.value)..remove(item);
                                              selectedJobTypes.value = newItems;
                                            },
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    context.t.auth.location,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  FormBuilderField(
                    key: locationKey,
                    name: 'location',
                    focusNode: locationFocusNode,
                    validator: (value) => null,
                    builder: (FormFieldState<dynamic> field) {
                      return InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            if (locationOverlayEntry.value != null) {
                              await hideAllDropdowns();
                              return;
                            }
                            await hideAllDropdowns();
                            final RenderBox renderBox = locationKey.currentContext!.findRenderObject() as RenderBox;
                            final Size size = renderBox.size;
                            final Offset position = renderBox.localToGlobal(Offset.zero);
                            locationOverlayEntry.value = OverlayEntry(
                              builder:
                                  (context) => Positioned(
                                    top: position.dy + size.height,
                                    left: position.dx,
                                    width: size.width,
                                    child: Card(
                                      elevation: 8,
                                      margin: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      child: Container(
                                        constraints: const BoxConstraints(maxHeight: 300),
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: cities.length,
                                          itemBuilder: (context, index) {
                                            final city = cities[index];
                                            return ListTile(
                                              title: Text(city.name),
                                              onTap: () async {
                                                selectedCity.value = city;
                                                await hideAllDropdowns();
                                                locationFocusNode.unfocus();
                                                if (context.mounted) {
                                                  FocusScope.of(context).requestFocus(cvFocusNode);
                                                }
                                              },
                                              dense: true,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                            );
                            if (context.mounted) {
                              Overlay.of(context).insert(locationOverlayEntry.value!);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(selectedCity.value != null ? selectedCity.value!.name : context.t.auth.location),
                              const Icon(IconlyLight.arrowDown2, size: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    context.t.job.cv,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  FormBuilderTextField(
                    textAlign: TextAlign.center,
                    name: 'cv',
                    controller: cvPlaceholderController,
                    focusNode: cvFocusNode,
                    readOnly: true,
                    onTap: () async {
                      final result = await ref.read(fileServiceProvider).uploadFile([
                        FileSelector(label: context.t.job.cv, extensions: ['pdf', 'docx']),
                      ]);
                      result.fold(
                        ifLeft: (value) => null,
                        ifRight: (value) {
                          cv.value = value;
                          cvPlaceholderController.text = value.name;
                          cvFocusNode.unfocus();
                          FocusScope.of(context).requestFocus(coverLetterFocusNode);
                        },
                      );
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (cv.value != null)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: 0.84,
                      child: CustomButton(
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text(cv.value!.name),
                                  content: SizedBox(
                                    height: 600.0,
                                    width: 400.0,
                                    child: PdfViewerPage(data: cv.value!.data),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(context.t.common.close),
                                    ),
                                  ],
                                ),
                          );
                        },
                        child: Text(
                          context.t.common.preview,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16.0),
                  Text(
                    context.t.job.coverLetter.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  FormBuilderTextField(
                    name: 'cover_letter',
                    controller: coverLetterController,
                    focusNode: coverLetterFocusNode,
                    minLines: 5,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: context.t.job.coverLetter.description,
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    ),
                    onSubmitted: (_) async {
                      coverLetterFocusNode.unfocus();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            return _CustomNavbar(
              onPressed: () async {
                await hideAllDropdowns();

                if (context.mounted) {
                  FocusScope.of(context).unfocus();
                }
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final currentState = ref.read(authControllerProvider) as AuthAuthorized;
                  if (cv.value == null && currentState.user.jobInfo.cv == null && context.mounted) {
                    NotificationService.error(context: context, message: context.t.job.uploadCV);
                    return;
                  }
                  await ref
                      .read(authControllerProvider.notifier)
                      .updateJobInfo(
                        desiredJob: jobWantedController.text,
                        cv: cv.value,
                        referenceLetter: coverLetterController.text,
                        positions: selectedPositions.value.map((e) => e.toAuth()).toList(),
                        majors: selectedMajors.value.map((e) => e.toAuth()).toList(),
                        desiredWorkingProvince: selectedCity.value!.name,
                        schedules: selectedJobTypes.value.map((e) => e.toAuth()).toList(),
                      );
                  if (context.mounted) {
                    NotificationService.success(context: context, message: context.t.profile.updateSuccess);
                    context.pop();
                  }
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class _CustomNavbar extends StatelessWidget {
  const _CustomNavbar({required this.onPressed});

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest),
      child: CustomButton(
        onPressed: onPressed,
        child: Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Text(context.t.auth.save)),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<void Function()>.has('onPressed', onPressed));
  }
}
