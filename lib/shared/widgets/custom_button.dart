import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:pdfx/pdfx.dart';

import '../../core/services/file_service.dart';
import '../../i18n/strings.g.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, this.onPressed, required this.child, this.color});

  final void Function()? onPressed;

  final Widget child;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(color ?? Theme.of(context).colorScheme.primary),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 20.0, horizontal: 32.0)),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<void Function()?>.has('onPressed', onPressed));
    properties.add(ColorProperty('color', color));
  }
}

class DropdownButtonField<T> extends StatefulWidget {
  const DropdownButtonField({
    super.key,
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
    this.textBuilder,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T? value) onChanged;
  final String Function()? textBuilder;

  @override
  State<DropdownButtonField<T>> createState() => _DropdownButtonFieldState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<void Function(T? value)>.has('onChanged', onChanged));
    properties.add(StringProperty('label', label));
    properties.add(DiagnosticsProperty<T>('value', value));
    properties.add(ObjectFlagProperty<String Function()?>.has('textBuilder', textBuilder));
  }
}

class _DropdownButtonFieldState<T> extends State<DropdownButtonField<T>> {
  late final FocusNode _focusNode;
  late T? _selectedValue;
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
      _controller.text = widget.textBuilder != null ? widget.textBuilder!.call() : _selectedValue.toString();
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
                  setState(() => _selectedValue = item.value);
                  widget.onChanged(item.value);
                  _controller.text =
                      widget.textBuilder != null ? widget.textBuilder!.call() : _selectedValue.toString();
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

class DisabledButton extends StatelessWidget {
  const DisabledButton({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
  }
}

class PreviewButton extends StatelessWidget {
  const PreviewButton({super.key, required this.file});

  final ValueNotifier<FileSelectorResult?> file;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 0.84,
      child: CustomButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(file.value!.name),
                  content: SizedBox(height: 600.0, width: 400.0, child: _PdfViewerPage(data: file.value!.data)),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(context.t.common.close))],
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
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ValueNotifier<FileSelectorResult?>>('file', file));
  }
}

class _PdfViewerPage extends StatefulWidget {
  const _PdfViewerPage({super.key, required this.data});

  final Uint8List data;

  @override
  State<_PdfViewerPage> createState() => __PdfViewerPageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<Uint8List>('data', [data]));
  }
}

class __PdfViewerPageState extends State<_PdfViewerPage> {
  late PdfController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(document: PdfDocument.openData(widget.data));
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [PdfView(controller: _pdfController, scrollDirection: Axis.vertical)]);
  }
}
