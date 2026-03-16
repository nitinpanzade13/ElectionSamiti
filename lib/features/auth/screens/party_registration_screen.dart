import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/data/location_data.dart';
import '../services/registration_service.dart';

class PartyRegistrationScreen extends StatefulWidget {
  const PartyRegistrationScreen({super.key});

  @override
  State<PartyRegistrationScreen> createState() =>
      _PartyRegistrationScreenState();
}

class _PartyRegistrationScreenState extends State<PartyRegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _registrationService = RegistrationService();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _partyController = TextEditingController();
  final _wardController = TextEditingController();

  // Dropdown values
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedTaluka;
  String? _selectedVillage;

  // Dropdown options
  List<String> _states = [];
  List<String> _districts = [];
  List<String> _talukas = [];
  List<String> _villages = [];

  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _states = LocationData.getStates();
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _partyController.dispose();
    _wardController.dispose();
    super.dispose();
  }

  void _onStateChanged(String? value) {
    setState(() {
      _selectedState = value;
      _selectedDistrict = null;
      _selectedTaluka = null;
      _selectedVillage = null;
      _districts = value != null ? LocationData.getDistricts(value) : [];
      _talukas = [];
      _villages = [];
    });
  }

  void _onDistrictChanged(String? value) {
    setState(() {
      _selectedDistrict = value;
      _selectedTaluka = null;
      _selectedVillage = null;
      _talukas = (_selectedState != null && value != null)
          ? LocationData.getTalukas(_selectedState!, value)
          : [];
      _villages = [];
    });
  }

  void _onTalukaChanged(String? value) {
    setState(() {
      _selectedTaluka = value;
      _selectedVillage = null;
      _villages = (_selectedState != null &&
              _selectedDistrict != null &&
              value != null)
          ? LocationData.getVillages(_selectedState!, _selectedDistrict!, value)
          : [];
    });
  }

  void _onVillageChanged(String? value) {
    setState(() => _selectedVillage = value);
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedState == null ||
        _selectedDistrict == null ||
        _selectedTaluka == null ||
        _selectedVillage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select all location fields',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final activationKey = await _registrationService.registerPartyMember(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      state: _selectedState!,
      district: _selectedDistrict!,
      taluka: _selectedTaluka!,
      village: _selectedVillage!,
      party: _partyController.text.trim(),
      wardNumber: int.tryParse(_wardController.text.trim()) ?? 0,
    );

    setState(() => _isLoading = false);

    if (activationKey != null && mounted) {
      _showActivationKeyDialog(activationKey);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registration failed. Email may already be in use.',
            style: AppTheme.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showActivationKeyDialog(String key) {
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
              // Success Icon
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
              Text('Registration Successful!',
                  style: AppTheme.headingMedium, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                'Share this activation key with your support member',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Activation Key Display
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.accentSaffron, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.key_rounded,
                        color: AppTheme.accentSaffron, size: 24),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        key,
                        style: AppTheme.headingMedium.copyWith(
                          letterSpacing: 4,
                          color: AppTheme.accentSaffron,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '⚠️ Save this key! You will not see it again.',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.accentSaffron,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Copy Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: key));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Activation key copied!',
                            style: AppTheme.bodyMedium
                                .copyWith(color: Colors.white)),
                        backgroundColor: AppTheme.accentGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded,
                      color: AppTheme.accentSaffron),
                  label: Text('Copy Key',
                      style: AppTheme.buttonText
                          .copyWith(color: AppTheme.accentSaffron)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.cardBorder),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Done Button — goes back to welcome
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  style: AppTheme.primaryButton(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
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
                        child: Text('Party Member Registration',
                            style: AppTheme.headingSmall),
                      ),
                    ],
                  ),
                ),

                // ─── Form ───
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.cardDecoration,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ═══ Personal Info ═══
                            _buildSectionHeader(
                                Icons.person_rounded, 'Personal Information'),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              icon: Icons.badge_rounded,
                              hint: 'Enter your full name',
                            ),
                            const SizedBox(height: 14),
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              icon: Icons.email_rounded,
                              hint: 'your@email.com',
                              keyboard: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              icon: Icons.lock_rounded,
                              hint: 'Min 6 characters',
                              isPassword: true,
                            ),

                            const SizedBox(height: 28),
                            // ═══ Location (Cascading Dropdowns) ═══
                            _buildSectionHeader(
                                Icons.location_on_rounded, 'Location Details'),
                            const SizedBox(height: 8),
                            Text(
                              'Select your area step by step',
                              style: AppTheme.bodyMedium.copyWith(fontSize: 13),
                            ),
                            const SizedBox(height: 16),

                            // State Dropdown
                            _buildDropdown(
                              label: 'State',
                              icon: Icons.map_rounded,
                              value: _selectedState,
                              items: _states,
                              onChanged: _onStateChanged,
                              hint: 'Select State',
                            ),
                            const SizedBox(height: 14),

                            // District Dropdown
                            _buildDropdown(
                              label: 'District',
                              icon: Icons.location_city_rounded,
                              value: _selectedDistrict,
                              items: _districts,
                              onChanged: _onDistrictChanged,
                              hint: _selectedState == null
                                  ? 'Select state first'
                                  : 'Select District',
                              enabled: _selectedState != null,
                            ),
                            const SizedBox(height: 14),

                            // Taluka Dropdown
                            _buildDropdown(
                              label: 'Taluka',
                              icon: Icons.villa_rounded,
                              value: _selectedTaluka,
                              items: _talukas,
                              onChanged: _onTalukaChanged,
                              hint: _selectedDistrict == null
                                  ? 'Select district first'
                                  : 'Select Taluka',
                              enabled: _selectedDistrict != null,
                            ),
                            const SizedBox(height: 14),

                            // Village Dropdown
                            _buildDropdown(
                              label: 'Village',
                              icon: Icons.home_work_rounded,
                              value: _selectedVillage,
                              items: _villages,
                              onChanged: _onVillageChanged,
                              hint: _selectedTaluka == null
                                  ? 'Select taluka first'
                                  : 'Select Village',
                              enabled: _selectedTaluka != null,
                            ),

                            const SizedBox(height: 28),
                            // ═══ Election Info ═══
                            _buildSectionHeader(
                                Icons.how_to_vote_rounded, 'Election Details'),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _partyController,
                              label: 'Party Name',
                              icon: Icons.flag_rounded,
                              hint: 'e.g. BJP, INC, NCP...',
                            ),
                            const SizedBox(height: 14),
                            _buildTextField(
                              controller: _wardController,
                              label: 'Ward Number',
                              icon: Icons.numbers_rounded,
                              hint: 'e.g. 5',
                              keyboard: TextInputType.number,
                            ),

                            const SizedBox(height: 32),
                            // ═══ Register Button ═══
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: AppTheme.saffronGradient,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppTheme.accentSaffron.withAlpha(80),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                                Icons
                                                    .app_registration_rounded,
                                                color: Colors.white),
                                            const SizedBox(width: 10),
                                            Text(
                                                'Register & Get Activation Key',
                                                style: AppTheme.buttonText),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Reusable Widgets ───

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentSaffron, size: 22),
        const SizedBox(width: 10),
        Text(title, style: AppTheme.headingSmall.copyWith(fontSize: 16)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboard = TextInputType.text,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: isPassword ? _obscurePassword : false,
      style: AppTheme.bodyLarge,
      decoration:
          AppTheme.inputDecoration(label: label, icon: icon, hint: hint)
              .copyWith(
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppTheme.textSecondary,
                  size: 22,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        if (label == 'Email Address' &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                .hasMatch(value.trim())) {
          return 'Enter a valid email';
        }
        if (label == 'Password' && value.trim().length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? hint,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: AppTheme.bodyLarge.copyWith(fontSize: 14)),
              ))
          .toList(),
      onChanged: enabled ? onChanged : null,
      decoration: AppTheme.inputDecoration(label: label, icon: icon, hint: hint),
      dropdownColor: AppTheme.cardDark,
      style: AppTheme.bodyLarge,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: enabled ? AppTheme.accentSaffron : AppTheme.textSecondary.withAlpha(80),
      ),
      isExpanded: true,
      validator: (v) => v == null ? 'Please select $label' : null,
    );
  }
}
