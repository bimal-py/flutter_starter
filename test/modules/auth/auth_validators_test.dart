import 'package:flutter_starter/modules/auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an email must look like one', () {
    expect(AuthValidators.email('ada@example.com'), isNull);
    expect(AuthValidators.email('  ada@example.com  '), isNull);
    expect(AuthValidators.email('ada@'), AuthError.emailInvalid);
    expect(AuthValidators.email(null), AuthError.emailInvalid);
  });

  test('a new password follows the backend rules', () {
    expect(AuthValidators.password('Short1'), AuthError.passwordTooShort);
    expect(
      AuthValidators.password('onlyletters'),
      AuthError.passwordNeedsLettersAndNumbers,
    );
    expect(
      AuthValidators.password('lowercase123'),
      AuthError.passwordNeedsUpperAndLower,
    );
    expect(AuthValidators.password('Lovelace1815'), isNull);
  });

  test('the repeat must match, and can\'t be empty', () {
    const required = 'Repeat your password';
    expect(
      AuthValidators.confirmPassword('', 'a', requiredMessage: required),
      required,
    );
    expect(
      AuthValidators.confirmPassword('b', 'a', requiredMessage: required),
      AuthError.passwordsDoNotMatch,
    );
    expect(
      AuthValidators.confirmPassword('a', 'a', requiredMessage: required),
      isNull,
    );
  });
}
