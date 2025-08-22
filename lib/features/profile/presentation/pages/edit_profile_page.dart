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
import '../../../jobs/presentation/providers/job_provider.dart';

/// A page for editing personal information of the user.
///
/// This page allows users to update their first name, last name, email,
/// phone number, address, university, gender, city, district, and profile image
class PersonalInfoEditPage extends HookConsumerWidget {
  /// Creates a [PersonalInfoEditPage].
  const PersonalInfoEditPage({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    if (ref.read(authControllerProvider) is! AuthAuthorized) {
      return Center(child: Text(context.t.auth.notAllowedToView));
    }
    final currentState = ref.read(authControllerProvider) as AuthAuthorized;
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final image = useState<FileSelectorResult?>(null);
    final firstNameController = useTextEditingController(
      text: currentState.user.userInfo.firstName,
    );
    final lastNameController = useTextEditingController(
      text: currentState.user.userInfo.lastName,
    );
    final emailController = useTextEditingController(
      text: currentState.user.userInfo.email,
    );
    final phoneController = useTextEditingController(
      text: currentState.user.userInfo.phone,
    );
    final addressController = useTextEditingController(
      text: currentState.user.userInfo.address,
    );

    // Safely get selected university with proper error handling
    final universityState = ref.read(universityControllerProvider);
    final selectedUniversity = useState<University?>(
      currentState.user.jobInfo.university != null && universityState is UniversityLoaded
          ? (() {
              try {
                return universityState.universities.firstWhere(
                  // ignore: lines_longer_than_80_chars
                  (final university) => university.id == currentState.user.jobInfo.university!.id,
                );
              } catch (e) {
                debugPrint('University not found: ${currentState.user.jobInfo.university!.id}');
                return null;
              }
            })()
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

    // Safely get city options with proper error handling
    final citiesState = ref.read(citiesControllerProvider);
    final cityOptions = citiesState is CitiesLoaded ? citiesState.cities : <City>[];

    final selectedGender = useState(
      // ignore: lines_longer_than_80_chars
      currentState.user.userInfo.gender ? context.t.profile.male : context.t.profile.female,
    );

    final selectedCity = useState<City?>(
      currentState.user.userInfo.city != null && citiesState is CitiesLoaded
          ? (() {
              try {
                return citiesState.cities.firstWhere(
                  (final city) => city.name.contains(
                    currentState.user.userInfo.city!,
                  ),
                );
              } catch (e) {
                debugPrint('City not found: ${currentState.user.userInfo.city}');
                return null;
              }
            })()
          : null,
    );
    final selectedDistrict = useState<District?>(null);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = ref.read(districtsControllerProvider);
      if (state is DistrictsInitial && selectedCity.value != null) {
        await ref
            .read(districtsControllerProvider.notifier)
            .getDistricts(
              code: selectedCity.value!.code,
            );
        if (currentState.user.userInfo.district != null) {
          final districtsState = ref.read(districtsControllerProvider);
          if (districtsState is DistrictsLoaded) {
            try {
              final district = districtsState.districts.firstWhere(
                (final district) => district.name.contains(
                  currentState.user.userInfo.district!,
                ),
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
              (final district) => district.name.contains(
                currentState.user.userInfo.district!,
              ),
            );
            selectedDistrict.value = district;
          } catch (e) {
            debugPrint('District not found: $e');
          }
        }
      }
    });
    final selectedDate = useState<DateTime?>(
      currentState.user.userInfo.birthDate != null
          ? DateFormat('dd-MM-yyyy').parse(
              currentState.user.userInfo.birthDate!,
            )
          : DateTime.now(),
    );
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: const Color(0xFff5fafd),
        title: Text(
          context.t.profile.personalInformation,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                        child: _ProfileImage(
                          image: image,
                          currentState: currentState,
                        ),
                      ),
                      _CustomUploadImage(image: image, ref: ref),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.t.auth.firstName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  key: const Key('first_name_field'),
                  name: 'first_name',
                  controller: firstNameController,
                  focusNode: firstNameFocusNode,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  validator: (final value) => InputConverter.validateFirstName(
                    value,
                    context,
                  ),
                  onSubmitted: (_) async {
                    firstNameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(lastNameFocusNode);
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  context.t.auth.lastName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  key: const Key('last_name_field'),
                  name: 'last_name',
                  controller: lastNameController,
                  focusNode: lastNameFocusNode,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  validator: (final value) => InputConverter.validateLastName(
                    value,
                    context,
                  ),
                  onSubmitted: (_) async {
                    lastNameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(emailFocusNode);
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  context.t.auth.email,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  key: const Key('email_field'),
                  name: 'email',
                  controller: emailController,
                  focusNode: emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  validator: (final value) => InputConverter.validateEmail(
                    value,
                    context,
                  ),
                  onSubmitted: (_) async {
                    emailFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(dateFocusNode);
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  context.t.auth.dateOfBirth,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                FormBuilderDateTimePicker(
                  key: const Key('date_of_birth_field'),
                  name: 'date_of_birth',
                  focusNode: dateFocusNode,
                  initialValue: selectedDate.value,
                  inputType: InputType.date,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    suffixIcon: Tooltip(
                      message: context.t.profile.selectDateOfBirth,
                      child: const Icon(IconlyLight.calendar),
                    ),
                  ),
                  format: DateFormat('dd/MM/yyyy'),
                  validator: (final value) {
                    if (value == null) {
                      return context.t.validation.required.dateOfBirth;
                    }
                    if (value.isAfter(DateTime.now())) {
                      return context.t.validation.length.dateOfBirth;
                    }
                    return null;
                  },
                  onChanged: (final value) async => selectedDate.value = value,
                  onFieldSubmitted: (_) async {
                    dateFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(phoneFocusNode);
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  context.t.auth.phone,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  key: const Key('phone_field'),
                  name: 'phone',
                  controller: phoneController,
                  focusNode: phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  validator: (final value) => InputConverter.validatePhone(
                    value,
                    context,
                  ),
                  onSubmitted: (_) async {
                    phoneFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(genderFocusNode);
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  context.t.auth.gender,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _GenderDropdown(
                  selectedGender: selectedGender,
                  genderFocusNode: genderFocusNode,
                  cityFocusNode: cityFocusNode,
                  genderOptions: genderOptions,
                ),
                const SizedBox(height: 16),
                Text(
                  context.t.auth.city,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _CitiesDropdown(
                  selectedCity: selectedCity,
                  cityFocusNode: cityFocusNode,
                  districtFocusNode: districtFocusNode,
                  cityOptions: cityOptions,
                  ref: ref,
                  selectedDistrict: selectedDistrict,
                ),
                const SizedBox(height: 16),
                Text(
                  context.t.auth.district,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _DistrictsDropdown(
                  selectedCity: selectedCity,
                  districtFocusNode: districtFocusNode,
                  addressFocusNode: addressFocusNode,
                  ref: ref,
                  selectedDistrict: selectedDistrict,
                ),
                const SizedBox(height: 16),
                Text(
                  context.t.auth.address,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'address',
                  controller: addressController,
                  focusNode: addressFocusNode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  validator: (final value) => InputConverter.validateAddress(
                    value,
                    context,
                  ),
                  onSubmitted: (_) async {
                    addressFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(universityFocusNode);
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  context.t.auth.university,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _UniversitiesDropdown(
                  selectedUniversity: selectedUniversity,
                  universityFocusNode: universityFocusNode,
                  ref: ref,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: _CustomNavbar(
          onPressed: () async {
            FocusScope.of(context).unfocus();
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              // ignore: lines_longer_than_80_chars
              final userId = (ref.read(authControllerProvider) as AuthAuthorized).user.userId;
              await ref
                  .read(authControllerProvider.notifier)
                  .updateUserInfo(
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    phone: phoneController.text,
                    birthDay: DateFormat('dd-MM-yyyy').format(
                      selectedDate.value!,
                    ),
                    gender: genderOptions.indexOf(selectedGender.value),
                    location: addressController.text,
                    avatar: image.value,
                    city: selectedCity.value!.name,
                    district: selectedDistrict.value!.name,
                    university: selectedUniversity.value!,
                  );
              ref.read(authControllerProvider.notifier).reset();
              await ref
                  .read(authControllerProvider.notifier)
                  .getCandidateData(
                    userId!,
                  );
              if (context.mounted) {
                NotificationService.success(
                  context: context,
                  message: context.t.profile.updateSuccess,
                );
                context.pop();
              }
            }
          },
        ),
      ),
    );
  }
}

/// A dropdown widget for selecting a university.
class _UniversitiesDropdown extends StatelessWidget {
  /// Creates a [_UniversitiesDropdown].
  const _UniversitiesDropdown({
    required this.selectedUniversity,
    required this.universityFocusNode,
    required this.ref,
  });

  /// The currently selected university.
  final ValueNotifier<University?> selectedUniversity;

  /// The focus node for the university dropdown.
  final FocusNode universityFocusNode;

  /// A reference to the widget tree.
  final WidgetRef ref;

  @override
  Widget build(final BuildContext context) => LayoutBuilder(
    builder: (final context, final constraints) {
      final state = ref.watch(universityControllerProvider);
      return MenuAnchor(
        style: MenuStyle(
          minimumSize: WidgetStatePropertyAll(
            Size(constraints.maxWidth + 8, 0),
          ),
          maximumSize: WidgetStatePropertyAll(
            Size(
              constraints.maxWidth + 8,
              double.infinity,
            ),
          ),
          elevation: WidgetStateProperty.all(4),
        ),
        crossAxisUnconstrained: false,
        alignmentOffset: const Offset(0, 8),
        menuChildren: [
          // ignore: lines_longer_than_80_chars
          ...(state is UniversityLoaded ? state.universities : <University>[]).map(
            (final University university) => MenuItemButton(
              onPressed: () async {
                selectedUniversity.value = university;
                universityFocusNode.unfocus();
              },
              child: Text(university.name),
            ),
          ),
        ],
        builder: (final context, final controller, final child) => FormBuilderField(
          name: 'university',
          focusNode: universityFocusNode,
          validator: (final value) => null,
          builder: (final FormFieldState<dynamic> field) => InputDecorator(
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
              ),
              suffixIcon: Tooltip(
                message: context.t.profile.selectUniversity,
                child: IconButton(
                  icon: const Icon(IconlyLight.arrowDown2),
                  onPressed: () async {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                ),
              ),
            ),
            child: GestureDetector(
              onTap: () async {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: Text(
                selectedUniversity.value != null ? selectedUniversity.value!.name : context.t.auth.selectUniversity,
              ),
            ),
          ),
        ),
      );
    },
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<ValueNotifier<University?>>(
          'selectedUniversity',
          selectedUniversity,
        ),
      )
      ..add(
        DiagnosticsProperty<FocusNode>(
          'universityFocusNode',
          universityFocusNode,
        ),
      )
      ..add(DiagnosticsProperty<WidgetRef>('ref', ref));
  }
}

/// A dropdown widget for selecting a district.
class _DistrictsDropdown extends StatelessWidget {
  /// Creates a [_DistrictsDropdown].
  const _DistrictsDropdown({
    required this.selectedCity,
    required this.districtFocusNode,
    required this.addressFocusNode,
    required this.ref,
    required this.selectedDistrict,
  });

  /// The currently selected city.
  final ValueNotifier<City?> selectedCity;

  /// The focus node for the district dropdown.
  final FocusNode districtFocusNode;

  /// The focus node for the address field.
  final FocusNode addressFocusNode;

  /// A reference to the widget tree.
  final WidgetRef ref;

  /// The currently selected district.
  final ValueNotifier<District?> selectedDistrict;

  @override
  Widget build(final BuildContext context) => LayoutBuilder(
    builder: (final context, final constraints) {
      final state = ref.watch(districtsControllerProvider);
      return MenuAnchor(
        style: MenuStyle(
          minimumSize: WidgetStatePropertyAll(
            Size(constraints.maxWidth + 8, 0),
          ),
          maximumSize: WidgetStatePropertyAll(
            Size(constraints.maxWidth + 8, double.infinity),
          ),
          elevation: WidgetStateProperty.all(4),
        ),
        crossAxisUnconstrained: false,
        alignmentOffset: const Offset(0, 8),
        builder: (final context, final controller, final child) => FormBuilderField(
          name: 'district',
          focusNode: districtFocusNode,
          validator: (final value) => null,
          builder: (final FormFieldState<dynamic> field) {
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
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
                enabled: isEnabled,
                suffixIcon: Tooltip(
                  message: context.t.profile.selectDistrict,
                  child: IconButton(
                    icon: const Icon(IconlyLight.arrowDown2),
                    onPressed: () async {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () async {
                  if (isEnabled) {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  }
                },
                child: Text(
                  displayText,
                  style: isEnabled
                      ? null
                      : const TextStyle(
                          color: Colors.grey,
                        ),
                ),
              ),
            );
          },
        ),
        menuChildren: [
          ...(state is DistrictsLoaded ? state.districts : <District>[]).map(
            (final District district) => MenuItemButton(
              onPressed: () async {
                selectedDistrict.value = district;
                districtFocusNode.unfocus();
                FocusScope.of(context).requestFocus(addressFocusNode);
              },
              child: Text(district.name),
            ),
          ),
        ],
      );
    },
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<ValueNotifier<City?>>('selectedCity', selectedCity),
      )
      ..add(
        DiagnosticsProperty<FocusNode>('districtFocusNode', districtFocusNode),
      )
      ..add(
        DiagnosticsProperty<FocusNode>('addressFocusNode', addressFocusNode),
      )
      ..add(DiagnosticsProperty<WidgetRef>('ref', ref))
      ..add(
        DiagnosticsProperty<ValueNotifier<District?>>(
          'selectedDistrict',
          selectedDistrict,
        ),
      );
  }
}

/// A dropdown widget for selecting a city.
class _CitiesDropdown extends StatelessWidget {
  /// Creates a [_CitiesDropdown].
  const _CitiesDropdown({
    required this.selectedCity,
    required this.cityFocusNode,
    required this.districtFocusNode,
    required this.cityOptions,
    required this.ref,
    required this.selectedDistrict,
  });

  /// The currently selected city.
  final ValueNotifier<City?> selectedCity;

  /// The focus node for the city dropdown.
  final FocusNode cityFocusNode;

  /// The focus node for the district dropdown.
  final FocusNode districtFocusNode;

  /// The list of available cities.
  final List<City> cityOptions;

  /// A reference to the widget tree.
  final WidgetRef ref;

  /// The currently selected district.
  final ValueNotifier<District?> selectedDistrict;

  @override
  Widget build(final BuildContext context) => LayoutBuilder(
    builder: (final context, final constraints) => MenuAnchor(
      style: MenuStyle(
        minimumSize: WidgetStatePropertyAll(
          Size(constraints.maxWidth + 8, 0),
        ),
        maximumSize: WidgetStatePropertyAll(
          Size(constraints.maxWidth + 8, double.infinity),
        ),
        elevation: WidgetStateProperty.all(4),
      ),
      crossAxisUnconstrained: false,
      alignmentOffset: const Offset(0, 8),
      builder:
          // ignore: lines_longer_than_80_chars
          (final context, final controller, final child) => FormBuilderField(
            name: 'city',
            focusNode: cityFocusNode,
            validator: (final value) => null,
            builder: (final FormFieldState<dynamic> field) => InputDecorator(
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
                suffixIcon: Tooltip(
                  message: context.t.profile.selectCity,
                  child: IconButton(
                    icon: const Icon(IconlyLight.arrowDown2),
                    onPressed: () async {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () async {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                child: Text(
                  // ignore: lines_longer_than_80_chars
                  selectedCity.value != null ? selectedCity.value!.name : context.t.auth.selectCity,
                ),
              ),
            ),
          ),
      menuChildren: [
        ...cityOptions.map(
          (final city) => MenuItemButton(
            onPressed: () async {
              selectedDistrict.value = null;
              await ref.read(districtsControllerProvider.notifier).reset();
              selectedCity.value = city;
              await ref
                  .read(districtsControllerProvider.notifier)
                  .getDistricts(
                    code: selectedCity.value!.code,
                  );

              cityFocusNode.unfocus();
              if (context.mounted) {
                FocusScope.of(context).requestFocus(districtFocusNode);
              }
            },
            child: Text(city.name),
          ),
        ),
      ],
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<ValueNotifier<City?>>(
          'selectedCity',
          selectedCity,
        ),
      )
      ..add(DiagnosticsProperty<FocusNode>('cityFocusNode', cityFocusNode))
      ..add(
        DiagnosticsProperty<FocusNode>(
          'districtFocusNode',
          districtFocusNode,
        ),
      )
      ..add(IterableProperty<City>('cityOptions', cityOptions))
      ..add(DiagnosticsProperty<WidgetRef>('ref', ref))
      ..add(
        DiagnosticsProperty<ValueNotifier<District?>>(
          'selectedDistrict',
          selectedDistrict,
        ),
      );
  }
}

/// A dropdown widget for selecting gender.
class _GenderDropdown extends StatelessWidget {
  /// Creates a [_GenderDropdown].
  const _GenderDropdown({
    required this.selectedGender,
    required this.genderFocusNode,
    required this.cityFocusNode,
    required this.genderOptions,
  });

  /// The currently selected gender.
  final ValueNotifier<String> selectedGender;

  /// The focus node for the gender dropdown.
  final FocusNode genderFocusNode;

  /// The focus node for the city dropdown.
  final FocusNode cityFocusNode;

  /// The list of available gender options.
  final List<String> genderOptions;

  @override
  Widget build(final BuildContext context) => LayoutBuilder(
    builder: (final context, final constraints) => MenuAnchor(
      style: MenuStyle(
        minimumSize: WidgetStatePropertyAll(
          Size(constraints.maxWidth + 8, 0),
        ),
        maximumSize: WidgetStatePropertyAll(
          Size(constraints.maxWidth + 8, double.infinity),
        ),
        elevation: WidgetStateProperty.all(4),
      ),
      crossAxisUnconstrained: false,
      alignmentOffset: const Offset(0, 8),
      builder:
          // ignore: lines_longer_than_80_chars
          (final context, final controller, final child) => FormBuilderField(
            name: 'gender',
            focusNode: genderFocusNode,
            validator: (final value) => null,
            builder: (final FormFieldState<dynamic> field) => InputDecorator(
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
                suffixIcon: Tooltip(
                  message: context.t.profile.selectGender,
                  child: IconButton(
                    icon: const Icon(IconlyLight.arrowDown2),
                    onPressed: () async {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () async {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                child: Text(selectedGender.value),
              ),
            ),
          ),
      menuChildren: [
        ...genderOptions.map(
          (final gender) => MenuItemButton(
            onPressed: () async {
              selectedGender.value = gender;
              genderFocusNode.unfocus();
              FocusScope.of(context).requestFocus(cityFocusNode);
            },
            child: Text(gender),
          ),
        ),
      ],
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<ValueNotifier<String>>(
          'selectedGender',
          selectedGender,
        ),
      )
      ..add(DiagnosticsProperty<FocusNode>('genderFocusNode', genderFocusNode))
      ..add(DiagnosticsProperty<FocusNode>('cityFocusNode', cityFocusNode))
      ..add(IterableProperty<String>('genderOptions', genderOptions));
  }
}

/// A widget for uploading a custom profile image.
class _CustomUploadImage extends StatelessWidget {
  /// Creates a [_CustomUploadImage].
  const _CustomUploadImage({required this.image, required this.ref});

  /// The currently selected image file.
  final ValueNotifier<FileSelectorResult?> image;

  /// A reference to the widget tree.
  final WidgetRef ref;

  @override
  Widget build(final BuildContext context) => Positioned(
    bottom: 0,
    right: 0,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        key: const Key('change_avatar_button'),
        icon: Icon(
          IconlyLight.edit,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 16,
        ),
        onPressed: () async {
          final result = await ref.read(fileServiceProvider).uploadImage();
          result.fold(
            ifLeft: (_) => null,
            ifRight: (final value) {
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
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<ValueNotifier<FileSelectorResult?>>(
          'image',
          image,
        ),
      )
      ..add(DiagnosticsProperty<WidgetRef>('ref', ref));
  }
}

/// A widget for displaying the profile image.
class _ProfileImage extends StatelessWidget {
  /// Creates a [_ProfileImage].
  const _ProfileImage({required this.image, required this.currentState});

  /// The currently selected image file.
  final ValueNotifier<FileSelectorResult?> image;

  /// The current authentication state.
  final AuthAuthorized currentState;

  @override
  Widget build(final BuildContext context) => image.value != null
      ? ClipOval(
          child: Image.memory(
            image.value!.data,
            fit: BoxFit.cover,
            width: 86,
            height: 86,
          ),
        )
      : currentState.user.userInfo.avatar != null
      ? ClipOval(
          child: CachedNetworkImage(
            imageUrl: queryImage(currentState.user.userInfo.avatar!),
            fit: BoxFit.cover,
            width: 86,
            height: 86,
          ),
        )
      : const Icon(IconlyLight.profile, size: 48, color: Colors.grey);

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<ValueNotifier<FileSelectorResult?>>(
          'image',
          image,
        ),
      )
      ..add(DiagnosticsProperty<AuthAuthorized>('currentState', currentState));
  }
}

/// A page for editing job-related information of the user.
///
/// This page allows users to update their desired job, positions, majors,
/// job types, desired working location, CV, and cover letter.
class JobInfoEditPage extends HookConsumerWidget {
  /// Creates a [JobInfoEditPage].
  const JobInfoEditPage({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    if (ref.read(authControllerProvider) is! AuthAuthorized) {
      return Center(child: Text(context.t.auth.notAllowedToView));
    }
    final currentState = ref.read(authControllerProvider) as AuthAuthorized;
    final jobInfo = currentState.user.jobInfo;

    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final jobWantedController = useTextEditingController(
      text: jobInfo.desiredJob,
    );
    final coverLetterController = useTextEditingController(
      text: jobInfo.referenceLetter,
    );
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
      // ignore: lines_longer_than_80_chars
      jobInfo.positions.map((final p) => Position(id: p.id, name: p.name)).toSet(),
    );
    // ignore: lines_longer_than_80_chars
    final selectedMajors = useState<Set<Major>>(jobInfo.majors.map((final m) => Major(id: m.id, name: m.name)).toSet());
    final selectedJobTypes = useState<Set<Schedule>>(
      // ignore: lines_longer_than_80_chars
      jobInfo.schedules.map((final s) => Schedule(id: s.id, name: s.name)).toSet(),
    );

    // Safely get selected city with proper error handling
    final jobCitiesState = ref.read(citiesControllerProvider);
    final selectedCity = useState<City?>(
      jobInfo.desiredWorkingProvince != null && jobCitiesState is CitiesLoaded
          ? (() {
              try {
                return jobCitiesState.cities.firstWhere(
                  (final city) => city.name.contains(jobInfo.desiredWorkingProvince!),
                );
              } catch (e) {
                debugPrint('City not found: ${jobInfo.desiredWorkingProvince}');
                return null;
              }
            })()
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

    useEffect(() => hideAllDropdowns, const []);

    useEffect(() {
      Future.microtask(() async {
        await ref.read(positionControllerProvider.notifier).getPositions();
        await ref.read(majorControllerProvider.notifier).getMajors();
        await ref.read(scheduleControllerProvider.notifier).getSchedules();
        await ref.read(citiesControllerProvider.notifier).fetchCities();
      });
      return null;
    }, const []);

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

    useEffect(() {
      // ignore: lines_longer_than_80_chars
      if (citiesState is CitiesLoaded && jobInfo.desiredWorkingProvince != null && selectedCity.value?.code == -1) {
        try {
          // ignore: lines_longer_than_80_chars
          final city = cities.firstWhere((final c) => c.name == jobInfo.desiredWorkingProvince);
          selectedCity.value = city;
        } catch (e) {
          debugPrint('City not found in initial load: $e');
          selectedCity.value = null;
        }
      }
      return null;
    }, [citiesState, jobInfo.desiredWorkingProvince]);

    if (positionState is! PositionLoaded ||
        majorState is! MajorLoaded ||
        jobTypeState is! ScheduleLoaded ||
        citiesState is! CitiesLoaded) {
      return Scaffold(
        appBar: AppBar(
          surfaceTintColor: const Color(0xFff5fafd),
          title: Text(
            context.t.job.information,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: const Color(0xFff5fafd),
        title: Text(
          context.t.job.information,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FormBuilder(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    context.t.job.wanted,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'job_wanted',
                    controller: jobWantedController,
                    focusNode: jobWantedFocusNode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                    ),
                    onSubmitted: (_) async {
                      jobWantedFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(positionFocusNode);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.t.job.position,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderField(
                    key: positionKey,
                    name: 'position',
                    focusNode: positionFocusNode,
                    validator: (final value) => null,
                    builder: (final FormFieldState<dynamic> field) => InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PositionDropdown(
                            selectedPositions: selectedPositions,
                            positionKey: positionKey,
                            positions: positions,
                            onTap: hideAllDropdowns,
                            positionOverlayEntry: positionOverlayEntry,
                          ),
                          if (selectedPositions.value.isNotEmpty)
                            _PositionSelector(
                              selectedPositions: selectedPositions,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.t.job.major,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderField(
                    key: majorKey,
                    name: 'major',
                    focusNode: majorFocusNode,
                    validator: (final value) => null,
                    builder: (final FormFieldState<dynamic> field) => InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MajorSelector(
                            selectedMajors: selectedMajors,
                            majorKey: majorKey,
                            majors: majors,
                            onTap: hideAllDropdowns,
                            majorOverlayEntry: majorOverlayEntry,
                          ),
                          if (selectedMajors.value.isNotEmpty)
                            _MajorList(
                              selectedMajors: selectedMajors,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.t.job.type,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderField(
                    key: jobTypeKey,
                    name: 'job_type',
                    focusNode: jobTypeFocusNode,
                    validator: (final value) => null,
                    builder: (final FormFieldState<dynamic> field) => InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _JobTypeList(
                            selectedJobTypes: selectedJobTypes,
                            jobTypeKey: jobTypeKey,
                            jobTypes: jobTypes,
                            onTap: hideAllDropdowns,
                            jobTypeOverlayEntry: jobTypeOverlayEntry,
                          ),
                          if (selectedJobTypes.value.isNotEmpty)
                            _ScheduleList(
                              selectedJobTypes: selectedJobTypes,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.t.auth.location,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderField(
                    key: locationKey,
                    name: 'location',
                    focusNode: locationFocusNode,
                    validator: (final value) => null,
                    builder: (final FormFieldState<dynamic> field) => InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                      ),
                      child: _CitiesJobDropdown(
                        selectedCity: selectedCity,
                        locationFocusNode: locationFocusNode,
                        cvFocusNode: cvFocusNode,
                        locationOverlayEntry: locationOverlayEntry,
                        cities: cities,
                        locationKey: locationKey,
                        hideAllDropdowns: hideAllDropdowns,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.t.job.cv,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    textAlign: TextAlign.center,
                    name: 'cv',
                    controller: cvPlaceholderController,
                    focusNode: cvFocusNode,
                    readOnly: true,
                    onTap: () async {
                      // ignore: lines_longer_than_80_chars
                      final result = await ref.read(fileServiceProvider).uploadFile([
                        FileSelector(
                          label: context.t.job.cv,
                          extensions: ['pdf'],
                        ),
                      ]);
                      result.fold(
                        ifLeft: (final value) => null,
                        ifRight: (final value) {
                          if (value.data.length > 512 * 1024) {
                            NotificationService.error(
                              context: context,
                              message: context.t.validation.file.cvFormat,
                            );
                            return;
                          }
                          cv.value = value;
                          cvPlaceholderController.text = value.name;
                          cvFocusNode.unfocus();
                          FocusScope.of(context).requestFocus(
                            coverLetterFocusNode,
                          );
                        },
                      );
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (cv.value != null) PreviewButton(file: cv),
                  const SizedBox(height: 16),
                  Text(
                    context.t.job.coverLetter.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'cover_letter',
                    controller: coverLetterController,
                    focusNode: coverLetterFocusNode,
                    minLines: 5,
                    maxLines: 5,
                    validator: (final value) {
                      if (value == null || value.isEmpty) {
                        return context.t.job.noReferenceLetter;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: context.t.job.coverLetter.description,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
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
        child: _CustomNavbar(
          onPressed: () async {
            await hideAllDropdowns();

            if (context.mounted) {
              FocusScope.of(context).unfocus();
            }
            if (selectedPositions.value.isEmpty && context.mounted) {
              NotificationService.error(
                context: context,
                message: context.t.validation.required.jobPosition,
              );
              return;
            }
            if (selectedMajors.value.isEmpty && context.mounted) {
              NotificationService.error(
                context: context,
                message: context.t.validation.required.major,
              );
              return;
            }
            if (selectedJobTypes.value.isEmpty && context.mounted) {
              NotificationService.error(
                context: context,
                message: context.t.validation.required.workType,
              );
              return;
            }
            // ignore: lines_longer_than_80_chars
            if (cv.value == null && currentState.user.jobInfo.cv == null && context.mounted) {
              NotificationService.error(
                context: context,
                message: context.t.job.uploadCV,
              );
              return;
            }
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              // ignore: lines_longer_than_80_chars
              final userId = (ref.read(authControllerProvider) as AuthAuthorized).user.userId;
              await ref
                  .read(authControllerProvider.notifier)
                  .updateJobInfo(
                    desiredJob: jobWantedController.text,
                    cv: cv.value,
                    referenceLetter: coverLetterController.text,
                    // ignore: lines_longer_than_80_chars
                    positions: selectedPositions.value.map((final e) => e.toAuth()).toList(),
                    // ignore: lines_longer_than_80_chars
                    majors: selectedMajors.value.map((final e) => e.toAuth()).toList(),
                    desiredWorkingProvince: selectedCity.value!.name,
                    // ignore: lines_longer_than_80_chars
                    schedules: selectedJobTypes.value.map((final e) => e.toAuth()).toList(),
                  );
              ref.read(authControllerProvider.notifier).reset();
              await ref
                  .read(authControllerProvider.notifier)
                  .getCandidateData(
                    userId,
                  );
              if (context.mounted) {
                NotificationService.success(
                  context: context,
                  message: context.t.profile.updateSuccess,
                );
                context.pop();
              }
            }
          },
        ),
      ),
    );
  }
}

/// A dropdown widget for selecting a city for job location.
class _CitiesJobDropdown extends StatelessWidget {
  /// Creates a [_CitiesJobDropdown].
  const _CitiesJobDropdown({
    required this.selectedCity,
    required this.locationFocusNode,
    required this.cvFocusNode,
    required this.locationOverlayEntry,
    required this.cities,
    required this.locationKey,
    required this.hideAllDropdowns,
  });

  /// The currently selected city.
  final ValueNotifier<City?> selectedCity;

  /// The focus node for the location dropdown.
  final FocusNode locationFocusNode;

  /// The focus node for the CV field.
  final FocusNode cvFocusNode;

  /// The overlay entry for the location dropdown.
  final ValueNotifier<OverlayEntry?> locationOverlayEntry;

  /// The list of available cities.
  final List<City> cities;

  /// The global key for the location field.
  final GlobalKey<FormFieldState> locationKey;

  /// A function to hide all dropdowns.
  final Future<void> Function() hideAllDropdowns;

  @override
  Widget build(final BuildContext context) => GestureDetector(
    onTap: () async {
      if (locationOverlayEntry.value != null) {
        await hideAllDropdowns();
        return;
      }
      await hideAllDropdowns();
      // ignore: lines_longer_than_80_chars
      final RenderBox renderBox = locationKey.currentContext!.findRenderObject()! as RenderBox;
      final Size size = renderBox.size;
      final Offset position = renderBox.localToGlobal(Offset.zero);
      locationOverlayEntry.value = OverlayEntry(
        builder: (final context) => Positioned(
          top: position.dy + size.height,
          left: position.dx,
          width: size.width,
          child: Card(
            elevation: 8,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: cities.length,
                itemBuilder: (final context, final index) {
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
        Text(
          // ignore: lines_longer_than_80_chars
          selectedCity.value != null ? selectedCity.value!.name : context.t.auth.location,
        ),
        const Icon(IconlyLight.arrowDown2, size: 16),
      ],
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<ValueNotifier<City?>>(
          'selectedCity',
          selectedCity,
        ),
      )
      ..add(
        DiagnosticsProperty<FocusNode>(
          'locationFocusNode',
          locationFocusNode,
        ),
      )
      ..add(DiagnosticsProperty<FocusNode>('cvFocusNode', cvFocusNode))
      ..add(
        DiagnosticsProperty<ValueNotifier<OverlayEntry?>>(
          'locationOverlayEntry',
          locationOverlayEntry,
        ),
      )
      ..add(IterableProperty<City>('cities', cities))
      ..add(
        DiagnosticsProperty<GlobalKey<FormFieldState>>(
          'locationKey',
          locationKey,
        ),
      )
      ..add(
        ObjectFlagProperty<Future<void> Function()>.has(
          'hideAllDropdowns',
          hideAllDropdowns,
        ),
      );
  }
}

/// A widget for displaying a list of selected job schedules (types).
class _ScheduleList extends StatelessWidget {
  /// Creates a [_ScheduleList].
  const _ScheduleList({super.key, required this.selectedJobTypes});

  /// The set of selected job schedules.
  final ValueNotifier<Set<Schedule>> selectedJobTypes;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...selectedJobTypes.value.map(
            (final item) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(item.name, style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close_outlined, size: 14),
                color: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.primaryContainer.withAlpha(160),
                ),
                onDeleted: () async {
                  // ignore: lines_longer_than_80_chars
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
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<ValueNotifier<Set<Schedule>>>(
        'selectedJobTypes',
        selectedJobTypes,
      ),
    );
  }
}

/// A widget for selecting job types from a list.
class _JobTypeList extends StatelessWidget {
  /// Creates a [_JobTypeList].
  const _JobTypeList({
    required this.selectedJobTypes,
    required this.jobTypeOverlayEntry,
    required this.onTap,
    required this.jobTypes,
    required this.jobTypeKey,
  });

  /// The set of selected job types.
  final ValueNotifier<Set<Schedule>> selectedJobTypes;

  /// The overlay entry for the job type dropdown.
  final ValueNotifier<OverlayEntry?> jobTypeOverlayEntry;

  /// A function to handle tap events.
  final Future<void> Function() onTap;

  /// The list of available job types.
  final List<Schedule> jobTypes;

  /// The global key for the job type field.
  final GlobalKey<FormFieldState> jobTypeKey;

  @override
  Widget build(final BuildContext context) => GestureDetector(
    onTap: () async {
      if (jobTypeOverlayEntry.value != null) {
        await onTap();
        return;
      }
      await onTap();
      // ignore: lines_longer_than_80_chars
      final RenderBox renderBox = jobTypeKey.currentContext!.findRenderObject()! as RenderBox;
      final Size size = renderBox.size;
      final Offset position = renderBox.localToGlobal(Offset.zero);
      jobTypeOverlayEntry.value = OverlayEntry(
        builder: (final context) => Positioned(
          top: position.dy + size.height,
          left: position.dx,
          width: size.width,
          child: Card(
            elevation: 8,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: jobTypes.length,
                itemBuilder: (final context, final index) {
                  final jobType = jobTypes[index];
                  return ListTile(
                    title: Text(jobType.name),
                    onTap: () async {
                      // ignore: lines_longer_than_80_chars
                      final newSelection = Set<Schedule>.from(selectedJobTypes.value)..add(jobType);
                      selectedJobTypes.value = newSelection;
                      await onTap();
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
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [Icon(IconlyLight.arrowDown2, size: 16)],
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<ValueNotifier<Set<Schedule>>>(
          'selectedJobTypes',
          selectedJobTypes,
        ),
      )
      ..add(
        DiagnosticsProperty<ValueNotifier<OverlayEntry?>>(
          'jobTypeOverlayEntry',
          jobTypeOverlayEntry,
        ),
      )
      ..add(ObjectFlagProperty<Future<void> Function()>.has('onTap', onTap))
      ..add(IterableProperty<Schedule>('jobTypes', jobTypes))
      ..add(
        DiagnosticsProperty<GlobalKey<FormFieldState>>(
          'jobTypeKey',
          jobTypeKey,
        ),
      );
  }
}

/// A widget for displaying a list of selected majors.
class _MajorList extends StatelessWidget {
  /// Creates a [_MajorList].
  const _MajorList({super.key, required this.selectedMajors});

  /// The set of selected majors.
  final ValueNotifier<Set<Major>> selectedMajors;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...selectedMajors.value.map(
            (final item) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(item.name, style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close_outlined, size: 14),
                color: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.primaryContainer.withAlpha(160),
                ),
                onDeleted: () {
                  // ignore: lines_longer_than_80_chars
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
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<ValueNotifier<Set<Major>>>(
        'selectedMajors',
        selectedMajors,
      ),
    );
  }
}

/// A widget for selecting majors from a list.
class _MajorSelector extends StatelessWidget {
  /// Creates a [_MajorSelector].
  const _MajorSelector({
    required this.majorOverlayEntry,
    required this.selectedMajors,
    required this.majors,
    required this.onTap,
    required this.majorKey,
  });

  /// The overlay entry for the major dropdown.
  final ValueNotifier<OverlayEntry?> majorOverlayEntry;

  /// The set of selected majors.
  final ValueNotifier<Set<Major>> selectedMajors;

  /// The list of available majors.
  final List<Major> majors;

  /// A function to handle tap events.
  final Future<void> Function() onTap;

  /// The global key for the major field.
  final GlobalKey<FormFieldState> majorKey;

  @override
  Widget build(final BuildContext context) => GestureDetector(
    onTap: () async {
      if (majorOverlayEntry.value != null) {
        await onTap();
        return;
      }
      await onTap();
      // ignore: lines_longer_than_80_chars
      final RenderBox renderBox = majorKey.currentContext!.findRenderObject()! as RenderBox;
      final Size size = renderBox.size;
      final Offset position = renderBox.localToGlobal(Offset.zero);
      majorOverlayEntry.value = OverlayEntry(
        builder: (final context) => Positioned(
          top: position.dy + size.height,
          left: position.dx,
          width: size.width,
          child: Card(
            elevation: 8,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: majors.length,
                itemBuilder: (final context, final index) {
                  final major = majors[index];
                  return ListTile(
                    title: Text(major.name),
                    onTap: () async {
                      // ignore: lines_longer_than_80_chars
                      final newSelection = Set<Major>.from(selectedMajors.value)..add(major);
                      selectedMajors.value = newSelection;
                      await onTap();
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
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<ValueNotifier<OverlayEntry?>>(
          'majorOverlayEntry',
          majorOverlayEntry,
        ),
      )
      ..add(
        DiagnosticsProperty<ValueNotifier<Set<Major>>>(
          'selectedMajors',
          selectedMajors,
        ),
      )
      ..add(IterableProperty<Major>('majors', majors))
      ..add(ObjectFlagProperty<Future<void> Function()>.has('onTap', onTap))
      ..add(
        DiagnosticsProperty<GlobalKey<FormFieldState>>(
          'majorKey',
          majorKey,
        ),
      );
  }
}

/// A widget for displaying a list of selected job positions.
class _PositionSelector extends StatelessWidget {
  /// Creates a [_PositionSelector].
  const _PositionSelector({required this.selectedPositions});

  /// The set of selected job positions.
  final ValueNotifier<Set<Position>> selectedPositions;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...selectedPositions.value.map(
            (final item) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(item.name, style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close_outlined, size: 14),
                color: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.primaryContainer.withAlpha(160),
                ),
                onDeleted: () {
                  // ignore: lines_longer_than_80_chars
                  final newItems = Set<Position>.from(selectedPositions.value)..remove(item);
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
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<ValueNotifier<Set<Position>>>(
        'selectedPositions',
        selectedPositions,
      ),
    );
  }
}

/// A dropdown widget for selecting job positions.
class _PositionDropdown extends StatelessWidget {
  /// Creates a [_PositionDropdown].
  const _PositionDropdown({
    required this.positionOverlayEntry,
    required this.selectedPositions,
    required this.positions,
    required this.onTap,
    required this.positionKey,
  });

  /// The overlay entry for the position dropdown.
  final ValueNotifier<OverlayEntry?> positionOverlayEntry;

  /// The set of selected job positions.
  final ValueNotifier<Set<Position>> selectedPositions;

  /// The list of available job positions.
  final List<Position> positions;

  /// A function to handle tap events.
  final Future<void> Function() onTap;

  /// The global key for the position field.
  final GlobalKey<FormFieldState> positionKey;

  @override
  Widget build(final BuildContext context) => GestureDetector(
    onTap: () async {
      if (positionOverlayEntry.value != null) {
        await onTap();
        return;
      }
      await onTap();
      // ignore: lines_longer_than_80_chars
      final RenderBox renderBox = positionKey.currentContext!.findRenderObject()! as RenderBox;
      final Size size = renderBox.size;
      final Offset position = renderBox.localToGlobal(Offset.zero);
      positionOverlayEntry.value = OverlayEntry(
        builder: (final context) => Positioned(
          top: position.dy + size.height,
          left: position.dx,
          width: size.width,
          child: Card(
            elevation: 8,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: positions.length,
                itemBuilder: (final context, final index) {
                  final position = positions[index];
                  return ListTile(
                    title: Text(position.name),
                    onTap: () async {
                      // ignore: lines_longer_than_80_chars
                      final newSelection = Set<Position>.from(selectedPositions.value)..add(position);
                      selectedPositions.value = newSelection;
                      await onTap();
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
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<ValueNotifier<OverlayEntry?>>(
          'positionOverlayEntry',
          positionOverlayEntry,
        ),
      )
      ..add(
        DiagnosticsProperty<ValueNotifier<Set<Position>>>(
          'selectedPositions',
          selectedPositions,
        ),
      )
      ..add(IterableProperty<Position>('positions', positions))
      ..add(ObjectFlagProperty<Future<void> Function()>.has('onTap', onTap))
      ..add(
        DiagnosticsProperty<GlobalKey<FormFieldState>>(
          'positionKey',
          positionKey,
        ),
      );
  }
}

/// A custom navigation bar widget with a save button.
class _CustomNavbar extends StatelessWidget {
  /// Creates a [_CustomNavbar].
  const _CustomNavbar({required this.onPressed});

  /// The callback function when the save button is pressed.
  final void Function() onPressed;

  @override
  Widget build(final BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    ),
    child: CustomButton(
      key: const Key('save_profile_button'),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(context.t.auth.save),
      ),
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<void Function()>.has(
        'onPressed',
        onPressed,
      ),
    );
  }
}
