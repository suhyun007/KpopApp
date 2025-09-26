import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../l10n/app_localizations.dart';
import '../config/google_signin_config.dart';
import '../config/apple_signin_config.dart';
import '../services/notification_service.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool _pushNotificationsEnabled = true;
  bool _isLoggedIn = false;
  String _userName = 'Guest';
  String _userEmail = '';
  String _userPhotoUrl = '';
  String _loginProvider = '';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: GoogleSignInConfig.scopes,
  );

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _checkNotificationStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userName = prefs.getString('userName') ?? 'Guest';
    final userEmail = prefs.getString('userEmail') ?? '';
    final userPhotoUrl = prefs.getString('userPhotoUrl') ?? '';
    final loginProvider = prefs.getString('loginProvider') ?? '';

    setState(() {
      _isLoggedIn = isLoggedIn;
      _userName = userName;
      _userEmail = userEmail;
      _userPhotoUrl = userPhotoUrl;
      _loginProvider = loginProvider;
    });
  }

  Future<void> _checkNotificationStatus() async {
    try {
      final supabase = Supabase.instance.client;
      final deviceInfo = DeviceInfoPlugin();
      String deviceId;
      
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown-ios';
      } else {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      }

      // user_push_tokens 테이블에서 해당 device_id의 is_active 상태 확인
      try {
        final response = await supabase
          .from('user_push_tokens')
          .select('is_active')
          .eq('device_id', deviceId)
          .single();
          
        setState(() {
          _pushNotificationsEnabled = response['is_active'] == true;
        });
      } catch (e) {
        // 토큰이 없는 경우 OFF로 설정
        setState(() {
          _pushNotificationsEnabled = false;
        });
      }
    } catch (e) {
      // 에러 발생 시 (토큰이 없는 경우) OFF로 설정
      setState(() {
        _pushNotificationsEnabled = false;
      });
    }
  }

  Future<void> _saveLoginStatus({
    required String userName,
    required String userEmail,
    required String userPhotoUrl,
    required String loginProvider,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', userName);
    await prefs.setString('userEmail', userEmail);
    await prefs.setString('userPhotoUrl', userPhotoUrl);
    await prefs.setString('loginProvider', loginProvider);
  }

  Future<void> _clearLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userPhotoUrl');
    await prefs.remove('loginProvider');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'My Page',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 프로필 섹션
            _buildProfileSection(),
            const SizedBox(height: 20),
            
            
            // 알림 설정 섹션
            _buildSectionTitle('Notifications'),
            _buildNotificationSection(),
            const SizedBox(height: 20),
            
            // 앱 설정 섹션
            /*
            _buildSectionTitle('App Settings'),
            _buildAppSettingsSection(),
            const SizedBox(height: 20),
            */
            
            // 정보 섹션
            _buildSectionTitle('Information'),
            _buildInformationSection(),
            const SizedBox(height: 20),
            
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFCFA23B), Color(0xFFB57A1A)],
          stops: [0.1, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 프로필 이미지
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: _userPhotoUrl.isNotEmpty 
                ? NetworkImage(_userPhotoUrl) 
                : null,
            child: _userPhotoUrl.isEmpty
                ? Icon(
                    _isLoggedIn ? Icons.person : Icons.person_outline,
                    size: 30,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(height: 5),
          
          // 사용자 이름
          Text(
            _userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // 이메일 (로그인된 경우만)
          if (_isLoggedIn && _userEmail.isNotEmpty)
            Text(
              _userEmail,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          
          // 로그인/회원가입 버튼 또는 로그아웃 버튼
          if (!_isLoggedIn)
            Transform.translate(
              offset: const Offset(0, -5),
              child: ElevatedButton(
              onPressed: _showLoginOptions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFD6A93A),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                minimumSize: const Size(0, 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Login / Sign Up',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            )
          else
            Transform.translate(
              offset: const Offset(0, -5),
              child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFD6A93A),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                minimumSize: const Size(0, 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFD6A93A),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


  Widget _buildNotificationSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFB8860B),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildSwitchItem(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Receive notifications about new concerts',
            value: _pushNotificationsEnabled,
            onChanged: (value) async {
              setState(() {
                _pushNotificationsEnabled = value;
              });
              
              // 알림 설정 변경 시 DB 업데이트
              if (value) {
                await NotificationService.enableNotifications();
              } else {
                await NotificationService.disableNotifications();
              }
            },
          ),
          /*
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.email,
            title: 'Email Notifications',
            subtitle: 'Manage email notification preferences',
            onTap: _showEmailSettings,
          ),
          */
        ],
      ),
    );
  }

  Widget _buildInformationSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFB8860B),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.info,
            title: 'About App',
            subtitle: 'Version 1.0.0',
            onTap: _showAboutApp,
          ),
          _buildDivider(),
          /*
          _buildMenuItem(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: _showHelpSupport,
          ),
          _buildDivider(),
          */
          _buildMenuItem(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: _showPrivacyPolicy,
          ),
          /*
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'Read our terms of service',
            onTap: _showTermsOfService,
          ),
          */
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFFD6A93A),
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFFD6A93A),
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFD6A93A),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[700],
      height: 1,
      indent: 56,
    );
  }


  // 이벤트 핸들러들
  void _showLoginOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Login Method',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Apple 로그인은 iOS에서만 사용
            if (Theme.of(context).platform == TargetPlatform.iOS) ...[
              _buildLoginButton(
                icon: Icons.apple,
                title: 'Continue with Apple',
                onTap: _loginWithApple,
              ),
              const SizedBox(height: 10),
            ],
            _buildGoogleLoginButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _loginWithGoogle,
        icon: Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(left: 12),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('image/icons/g-logo.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
        label: const Text(
          'Continue with Google',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.grey, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    Color backgroundColor;
    Color iconColor;
    
    if (title.contains('Google')) {
      backgroundColor = const Color(0xFF4285F4);
      iconColor = Colors.white;
    } else if (title.contains('Apple')) {
      backgroundColor = Colors.black;
      iconColor = Colors.white;
    } else {
      backgroundColor = Colors.grey[800]!;
      iconColor = Colors.white;
    }
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: iconColor, size: title.contains('Apple') ? 24 : 20),
        label: Text(
          title,
          style: TextStyle(
            color: iconColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: title.contains('Apple') 
                ? const BorderSide(color: Colors.white, width: 1)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Future<void> _loginWithGoogle() async {
    Navigator.pop(context);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // 사용자가 취소한 경우

      await googleUser.authentication;
      
      setState(() {
        _isLoggedIn = true;
        _userName = googleUser.displayName ?? 'Google User';
        _userEmail = googleUser.email;
        _userPhotoUrl = googleUser.photoUrl ?? '';
        _loginProvider = 'Google';
      });

      await _saveLoginStatus(
        userName: _userName,
        userEmail: _userEmail,
        userPhotoUrl: _userPhotoUrl,
        loginProvider: _loginProvider,
      );

      _showSnackBar('Google 로그인 성공!');
    } catch (error) {
      _showSnackBar('Google 로그인 실패: $error');
    }
  }

  Future<void> _loginWithApple() async {
    Navigator.pop(context);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: AppleSignInConfig.scopes,
      );

      setState(() {
        _isLoggedIn = true;
        _userName = '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
        if (_userName.isEmpty) _userName = 'Apple User';
        _userEmail = credential.email ?? '';
        _userPhotoUrl = '';
        _loginProvider = 'Apple';
      });

      await _saveLoginStatus(
        userName: _userName,
        userEmail: _userEmail,
        userPhotoUrl: _userPhotoUrl,
        loginProvider: _loginProvider,
      );

      _showSnackBar('Apple 로그인 성공!');
    } catch (error) {
      _showSnackBar('Apple 로그인 실패: $error');
    }
  }

  Future<void> _logout() async {
    try {
      if (_loginProvider == 'Google') {
        await _googleSignIn.signOut();
      }
      
      await _clearLoginStatus();
      
      setState(() {
        _isLoggedIn = false;
        _userName = 'Guest';
        _userEmail = '';
        _userPhotoUrl = '';
        _loginProvider = '';
      });

      _showSnackBar('로그아웃 완료!');
    } catch (error) {
      _showSnackBar('로그아웃 실패: $error');
    }
  }

  void _showLanguageSettings() {
    _showSnackBar('Language Settings - Coming Soon');
  }

  void _showStorageSettings() {
    _showSnackBar('Storage Settings - Coming Soon');
  }

  void _showAboutApp() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // App Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE6C767), Color(0xFFB8860B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // App Name
                  Text(
                    AppLocalizations.of(context)?.aboutKpopCall ?? 'About K-POP Call',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Version
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6C767).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE6C767), width: 1),
                    ),
                    child: Text(
                      'Version 1.0.0',
                      style: const TextStyle(
                        color: Color(0xFFE6C767),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.about ?? 'About',
                      style: const TextStyle(
                        color: Color(0xFFE6C767),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)?.aboutDescription ?? 'K-POP Call is your ultimate destination for K-POP concert information and artist updates. Stay connected with your favorite artists and never miss a concert again.',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)?.features ?? 'Features',
                      style: const TextStyle(
                        color: Color(0xFFE6C767),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem('🎵', AppLocalizations.of(context)?.popularArtistsFeature ?? 'Popular Artists'),
                    _buildFeatureItem('🎤', AppLocalizations.of(context)?.concertInformationFeature ?? 'Concert Information'),
                    _buildFeatureItem('🗺️', AppLocalizations.of(context)?.concertMapFeature ?? 'Concert Map'),
                    _buildFeatureItem('🔔', AppLocalizations.of(context)?.notificationsFeature ?? 'Notifications'),
                    _buildFeatureItem('👤', AppLocalizations.of(context)?.userProfileFeature ?? 'User Profile'),
                    const SizedBox(height: 24), // Extra space at bottom
                  ],
                ),
              ),
            ),
            // Close Button
            Container(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE6C767),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)?.close ?? 'Close',
                    style: const TextStyle(
                      fontSize: 16,
          fontWeight: FontWeight.bold,
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

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 16,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport() {
    _showSnackBar('Help & Support - Coming Soon');
  }

  void _showPrivacyPolicy() {
    Navigator.pushNamed(context, '/privacy-policy');
  }

  void _showTermsOfService() {
    _showSnackBar('Terms of Service - Coming Soon');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD6A93A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
