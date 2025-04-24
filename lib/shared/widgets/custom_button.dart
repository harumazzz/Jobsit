import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, this.onPressed, required this.child});

  final void Function()? onPressed;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0)))),
      ),
      onPressed: onPressed,
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<void Function()?>.has('onPressed', onPressed));
  }
}

class DropdownButtonField<T> extends StatefulWidget {
  const DropdownButtonField({super.key, required this.label, this.value, required this.items, required this.onChanged});

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T? value) onChanged;

  @override
  State<DropdownButtonField<T>> createState() => _DropdownButtonFieldState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<void Function(T? value)>.has('onChanged', onChanged));
    properties.add(StringProperty('label', label));
    properties.add(DiagnosticsProperty<T>('value', value));
  }
}

class _DropdownButtonFieldState<T> extends State<DropdownButtonField<T>> {
  late final FocusNode _focusNode;
  late T _selectedValue;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    if (widget.value != null) {
      _selectedValue = widget.value as T;
    }
    _controller = TextEditingController();
    if (widget.value != null) {
      _controller.text = _selectedValue.toString();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MenuAnchor(
          style: MenuStyle(
            minimumSize: WidgetStatePropertyAll(Size(constraints.maxWidth + 8, 0)),
            maximumSize: WidgetStatePropertyAll(Size(constraints.maxWidth + 8, double.infinity)),
            elevation: WidgetStateProperty.all(4.0),
          ),
          crossAxisUnconstrained: false,
          alignmentOffset: const Offset(0, 8),
          menuChildren: [
            ...widget.items.map((item) {
              return MenuItemButton(
                onPressed: () async {
                  if (item.value != null) {
                    setState(() => _selectedValue = item.value as T);
                    widget.onChanged(item.value);
                    _controller.text = _selectedValue.toString();
                  }
                  _focusNode.unfocus();
                },
                child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16.0), title: item.child),
              );
            }),
          ],
          builder: (context, controller, child) {
            return TextField(
              minLines: 1,
              maxLines: null,
              focusNode: _focusNode,
              readOnly: true,
              decoration: InputDecoration(
                labelText: widget.label,
                labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primaryContainer),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primaryContainer),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                suffixIcon: Icon(IconlyLight.arrowDown, color: Theme.of(context).colorScheme.primaryContainer),
              ),
              onTap: () async {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              controller: _controller,
              onTapOutside: (event) async {
                _focusNode.unfocus();
              },
            );
          },
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', widget.label));
    properties.add(DiagnosticsProperty<T>('value', widget.value));
    properties.add(ObjectFlagProperty<void Function(T?)>.has('onChanged', widget.onChanged));
  }
}
