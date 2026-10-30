import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/auth/features/features.dart';
import 'package:flutter_starter/modules/auth/utils/utils.dart';

/// Email, password and Remember me, checked with [AuthValidators] before
/// the cubit is called. The remembered email is filled in.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(
    text: context.read<LoginCubit>().state.rememberedEmail,
  );
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<LoginCubit>().login(
      email: _email.text,
      password: _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: AuthStrings.email,
              hint: AuthStrings.emailHint,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: AuthValidators.email,
              isRequired: true,
            ),
            16.verticalSpace,
            AppPasswordField(
              label: AuthStrings.password,
              controller: _password,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: AuthValidators.requiredPassword,
              isRequired: true,
              onSubmitted: (_) => _submit(),
            ),
            8.verticalSpace,
            BlocBuilder<LoginCubit, LoginState>(
              buildWhen: (a, b) => a.remember != b.remember,
              builder: (context, state) => CheckboxListTile(
                value: state.remember,
                onChanged: (value) =>
                    context.read<LoginCubit>().setRemember(value ?? false),
                title: const Text(AuthStrings.rememberMe),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            16.verticalSpace,
            FilledButton(
              onPressed: _submit,
              child: const Text(AuthStrings.signIn),
            ),
          ],
        ),
      ),
    );
  }
}
