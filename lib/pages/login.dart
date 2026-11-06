import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marketers/pages/main_shell.dart';
import 'package:marketers/pages/signin.dart';
import 'package:marketers/service/api_client.dart';
import 'package:marketers/service/auth_session_store.dart';
import 'package:marketers/service/colors.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _apiClient = ApiClient();

  late final AnimationController _anim;

  bool _isLoading = false;
  bool _showPassword = false;
  String? _errorMessage;

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
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // Staggered entrance: each section fades and slides up in sequence.
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    return null;
  }

  // --------------------------------------------------------------------- login

  Future<void> _login() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      // 1. Login
      final response = await _apiClient.post(
        '/auth/login/',
        data: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );

      final data = response.data;
      final accessToken = data is Map ? data['access']?.toString() ?? '' : '';

      if (accessToken.isEmpty) {
        throw const ApiFailure(
          ApiFailureKind.response,
          'Login response did not include an access token.',
        );
      }

      // 2. Save token temporarily so we can call /auth/user/me/
      await AuthSessionStore.saveAccessToken(accessToken);

      // 3. Get authenticated user
      final userResponse = await _apiClient.get('/auth/user/me/');
      final userData = userResponse.data;

      if (userData is! Map) {
        await AuthSessionStore.clear();
        throw const ApiFailure(
          ApiFailureKind.response,
          'Invalid user information returned by the server.',
        );
      }

      // 4. Check role
      final role = userData['role']?.toString().toUpperCase();
      if (role != 'MARKETER') {
        await AuthSessionStore.clear();
        throw const ApiFailure(
          ApiFailureKind.response,
          'This account is not registered as a marketer.',
        );
      }

      // 5. User is a marketer -> continue
      if (!mounted) return;
      HapticFeedback.lightImpact();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainShell()),
      );
    } on ApiFailure catch (error) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() => _errorMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() => _errorMessage = 'Unable to sign in. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToSignin() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const Signin()));
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
                        const SizedBox(height: 32),
                        _reveal(start: 0.2, end: 0.8, child: _buildCard()),
                        const SizedBox(height: 24),
                        _reveal(
                          start: 0.45,
                          end: 1.0,
                          child: _buildSignupRow(),
                        ),
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

  // Soft gradient with two blurred glows for depth.
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
              right: -70,
              child: _glow(260, AppColors.pearl.withValues(alpha: 0.16)),
            ),
            Positioned(
              bottom: -110,
              left: -90,
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
        // Logo with glowing ring
        Container(
          height: 88,
          width: 88,
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
            Icons.storefront_rounded,
            size: 40,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 22),
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
        const SizedBox(height: 16),
        const Text(
          'Welcome back',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Log in to continue to your account',
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
                action: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: _validateEmail,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocus),
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                label: 'Password',
                hint: 'Enter your password',
                icon: Icons.lock_outline_rounded,
                obscure: !_showPassword,
                action: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: _validatePassword,
                onSubmitted: (_) => _login(),
                suffixIcon: IconButton(
                  tooltip: _showPassword ? 'Hide password' : 'Show password',
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: AppColors.textDisabled,
                  ),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
              ),
              const SizedBox(height: 26),
              _buildLoginButton(),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildLoginButton() {
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
            onTap: _isLoading ? null : _login,
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
                            'Log In',
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

  Widget _buildSignupRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: AppColors.textDisabled, fontSize: 14),
        ),
        TextButton(
          onPressed: _isLoading ? null : _goToSignin,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: const Size(0, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Sign up',
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
      onChanged: (_) {
        if (_errorMessage != null) setState(() => _errorMessage = null);
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
