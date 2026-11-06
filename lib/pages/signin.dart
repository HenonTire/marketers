import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marketers/pages/login.dart';
import 'package:marketers/pages/main_shell.dart';
import 'package:marketers/service/colors.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  late final AnimationController _anim;

  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String? _errorMessage;

  static const int _minPasswordLength = 8;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Widget _reveal({
    required double start,
    required double end,
    required Widget child,
  }) {
    final curve = CurvedAnimation(
      parent: _anim,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  // ---------------------------------------------------------------- validation

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }

  String? _validateUsername(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please choose a username';
    if (text.length < 3) return 'Username must be at least 3 characters';
    if (text.contains(RegExp(r'\s'))) return 'Username cannot contain spaces';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please create a password';
    if (value.length < _minPasswordLength) {
      return 'Use at least $_minPasswordLength characters';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  // Returns 0..4
  int _passwordStrength(String p) {
    if (p.isEmpty) return 0;
    var score = 0;
    if (p.length >= _minPasswordLength) score++;
    if (p.contains(RegExp(r'[A-Z]')) && p.contains(RegExp(r'[a-z]'))) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (p.contains(RegExp(r'[^A-Za-z0-9]'))) score++;
    return score;
  }

  // ------------------------------------------------------------------- submit

  Future<void> _signIn() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      // TODO: replace with the real registration API call.
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      HapticFeedback.lightImpact();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainShell()),
      );
    } catch (_) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToLogin() {
    // Login pushes Signin, so go back when possible to avoid stacking pages.
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
      );
    }
  }

  // --------------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _reveal(start: 0.0, end: 0.5, child: _buildHeader()),
                        const SizedBox(height: 28),
                        _reveal(start: 0.2, end: 0.8, child: _buildCard()),
                        const SizedBox(height: 22),
                        _reveal(start: 0.45, end: 1.0, child: _buildLoginRow()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.surface.withValues(alpha: 0.55),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              left: -70,
              child: _glow(260, AppColors.pearl.withValues(alpha: 0.16)),
            ),
            Positioned(
              bottom: -110,
              right: -90,
              child: _glow(300, AppColors.pearl.withValues(alpha: 0.10)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow(double size, Color color) {
    return IgnorePointer(
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            border: Border.all(
              color: AppColors.pearl.withValues(alpha: 0.7),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.pearl.withValues(alpha: 0.28),
                blurRadius: 32,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            size: 36,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.pearl.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.pearl.withValues(alpha: 0.35)),
          ),
          child: const Text(
            'SHIKELA MARKETER',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Create your account',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Join Shikela and start in a minute',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: AppColors.textDisabled),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildErrorBanner(),
              _buildField(
                controller: _emailController,
                focusNode: _emailFocus,
                label: 'Email',
                hint: 'you@example.com',
                icon: Icons.alternate_email_rounded,
                keyboard: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: _validateEmail,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_usernameFocus),
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _usernameController,
                focusNode: _usernameFocus,
                label: 'Username',
                hint: 'Choose a username',
                icon: Icons.person_outline_rounded,
                autofillHints: const [AutofillHints.newUsername],
                validator: _validateUsername,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocus),
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                label: 'Password',
                hint: 'At least $_minPasswordLength characters',
                icon: Icons.lock_outline_rounded,
                obscure: !_showPassword,
                autofillHints: const [AutofillHints.newPassword],
                validator: _validatePassword,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_confirmFocus),
                suffixIcon: _visibilityToggle(
                  visible: _showPassword,
                  onTap: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
              _buildStrengthMeter(),
              const SizedBox(height: 16),
              _buildField(
                controller: _confirmPasswordController,
                focusNode: _confirmFocus,
                label: 'Confirm password',
                hint: 'Re-enter your password',
                icon: Icons.verified_user_outlined,
                obscure: !_showConfirmPassword,
                action: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validator: _validateConfirm,
                onSubmitted: (_) => _signIn(),
                suffixIcon: _visibilityToggle(
                  visible: _showConfirmPassword,
                  onTap: () => setState(
                    () => _showConfirmPassword = !_showConfirmPassword,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _visibilityToggle({
    required bool visible,
    required VoidCallback onTap,
  }) {
    return IconButton(
      tooltip: visible ? 'Hide password' : 'Show password',
      icon: Icon(
        visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 20,
        color: AppColors.textDisabled,
      ),
      onPressed: onTap,
    );
  }

  Widget _buildStrengthMeter() {
    final password = _passwordController.text;
    final strength = _passwordStrength(password);

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: password.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: List.generate(4, (i) {
                        final active = i < strength;
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 4,
                            margin: EdgeInsets.only(right: i == 3 ? 0 : 5),
                            decoration: BoxDecoration(
                              color: active
                                  ? _strengthColor(strength)
                                  : AppColors.border.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _strengthLabel(strength),
                    style: TextStyle(
                      color: _strengthColor(strength),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Color _strengthColor(int s) {
    switch (s) {
      case 0:
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.orangeAccent;
      case 3:
        return Colors.amber;
      default:
        return Colors.greenAccent;
    }
  }

  String _strengthLabel(int s) {
    switch (s) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      default:
        return 'Strong';
    }
  }

  Widget _buildErrorBanner() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: _errorMessage == null
          ? const SizedBox(width: double.infinity)
          : Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isLoading ? 0.75 : 1,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: LinearGradient(
            colors: [AppColors.pearl, AppColors.pearl.withValues(alpha: 0.82)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.pearl.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: _isLoading ? null : _signIn,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isLoading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.black,
                        ),
                      )
                    : const Row(
                        key: ValueKey('label'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Colors.black,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(color: AppColors.textDisabled, fontSize: 14),
        ),
        TextButton(
          onPressed: _isLoading ? null : _goToLogin,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: const Size(0, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Log in',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.pearl,
              decorationThickness: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboard = TextInputType.text,
    TextInputAction action = TextInputAction.next,
    bool obscure = false,
    Widget? suffixIcon,
    Iterable<String>? autofillHints,
    ValueChanged<String>? onSubmitted,
    ValueChanged<String>? onChanged,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboard,
      textInputAction: action,
      obscureText: obscure,
      autofillHints: autofillHints,
      validator: validator,
      enabled: !_isLoading,
      autocorrect: false,
      enableSuggestions: !obscure,
      onFieldSubmitted: onSubmitted,
      onChanged: (value) {
        if (_errorMessage != null) setState(() => _errorMessage = null);
        onChanged?.call(value);
      },
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      cursorColor: AppColors.pearl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: const TextStyle(
          color: AppColors.textDisabled,
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
        errorStyle: const TextStyle(fontSize: 12, height: 1.2),
        prefixIcon: Icon(icon, size: 20, color: AppColors.textDisabled),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.background.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: border(AppColors.border),
        enabledBorder: border(AppColors.border.withValues(alpha: 0.5)),
        disabledBorder: border(AppColors.border.withValues(alpha: 0.25)),
        focusedBorder: border(AppColors.pearl, 1.6),
        errorBorder: border(Colors.redAccent),
        focusedErrorBorder: border(Colors.redAccent, 1.6),
      ),
    );
  }
}
