import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/party_member_model.dart';
import '../services/registration_service.dart';

class SupportRegistrationScreen extends StatefulWidget {
  const SupportRegistrationScreen({super.key});

  @override
  State<SupportRegistrationScreen> createState() =>
      _SupportRegistrationScreenState();
}

class _SupportRegistrationScreenState extends State<SupportRegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _registrationService = RegistrationService();

  // Controllers
  final _activationKeyController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isValidating = false;
  bool _keyValidated = false;
  bool _obscurePassword = true;
  PartyMemberModel? _linkedPartyMember;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _activationKeyController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validateKey() async {
    final key = _activationKeyController.text.trim();
    if (key.isEmpty) {
      _showError('Please enter an activation key');
      return;
    }

    setState(() => _isValidating = true);

    final partyMember = await _registrationService.validateActivationKey(key);

    setState(() {
      _isValidating = false;
      _linkedPartyMember = partyMember;
      _keyValidated = partyMember != null;
    });

    if (partyMember == null && mounted) {
      _showError('Invalid activation key. Please check and try again.');
    }
  }

  void _resetKey() {
    setState(() {
      _keyValidated = false;
      _linkedPartyMember = null;
      _activationKeyController.clear();
    });
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_linkedPartyMember == null) return;

    setState(() => _isLoading = true);

    final success = await _registrationService.registerSupportMember(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      activationKey: _activationKeyController.text.trim(),
      linkedPartyMember: _linkedPartyMember!,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      _showSuccessDialog();
    } else if (mounted) {
      _showError('Registration failed. Email may already be in use.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: AppTheme.cardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: AppTheme.greenGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGreen.withAlpha(80),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              Text('Welcome to the Team!',
                  style: AppTheme.headingMedium, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                'You are now registered as a support member for ${_linkedPartyMember!.name}\'s campaign.',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // Show linked details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  children: [
                    _miniInfoRow(Icons.location_on_rounded,
                        '${_linkedPartyMember!.village}, ${_linkedPartyMember!.taluka}'),
                    _miniInfoRow(Icons.flag_rounded,
                        'Party: ${_linkedPartyMember!.party}'),
                    _miniInfoRow(Icons.numbers_rounded,
                        'Ward: ${_linkedPartyMember!.wardNumber}'),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text(
                'You can now login with your email and password.',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.accentGreen,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop(); // Back to welcome
                  },
                  style: AppTheme.primaryButton(),
                  child: const Text('Go to Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentSaffron, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: AppTheme.bodyMedium.copyWith(
                    fontSize: 13, color: AppTheme.textPrimary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                // ─── App Bar ───
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: AppTheme.textPrimary),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text('Support Member Registration',
                            style: AppTheme.headingSmall),
                      ),
                    ],
                  ),
                ),

                // ─── Content ───
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // ═══ Step 1: Activation Key ═══
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: AppTheme.cardDecoration,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        gradient: _keyValidated
                                            ? AppTheme.greenGradient
                                            : AppTheme.saffronGradient,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: _keyValidated
                                            ? const Icon(Icons.check_rounded,
                                                color: Colors.white, size: 18)
                                            : const Text('1',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 16)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _keyValidated
                                          ? 'Key Verified ✓'
                                          : 'Enter Activation Key',
                                      style: AppTheme.headingSmall.copyWith(
                                        fontSize: 16,
                                        color: _keyValidated
                                            ? AppTheme.accentGreen
                                            : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Get this key from your party member',
                                  style: AppTheme.bodyMedium
                                      .copyWith(fontSize: 13),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _activationKeyController,
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        style: AppTheme.bodyLarge.copyWith(
                                          letterSpacing: 3,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        enabled: !_keyValidated,
                                        decoration: AppTheme.inputDecoration(
                                          label: 'Activation Key',
                                          icon: Icons.key_rounded,
                                          hint: 'e.g. AB12CD34',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      height: 56,
                                      child: _keyValidated
                                          ? ElevatedButton(
                                              onPressed: _resetKey,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppTheme.cardDark,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          14),
                                                  side: const BorderSide(
                                                      color:
                                                          AppTheme.cardBorder),
                                                ),
                                                padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 14),
                                              ),
                                              child: const Icon(
                                                  Icons.refresh_rounded,
                                                  color: AppTheme
                                                      .textSecondary),
                                            )
                                          : ElevatedButton(
                                              onPressed: _isValidating
                                                  ? null
                                                  : _validateKey,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppTheme.accentSaffron,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          14),
                                                ),
                                                padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 18),
                                              ),
                                              child: _isValidating
                                                  ? const SizedBox(
                                                      width: 22,
                                                      height: 22,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons
                                                          .arrow_forward_rounded,
                                                      color: Colors.white,
                                                    ),
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // ═══ Party Member Details (after validation) ═══
                          if (_keyValidated && _linkedPartyMember != null) ...[
                            const SizedBox(height: 18),

                            // Linked Party Member Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGreen.withAlpha(20),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color:
                                        AppTheme.accentGreen.withAlpha(60)),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.verified_rounded,
                                          color: AppTheme.accentGreen,
                                          size: 22),
                                      const SizedBox(width: 8),
                                      Text('Linked Party Member Details',
                                          style:
                                              AppTheme.bodyLarge.copyWith(
                                            color: AppTheme.accentGreen,
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  _infoRow(
                                      'Member', _linkedPartyMember!.name),
                                  _infoRow(
                                      'Party', _linkedPartyMember!.party),
                                  _infoRow('State',
                                      _linkedPartyMember!.state),
                                  _infoRow('District',
                                      _linkedPartyMember!.district),
                                  _infoRow('Taluka',
                                      _linkedPartyMember!.taluka),
                                  _infoRow('Village',
                                      _linkedPartyMember!.village),
                                  _infoRow('Ward',
                                      '${_linkedPartyMember!.wardNumber}'),
                                ],
                              ),
                            ),

                            // ═══ Step 2: Personal Details ═══
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: AppTheme.cardDecoration,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.greenGradient,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Center(
                                          child: Text('2',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  fontSize: 16)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text('Your Details',
                                          style: AppTheme.headingSmall
                                              .copyWith(fontSize: 16)),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  TextFormField(
                                    controller: _nameController,
                                    style: AppTheme.bodyLarge,
                                    decoration: AppTheme.inputDecoration(
                                      label: 'Full Name',
                                      icon: Icons.badge_rounded,
                                      hint: 'Enter your full name',
                                    ),
                                    validator: (v) => (v == null ||
                                            v.trim().isEmpty)
                                        ? 'Name is required'
                                        : null,
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType:
                                        TextInputType.emailAddress,
                                    style: AppTheme.bodyLarge,
                                    decoration: AppTheme.inputDecoration(
                                      label: 'Email Address',
                                      icon: Icons.email_rounded,
                                      hint: 'your@email.com',
                                    ),
                                    validator: (v) {
                                      if (v == null ||
                                          v.trim().isEmpty) {
                                        return 'Email is required';
                                      }
                                      if (!RegExp(
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(v.trim())) {
                                        return 'Enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: AppTheme.bodyLarge,
                                    decoration: AppTheme.inputDecoration(
                                      label: 'Password',
                                      icon: Icons.lock_rounded,
                                      hint: 'Min 6 characters',
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons
                                                  .visibility_off_rounded
                                              : Icons
                                                  .visibility_rounded,
                                          color: AppTheme.textSecondary,
                                          size: 22,
                                        ),
                                        onPressed: () => setState(() =>
                                            _obscurePassword =
                                                !_obscurePassword),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null ||
                                          v.trim().isEmpty) {
                                        return 'Password is required';
                                      }
                                      if (v.trim().length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 28),
                                  // Register Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.greenGradient,
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.accentGreen
                                                .withAlpha(80),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _isLoading
                                            ? null
                                            : _handleRegister,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.transparent,
                                          shadowColor:
                                              Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5,
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                children: [
                                                  const Icon(
                                                      Icons
                                                          .group_add_rounded,
                                                      color:
                                                          Colors.white),
                                                  const SizedBox(
                                                      width: 10),
                                                  Text(
                                                      'Join Campaign Team',
                                                      style: AppTheme
                                                          .buttonText),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: AppTheme.bodyMedium.copyWith(fontSize: 13)),
          ),
          Text(': ', style: AppTheme.bodyMedium),
          Expanded(
            child: Text(value,
                style: AppTheme.bodyLarge
                    .copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
