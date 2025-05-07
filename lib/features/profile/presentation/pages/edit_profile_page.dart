import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/input_converter.dart';
import '../../../../shared/widgets/custom_button.dart';

class PersonalInfoEditPage extends HookWidget {
  const PersonalInfoEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);
    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final emailController = useTextEditingController();
    final phoneController = useTextEditingController();
    final addressController = useTextEditingController();
    final universityController = useTextEditingController();
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
    final cityOptions = ['Ho Chi Minh'];
    final districtOptions = ['District 1', 'District 2', 'District 3'];
    final selectedGender = useState('Male');
    final selectedCity = useState('Ho Chi Minh');
    final selectedDistrict = useState('District 1');
    final selectedDate = useState<DateTime?>(DateTime(2000));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold)),
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
                          child: const Icon(IconlyLight.profile, size: 48.0, color: Colors.grey),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                            child: IconButton(
                              icon: const Icon(IconlyLight.camera, color: Colors.white, size: 16),
                              onPressed: () async {
                                // TODO(self): Implement image selection
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
                                  child: Text(selectedCity.value),
                                ),
                              );
                            },
                          );
                        },
                        menuChildren: [
                          ...cityOptions.map((city) {
                            return MenuItemButton(
                              onPressed: () async {
                                selectedCity.value = city;
                                cityFocusNode.unfocus();
                                FocusScope.of(context).requestFocus(districtFocusNode);
                              },
                              child: Text(city),
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
                            name: 'district',
                            focusNode: districtFocusNode,
                            validator: (value) => null,
                            builder: (FormFieldState<dynamic> field) {
                              return InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'District',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                                  contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    controller.open();
                                  },
                                  child: Text(selectedDistrict.value),
                                ),
                              );
                            },
                          );
                        },
                        menuChildren: [
                          ...districtOptions.map((district) {
                            return MenuItemButton(
                              onPressed: () {
                                selectedDistrict.value = district;
                                districtFocusNode.unfocus();
                                FocusScope.of(context).requestFocus(addressFocusNode);
                              },
                              child: Text(district),
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
                  FormBuilderTextField(
                    name: 'university',
                    controller: universityController,
                    focusNode: universityFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'University',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    ),
                    onSubmitted: (_) async {
                      universityFocusNode.unfocus();
                    },
                  ),
                  const SizedBox(height: 32.0),
                  CustomButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        // TODO(self): Implement saving personal information to API

                        ElegantNotification.success(
                          background: const Color(0xFFDEF2ED),
                          description: const Text('Personal information updated successfully!'),
                        ).show(context);
                        context.pop();
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
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
    final locationFocusNode = useFocusNode();
    final cvFocusNode = useFocusNode();
    final coverLetterFocusNode = useFocusNode();
    final positionOptions = ['Option 1', 'Option 2', 'Option 3'];
    final majorOptions = ['Option 1', 'Option 2', 'Option 3'];
    final jobTypeOptions = ['Option 1', 'Option 2', 'Option 3'];
    final locationOptions = ['Ho Chi Minh city'];
    final selectedPositions = useState<List<String>>(['Option 2']);
    final selectedMajor = useState<String>('Option 1');
    final selectedJobType = useState<String>('Option 1');
    final selectedLocation = useState(locationOptions[0]);
    return Scaffold(
      appBar: AppBar(
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
                  FormBuilderField(
                    name: 'position',
                    focusNode: positionFocusNode,
                    validator: (value) => null,
                    builder: (FormFieldState<dynamic> field) {
                      return InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Position',
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                        ),
                        child: Wrap(
                          spacing: 8.0,
                          children: [
                            ...positionOptions.map((position) {
                              final isSelected = selectedPositions.value.contains(position);
                              return FilterChip(
                                label: Text(position),
                                selected: isSelected,
                                onSelected: (value) {
                                  List<String> updatedList = List.from(selectedPositions.value);
                                  if (value) {
                                    if (!updatedList.contains(position)) {
                                      updatedList.add(position);
                                    }
                                  } else {
                                    updatedList.remove(position);
                                  }
                                  selectedPositions.value = updatedList;
                                  field.didChange(updatedList);
                                  if (positionFocusNode.hasFocus) {
                                    positionFocusNode.unfocus();
                                    FocusScope.of(context).requestFocus(majorFocusNode);
                                  }
                                },
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return MenuAnchor(
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
                                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                                  contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    controller.open();
                                  },
                                  child: Text(selectedMajor.value),
                                ),
                              );
                            },
                          );
                        },
                        menuChildren: [
                          ...majorOptions.map((major) {
                            return MenuItemButton(
                              onPressed: () async {
                                selectedMajor.value = major;
                                majorFocusNode.unfocus();
                                FocusScope.of(context).requestFocus(jobTypeFocusNode);
                              },
                              child: Text(major),
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
                            name: 'job_type',
                            focusNode: jobTypeFocusNode,
                            validator: (value) => null,
                            builder: (FormFieldState<dynamic> field) {
                              return InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Job Type',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                                  contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    controller.open();
                                  },
                                  child: Text(selectedJobType.value),
                                ),
                              );
                            },
                          );
                        },
                        menuChildren: [
                          ...jobTypeOptions.map((jobType) {
                            return MenuItemButton(
                              onPressed: () async {
                                selectedJobType.value = jobType;
                                jobTypeFocusNode.unfocus();
                                FocusScope.of(context).requestFocus(locationFocusNode);
                              },
                              child: Text(jobType),
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
                            name: 'location',
                            focusNode: locationFocusNode,
                            validator: (value) => null,
                            builder: (FormFieldState<dynamic> field) {
                              return InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Location',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                                  contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    controller.open();
                                  },
                                  child: Text(selectedLocation.value),
                                ),
                              );
                            },
                          );
                        },
                        menuChildren: [
                          ...locationOptions.map((location) {
                            return MenuItemButton(
                              onPressed: () async {
                                selectedLocation.value = location;
                                locationFocusNode.unfocus();
                                FocusScope.of(context).requestFocus(cvFocusNode);
                              },
                              child: Text(location),
                            );
                          }),
                        ],
                      );
                    },
                  ),
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
                              // TODO(self): Implement CV upload
                            },
                          );
                        },
                      ),
                    ),
                    onTap: () async {
                      // TODO(self): Implement CV selection
                      cvFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(coverLetterFocusNode);
                    },
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
                  const SizedBox(height: 32.0),
                  CustomButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();

                        // TODO(self): Implement saving job information to API

                        // Show success notification
                        ElegantNotification.success(
                          background: const Color(0xFFDEF2ED),
                          description: const Text('Job information updated successfully!'),
                        ).show(context);
                        context.pop();
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
