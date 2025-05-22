import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:pdfx/pdfx.dart';

import '../../core/services/file_service.dart';
import '../../i18n/strings.g.dart';

/// A customizable elevated button widget.
class CustomButton extends StatelessWidget {
  /// Creates a [CustomButton].
  ///
  /// The [child] argument is required.
  /// The [onPressed] callback will be called when the button is tapped.
  /// The [color] can be used to override the default button color.
  const CustomButton({
    super.key,
    this.onPressed,
    required this.child,
    this.color,
  });

  /// Called when the button is tapped or otherwise activated.
  final void Function()? onPressed;

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text] widget.
  final Widget child;

  /// The background color of the button.
  ///
  /// If null, the primary color from the current theme is used.
  final Color? color;

  @override
  Widget build(final BuildContext context) => ElevatedButton(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(
        color ?? Theme.of(context).colorScheme.primary,
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(vertical: 20, horizontal: 32),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    onPressed: onPressed,
    child: child,
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<void Function()?>.has('onPressed', onPressed))
      ..add(ColorProperty('color', color));
  }
}

/// A dropdown button field that looks like a [TextField].
///
/// Allows users to select a value from a list of items in a dropdown menu.
class DropdownButtonField<T> extends StatefulWidget {
  /// Creates a [DropdownButtonField].
  ///
  /// The [label], [items], and [onChanged] arguments are required.
  /// The [value] is the currently selected value.
  /// The [textBuilder] can be used to customize the text displayed in the field
  const DropdownButtonField({
    super.key,
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
    this.textBuilder,
  });

  /// The label text to display above the dropdown field.
  final String label;

  /// The currently selected value.
  final T? value;

  /// The list of items to display in the dropdown menu.
  final List<DropdownMenuItem<T>> items;

  /// Called when the user selects an item from the dropdown menu.
  final void Function(T? value) onChanged;

  /// A function to build the text displayed in the field based on the value.
  ///
  /// If null, the `toString()` method of the selected value is used.
  final String Function()? textBuilder;

  @override
  State<DropdownButtonField<T>> createState() => _DropdownButtonFieldState<T>();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        ObjectFlagProperty<void Function(T? value)>.has(
          'onChanged',
          onChanged,
        ),
      )
      ..add(StringProperty('label', label))
      ..add(DiagnosticsProperty<T>('value', value))
      ..add(
        ObjectFlagProperty<String Function()?>.has(
          'textBuilder',
          textBuilder,
        ),
      );
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
      // ignore: lines_longer_than_80_chars
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
  Widget build(final BuildContext context) => LayoutBuilder(
    builder:
        (final context, final constraints) => MenuAnchor(
          style: MenuStyle(
            minimumSize: WidgetStatePropertyAll(
              Size(
                constraints.maxWidth + 8,
                0,
              ),
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
            ...widget.items.map(
              (final item) => MenuItemButton(
                onPressed: () async {
                  setState(() => _selectedValue = item.value);
                  widget.onChanged(item.value);
                  _controller.text =
                      // ignore: lines_longer_than_80_chars
                      widget.textBuilder != null ? widget.textBuilder!.call() : _selectedValue.toString();
                  _focusNode.unfocus();
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: item.child,
                ),
              ),
            ),
          ],
          builder:
              (final context, final controller, final child) => TextField(
                minLines: 1,
                maxLines: null,
                focusNode: _focusNode,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: widget.label,
                  labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: Icon(
                    IconlyLight.arrowDown,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
                onTap: () async {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                controller: _controller,
                onTapOutside: (final event) async {
                  _focusNode.unfocus();
                },
              ),
        ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', widget.label))
      ..add(DiagnosticsProperty<T>('value', widget.value))
      ..add(
        ObjectFlagProperty<void Function(T?)>.has(
          'onChanged',
          widget.onChanged,
        ),
      );
  }
}

/// A button widget that appears disabled, typically used to display static info
class DisabledButton extends StatelessWidget {
  /// Creates a [DisabledButton].
  ///
  /// The [title] argument is required and displayed as the button's text.
  const DisabledButton({super.key, required this.title});

  /// The text to display on the button.
  final String title;

  @override
  Widget build(final BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
  }
}

/// A button that, when pressed, shows a dialog to preview a PDF file.
class PreviewButton extends StatelessWidget {
  /// Creates a [PreviewButton].
  ///
  /// The [file] argument is required and contains the PDF file data to preview
  const PreviewButton({super.key, required this.file});

  /// A [ValueNotifier] holding the [FileSelectorResult] which contains the data
  final ValueNotifier<FileSelectorResult?> file;

  @override
  Widget build(final BuildContext context) => AnimatedOpacity(
    duration: const Duration(milliseconds: 300),
    opacity: 0.84,
    child: CustomButton(
      onPressed: () async {
        await showDialog(
          context: context,
          builder:
              (final context) => AlertDialog(
                title: Text(file.value!.name),
                content: SizedBox(
                  height: 600,
                  width: 400,
                  child: _PdfViewerPage(data: file.value!.data),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      context.t.common.close,
                    ),
                  ),
                ],
              ),
        );
      },
      child: Text(
        context.t.common.preview,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    ),
  );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<ValueNotifier<FileSelectorResult?>>('file', file),
    );
  }
}

/// A StatefulWidget to display a PDF document.
class _PdfViewerPage extends StatefulWidget {
  /// Creates a [_PdfViewerPage].
  ///
  /// The [data] argument is required and represents the bytes of the document.
  const _PdfViewerPage({
    super.key,
    required this.data,
  });

  /// The byte data of the PDF document.
  final Uint8List data;

  @override
  State<_PdfViewerPage> createState() => __PdfViewerPageState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<Uint8List>('data', [data]));
  }
}

/// The state for the [_PdfViewerPage] widget.
///
/// Manages the [PdfController] for displaying the PDF.
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
  Widget build(final BuildContext context) => Stack(
    children: [
      PdfView(controller: _pdfController, scrollDirection: Axis.vertical),
    ],
  );
}
