import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/common/bloc/bloc.dart';
import 'package:flutter_starter/common/widgets/text_field/text_field.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// [AppTextField] with an eye toggle. Each instance owns its own cubit, so
/// several password fields on a screen toggle independently. Validate with
/// `AuthValidators.password` / `confirmPassword` (auth module).
class AppPasswordField extends StatelessWidget {
  const AppPasswordField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helperText,
    this.errorText,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.autofillHints,
    this.focusNode,
    this.readOnly = false,
    this.enabled = true,
    this.isRequired = false,
    this.autofocus = false,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool enabled;
  final bool isRequired;
  final bool autofocus;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PasswordVisibilityCubit(),
      child: BlocBuilder<PasswordVisibilityCubit, PasswordVisibilityState>(
        builder: (context, state) {
          return AppTextField(
            label: label,
            controller: controller,
            hint: hint,
            helperText: helperText,
            errorText: errorText,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            validator: validator,
            autofillHints: autofillHints,
            focusNode: focusNode,
            readOnly: readOnly,
            enabled: enabled,
            isRequired: isRequired,
            autofocus: autofocus,
            maxLength: maxLength,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            obscureText: !state.isPasswordVisible,
            suffix: IconButton(
              onPressed: () => context.read<PasswordVisibilityCubit>().toggle(),
              icon: Icon(
                state.isPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 18.r,
              ),
            ),
          );
        },
      ),
    );
  }
}
