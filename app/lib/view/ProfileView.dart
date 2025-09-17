import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hacknova/model/user_model.dart';

class ProfilePage extends StatefulWidget {
  final UserDataService userDataService;

  const ProfilePage({super.key, required this.userDataService});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late TextEditingController _usernameController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isEditing = false;

  // Mock user data - replace with actual data from your service
  final Map<String, String> _userDetails = {
    'touristId': 'TID-2024-MH001',
    'issueDate': '15 Jan 2024',
    'expiryDate': '14 Jan 2026',
    'nationality': 'Indian',
    'passportNumber': 'A1234567',
    'emergencyContact': '+91 98765 43210',
    'bloodGroup': 'B+',
    'medicalInfo': 'No known allergies',
  };

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text:
          widget.userDataService.username.isEmpty
              ? 'John Doe'
              : widget.userDataService.username,
    );
    _locationController = TextEditingController(text: 'Mumbai, Maharashtra');
    _phoneController = TextEditingController(text: '+91 98765 43210');
    _emailController = TextEditingController(text: 'john.doe@example.com');

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _usernameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(),
                const SizedBox(height: 32),

                // Digital Tourist ID Card
                _buildDigitalIdCard(),
                const SizedBox(height: 24),

                // Personal Information Section
                _buildPersonalInfoSection(),
                const SizedBox(height: 24),

                // Emergency & Medical Info
                _buildEmergencySection(),
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          // Profile Picture with status indicator
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [const Color(0xFF007AFF), const Color(0xFF34C759)],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: const AssetImage(
                      'assets/images/lotus_img.jpeg',
                    ),
                    backgroundColor: Colors.grey[800],
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name and Location
          Text(
            _usernameController.text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: Colors.grey[400], size: 16),
              const SizedBox(width: 4),
              Text(
                _locationController.text,
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusBadge('Verified Tourist', const Color(0xFF34C759)),
              const SizedBox(width: 12),
              _buildStatusBadge('Premium', const Color(0xFFFF9500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDigitalIdCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF007AFF).withOpacity(0.8),
            const Color(0xFF5856D6).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007AFF).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DIGITAL TOURIST ID',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      _userDetails['touristId']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.qr_code,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ID Details grid
            Row(
              children: [
                Expanded(
                  child: _buildIdDetail(
                    'Issue Date',
                    _userDetails['issueDate']!,
                  ),
                ),
                Expanded(
                  child: _buildIdDetail('Expires', _userDetails['expiryDate']!),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildIdDetail(
                    'Nationality',
                    _userDetails['nationality']!,
                  ),
                ),
                Expanded(
                  child: _buildIdDetail(
                    'Passport',
                    _userDetails['passportNumber']!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minSize: 0,
                color:
                    _isEditing
                        ? const Color(0xFF34C759)
                        : const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(8),
                child: Text(
                  _isEditing ? 'Save' : 'Edit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  if (_isEditing) {
                    _saveChanges();
                  }
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildInfoField(
            'Username',
            _usernameController,
            Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _buildInfoField('Email', _emailController, Icons.email_outlined),
          const SizedBox(height: 12),
          _buildInfoField('Phone', _phoneController, Icons.phone_outlined),
          const SizedBox(height: 12),
          _buildInfoField(
            'Location',
            _locationController,
            Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color:
                _isEditing
                    ? Colors.white.withOpacity(0.08)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  _isEditing
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
            ),
          ),
          child:
              _isEditing
                  ? CupertinoTextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    placeholder: label,
                    placeholderStyle: TextStyle(color: Colors.grey[500]),
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(),
                    prefix: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: Icon(icon, color: Colors.grey[500], size: 18),
                    ),
                  )
                  : Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(icon, color: Colors.grey[500], size: 18),
                        const SizedBox(width: 12),
                        Text(
                          controller.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildEmergencySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency & Medical',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildEmergencyDetail(
                  'Emergency Contact',
                  _userDetails['emergencyContact']!,
                  Icons.phone_in_talk,
                  const Color(0xFFFF3B30),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEmergencyDetail(
                  'Blood Group',
                  _userDetails['bloodGroup']!,
                  Icons.bloodtype,
                  const Color(0xFFFF9500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildEmergencyDetail(
            'Medical Information',
            _userDetails['medicalInfo']!,
            Icons.medical_information_outlined,
            const Color(0xFF34C759),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyDetail(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary action buttons
        Row(
          children: [
            Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 14),
                color: const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(12),
                child: const Text(
                  'Export Digital ID',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => _exportDigitalId(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 14),
                color: const Color(0xFF34C759),
                borderRadius: BorderRadius.circular(12),
                child: const Text(
                  'Share Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => _shareProfile(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Secondary actions
        Row(
          children: [
            Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () => _openSettings(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                child: Text(
                  'Help & Support',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () => _openSupport(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _saveChanges() {
    widget.userDataService.setUserData(
      _usernameController.text,
      widget.userDataService.password,
    );

    // Show success message
    _showSuccessDialog('Profile updated successfully!');
  }

  void _exportDigitalId() {
    _showInfoDialog(
      'Export Digital ID',
      'Your digital tourist ID will be exported as a QR code.',
    );
  }

  void _shareProfile() {
    _showInfoDialog(
      'Share Profile',
      'Your profile information will be shared securely.',
    );
  }

  void _openSettings() {
    _showInfoDialog('Settings', 'Settings panel will open here.');
  }

  void _openSupport() {
    _showInfoDialog('Help & Support', 'Support center will be available soon.');
  }

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Success'),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }
}
