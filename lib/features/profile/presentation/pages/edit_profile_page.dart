import 'package:cached_network_image/cached_network_image.dart';
import 'package:elegant_notification/elegant_notification.dart';
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
import '../../../../core/utils/input_converter.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/domain/entities/user.dart' show University;
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../jobs/domain/entities/job.dart';
import '../../../jobs/presentation/providers/job_provider.dart';

class PersonalInfoEditPage extends HookConsumerWidget {
  const PersonalInfoEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.read(authControllerProvider) is! AuthAuthorized) {
      return const Center(child: Text('You are not authorized to view this page.'));
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
    final genderOptions = ['Male', 'Female'];
    final cityOptions = (ref.read(citiesControllerProvider) as CitiesLoaded).cities;
    final selectedGender = useState(currentState.user.userInfo.gender ? 'Male' : 'Female');
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
        title: const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold)),
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
                              result.fold(ifLeft: (_) => null, ifRight: (value) => image.value = value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                FormBuilderTextField(
                  name: 'first_name',
                  controller: firstNameController,
                  focusNode: firstNameFocusNode,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: InputConverter.validateName,
                  onSubmitted: (_) async {
                    firstNameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(lastNameFocusNode);
                  },
                ),
                const SizedBox(height: 16.0),
                FormBuilderTextField(
                  name: 'last_name',
                  controller: lastNameController,
                  focusNode: lastNameFocusNode,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: InputConverter.validateName,
                  onSubmitted: (_) async {
                    lastNameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(emailFocusNode);
                  },
                ),
                const SizedBox(height: 16.0),
                FormBuilderTextField(
                  name: 'email',
                  controller: emailController,
                  focusNode: emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: InputConverter.validateEmail,
                  onSubmitted: (_) async {
                    emailFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(dateFocusNode);
                  },
                ),
                const SizedBox(height: 16.0),
                FormBuilderDateTimePicker(
                  name: 'date_of_birth',
                  focusNode: dateFocusNode,
                  initialValue: selectedDate.value,
                  inputType: InputType.date,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
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
                FormBuilderTextField(
                  name: 'phone',
                  controller: phoneController,
                  focusNode: phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: InputConverter.validatePhone,
                  onSubmitted: (_) async {
                    phoneFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(genderFocusNode);
                  },
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
                                labelText: 'Gender',
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
                                labelText: 'City',
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  controller.open();
                                },
                                child: Text(selectedCity.value != null ? selectedCity.value!.name : 'Select City'),
                              ),
                            );
                          },
                        );
                      },
                      menuChildren: [
                        ...cityOptions.map((city) {
                          return MenuItemButton(
                            onPressed: () async {
                              // Reset district selection when city changes
                              selectedDistrict.value = null;

                              // Reset districts controller and set new city
                              await ref.read(districtsControllerProvider.notifier).reset();
                              selectedCity.value = city;

                              // Get districts for the selected city
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
                              displayText = 'Select a city first';
                              isEnabled = false;
                            } else if (state is! DistrictsLoaded) {
                              displayText = 'Loading districts...';
                              isEnabled = false;
                            } else if (selectedDistrict.value != null) {
                              displayText = selectedDistrict.value!.name;
                            } else {
                              displayText = 'Select District';
                            }
                            return InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'District',
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
                FormBuilderTextField(
                  name: 'address',
                  controller: addressController,
                  focusNode: addressFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  validator: InputConverter.validateAddress,
                  onSubmitted: (_) async {
                    addressFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(universityFocusNode);
                  },
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
                                labelText: 'University',
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
                                      : 'Select University',
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
                    ElegantNotification.success(
                      background: const Color(0xFFDEF2ED),
                      description: const Text('Personal information updated successfully!'),
                    ).show(context);
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

class JobInfoEditPage extends HookWidget {
  const JobInfoEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final jobWantedController = useTextEditingController();
    final cvPlaceholderController = useTextEditingController(text: 'CV Placeholder');
    final coverLetterController = useTextEditingController();
    final jobWantedFocusNode = useFocusNode();
    final positionFocusNode = useFocusNode();
    final majorFocusNode = useFocusNode();
    final jobTypeFocusNode = useFocusNode();
    final cvFocusNode = useFocusNode();
    final coverLetterFocusNode = useFocusNode();
    final selectedMajor = useState<Major?>(null);
    final cv = useState<FileSelectorResult?>(null);
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: const Color(0xFff5fafd),
        title: const Text('Job Information', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  FormBuilderTextField(
                    name: 'job_wanted',
                    controller: jobWantedController,
                    focusNode: jobWantedFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Job Wanted',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    ),
                    onSubmitted: (_) async {
                      jobWantedFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(positionFocusNode);
                    },
                  ),
                  const SizedBox(height: 16.0),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Consumer(
                        builder: (context, ref, child) {
                          final state = ref.watch(majorControllerProvider);
                          return switch (state) {
                            MajorInitial() => const SizedBox.shrink(),
                            MajorLoading() => const SizedBox.shrink(),
                            MajorError() => const SizedBox.shrink(),
                            MajorLoaded(majors: final majors) => MenuAnchor(
                              style: MenuStyle(
                                minimumSize: WidgetStatePropertyAll(Size(constraints.maxWidth + 8.0, 0.0)),
                                maximumSize: WidgetStatePropertyAll(Size(constraints.maxWidth + 8.0, double.infinity)),
                                elevation: WidgetStateProperty.all(4.0),
                              ),
                              crossAxisUnconstrained: false,
                              alignmentOffset: const Offset(0, 8),
                              builder: (context, controller, child) {
                                return FormBuilderField(
                                  name: 'major',
                                  focusNode: majorFocusNode,
                                  validator: (value) => null,
                                  builder: (FormFieldState<dynamic> field) {
                                    return InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Major',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                                      ),
                                      child: GestureDetector(
                                        onTap: () async {
                                          controller.open();
                                        },
                                        child: Text(
                                          selectedMajor.value != null ? selectedMajor.value!.name : 'Select Major',
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              menuChildren: [
                                ...majors.map((major) {
                                  return MenuItemButton(
                                    onPressed: () async {
                                      selectedMajor.value = major;
                                      majorFocusNode.unfocus();
                                      FocusScope.of(context).requestFocus(jobTypeFocusNode);
                                    },
                                    child: Text(major.name),
                                  );
                                }),
                              ],
                            ),
                          };
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // LayoutBuilder(
                  //   builder: (context, constraints) {
                  //     return MenuAnchor(
                  //       style: MenuStyle(
                  //         minimumSize: WidgetStatePropertyAll(Size(constraints.maxWidth + 8, 0)),
                  //         maximumSize: WidgetStatePropertyAll(Size(constraints.maxWidth + 8, double.infinity)),
                  //         elevation: WidgetStateProperty.all(4.0),
                  //       ),
                  //       crossAxisUnconstrained: false,
                  //       alignmentOffset: const Offset(0, 8),
                  //       builder: (context, controller, child) {
                  //         return FormBuilderField(
                  //           name: 'job_type',
                  //           focusNode: jobTypeFocusNode,
                  //           validator: (value) => null,
                  //           builder: (FormFieldState<dynamic> field) {
                  //             return InputDecorator(
                  //               decoration: const InputDecoration(
                  //                 labelText: 'Job Type',
                  //                 border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  //                 contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  //               ),
                  //               child: GestureDetector(
                  //                 onTap: () async {
                  //                   controller.open();
                  //                 },
                  //                 child: Text(selectedJobType.value),
                  //               ),
                  //             );
                  //           },
                  //         );
                  //       },
                  //       menuChildren: [
                  //         ...jobTypeOptions.map((jobType) {
                  //           return MenuItemButton(
                  //             onPressed: () async {
                  //               selectedJobType.value = jobType;
                  //               jobTypeFocusNode.unfocus();
                  //               FocusScope.of(context).requestFocus(locationFocusNode);
                  //             },
                  //             child: Text(jobType),
                  //           );
                  //         }),
                  //       ],
                  //     );
                  //   },
                  // ),
                  const SizedBox(height: 16.0),
                  // LayoutBuilder(
                  //   builder: (context, constraints) {
                  //     return MenuAnchor(
                  //       style: MenuStyle(
                  //         minimumSize: WidgetStatePropertyAll(Size(constraints.maxWidth + 8, 0)),
                  //         maximumSize: WidgetStatePropertyAll(Size(constraints.maxWidth + 8, double.infinity)),
                  //         elevation: WidgetStateProperty.all(4.0),
                  //       ),
                  //       crossAxisUnconstrained: false,
                  //       alignmentOffset: const Offset(0, 8),
                  //       builder: (context, controller, child) {
                  //         return FormBuilderField(
                  //           name: 'location',
                  //           focusNode: locationFocusNode,
                  //           validator: (value) => null,
                  //           builder: (FormFieldState<dynamic> field) {
                  //             return InputDecorator(
                  //               decoration: const InputDecoration(
                  //                 labelText: 'Location',
                  //                 border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  //                 contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  //               ),
                  //               child: GestureDetector(
                  //                 onTap: () async {
                  //                   controller.open();
                  //                 },
                  //                 child: Text(selectedLocation.value),
                  //               ),
                  //             );
                  //           },
                  //         );
                  //       },
                  //       menuChildren: [
                  //         ...locationOptions.map((location) {
                  //           return MenuItemButton(
                  //             onPressed: () async {
                  //               selectedLocation.value = location;
                  //               locationFocusNode.unfocus();
                  //               FocusScope.of(context).requestFocus(cvFocusNode);
                  //             },
                  //             child: Text(location),
                  //           );
                  //         }),
                  //       ],
                  //     );
                  //   },
                  // ),
                  const SizedBox(height: 16.0),
                  FormBuilderTextField(
                    name: 'cv',
                    controller: cvPlaceholderController,
                    focusNode: cvFocusNode,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'CV',
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                      suffixIcon: Consumer(
                        builder: (context, ref, child) {
                          return IconButton(
                            icon: const Icon(IconlyLight.upload),
                            onPressed: () async {
                              final result = await ref.read(fileServiceProvider).uploadFile([
                                const FileSelector(label: 'CV', extensions: ['pdf', 'docx']),
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
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  FormBuilderTextField(
                    name: 'cover_letter',
                    controller: coverLetterController,
                    focusNode: coverLetterFocusNode,
                    minLines: 5,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Cover Letter',
                      hintText: 'Write a brief introduction about yourself',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
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
                FocusScope.of(context).unfocus();
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  // ref
                  //     .read(authControllerProvider.notifier)
                  //     .updateJobInfo(

                  //     );
                  ElegantNotification.success(
                    background: const Color(0xFFDEF2ED),
                    description: const Text('Job information updated successfully!'),
                  ).show(context);
                  context.pop();
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
        child: const Padding(padding: EdgeInsets.symmetric(vertical: 4.0), child: Text('Save')),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<void Function()>.has('onPressed', onPressed));
  }
}
