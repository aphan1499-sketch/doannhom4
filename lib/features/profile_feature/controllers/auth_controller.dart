import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../main_navigation/main_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../services/device_management_service.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceManagementService _deviceManagementService =
      DeviceManagementService();

  late Rx<User?> _firebaseUser;

  var isPasswordHidden = true.obs;
  var isLoggedIn = false.obs;
  var isDarkMode = true.obs;
  var isLoading = false.obs;

  var currentUser = 'Người dùng mới'.obs;
  var userEmail = ''.obs;
  var userPhone = 'Chưa cập nhật'.obs;
  var userBirthDate = 'Chưa cập nhật'.obs;
  var userGender = 'Không tiết lộ'.obs;
  var userAvatar = 'assets/images/1.png'.obs;

  // Password strength (0: Weak, 1: Fair, 2: Good, 3: Strong, 4: Excellent)
  var passwordStrength = 0.obs;

  var activeDevices = [
    'iPhone 11 (Thiết bị này)',
    'Acer Aspire 7 - Windows 11',
    'Trình duyệt Chrome',
  ].obs;

  var paymentMethods = <Map<String, dynamic>>[
    {
      'id': '1',
      'type': 'visa',
      'cardNo': '•••• •••• •••• 4242',
      'cardHolder': 'NGUYEN VAN A',
      'expiry': '12/29',
      'isDefault': true,
      'gradientColors': [0xFF1F1C2C, 0xFF928DAB],
    },
    {
      'id': '2',
      'type': 'momo',
      'phone': '098****321',
      'isDefault': false,
      'gradientColors': [0xFFD82780, 0xFFE11B74],
    },
    {
      'id': '3',
      'type': 'bank',
      'bankName': 'Vietcombank',
      'accountNo': '•••• •••• 9876',
      'accountHolder': 'NGUYEN VAN A',
      'isDefault': false,
      'gradientColors': [0xFF0F2027, 0xFF203A43, 0xFF2C5364],
    },
  ].obs;

  @override
  void onReady() {
    super.onReady();
    _loadTheme();
    _firebaseUser = Rx<User?>(_auth.currentUser);
    _firebaseUser.bindStream(_auth.authStateChanges());
    ever(_firebaseUser, _setInitialScreen);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('isDarkMode') ?? true;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _setInitialScreen(User? user) async {
    if (user == null) {
      isLoggedIn.value = false;
      currentUser.value = 'Người dùng mới';
      userEmail.value = '';
      userPhone.value = 'Chưa cập nhật';
      userBirthDate.value = 'Chưa cập nhật';
      userGender.value = 'Không tiết lộ';
      userAvatar.value = 'assets/images/1.png';
    } else {
      isLoggedIn.value = true;
      userEmail.value = user.email ?? '';
      currentUser.value =
          user.displayName ?? user.email?.split('@')[0] ?? 'Người dùng mới';
      userAvatar.value = user.photoURL ?? 'assets/images/1.png';
      await _loadCachedUserData(user.uid);
      await _fetchUserData(user.uid);
      await _loadCachedAvatar(user.uid);
      // Centralized active device synchronization
      await _deviceManagementService.syncDeviceData();
      await loadActiveDevices();
    }
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      final authEmail = _auth.currentUser?.email;
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        if (authEmail != null &&
            authEmail.isNotEmpty &&
            data['email'] != authEmail) {
          await _firestore.collection('users').doc(uid).set({
            'email': authEmail,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          userEmail.value = authEmail;
        }
        currentUser.value = data['name'] ?? userEmail.value.split('@')[0];
        userPhone.value = data['phone'] ?? 'Chưa cập nhật';
        userBirthDate.value = data['dob'] ?? 'Chưa cập nhật';
        userGender.value = data['gender'] ?? 'Không tiết lộ';
        userAvatar.value = data['avatar'] ?? 'assets/images/1.png';
      }
    } catch (e) {
      debugPrint("Lỗi tải dữ liệu: $e");
    }
  }

  String _profileCacheKey(String uid, String field) => 'profile_${uid}_$field';

  Future<void> _loadCachedUserData(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    currentUser.value =
        prefs.getString(_profileCacheKey(uid, 'name')) ?? currentUser.value;
    userPhone.value =
        prefs.getString(_profileCacheKey(uid, 'phone')) ?? userPhone.value;
    userBirthDate.value =
        prefs.getString(_profileCacheKey(uid, 'dob')) ?? userBirthDate.value;
    userGender.value =
        prefs.getString(_profileCacheKey(uid, 'gender')) ?? userGender.value;
    userAvatar.value =
        prefs.getString(_profileCacheKey(uid, 'avatar')) ?? userAvatar.value;
  }

  Future<void> _loadCachedAvatar(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    userAvatar.value =
        prefs.getString(_profileCacheKey(uid, 'avatar')) ?? userAvatar.value;
  }

  Future<void> _cacheUserInfo(String uid, String field, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileCacheKey(uid, field), value);
  }

  void _applyLocalUserInfo(String field, String newValue) {
    switch (field) {
      case 'name':
        currentUser.value = newValue;
        break;
      case 'email':
        userEmail.value = newValue;
        break;
      case 'phone':
        userPhone.value = newValue;
        break;
      case 'dob':
        userBirthDate.value = newValue;
        break;
      case 'gender':
        userGender.value = newValue;
        break;
      case 'avatar':
        userAvatar.value = newValue;
        break;
    }
  }

  Map<String, dynamic> _userProfileData(User user) {
    return {
      'uid': user.uid,
      'email': user.email ?? userEmail.value,
      'name': currentUser.value,
      'phone': userPhone.value,
      'dob': userBirthDate.value,
      'gender': userGender.value,
      'avatar': userAvatar.value,
    };
  }

  Future<void> _syncUserInfoToFirestore(
    User user,
    String firestoreField,
    String newValue,
  ) async {
    await _firestore.collection('users').doc(user.uid).set({
      ..._userProfileData(user),
      firestoreField: newValue,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void togglePasswordVisibility() =>
      isPasswordHidden.value = !isPasswordHidden.value;

  void toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode.value);
  }

  void checkPasswordStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]')) ||
        password.contains(RegExp(r'[!@#\$&*~]'))) {
      score++;
    }
    passwordStrength.value = score;
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      await user?.reload();
      final refreshedUser = _auth.currentUser;
      final usesPasswordLogin =
          refreshedUser?.providerData.any(
            (provider) => provider.providerId == 'password',
          ) ??
          false;
      if (usesPasswordLogin && refreshedUser?.emailVerified == false) {
        await _auth.signOut();
        Get.snackbar(
          'Lá»—i Ä‘Äƒng nháº­p',
          'Vui lÃ²ng xÃ¡c thá»±c email trÆ°á»›c khi Ä‘Äƒng nháº­p.',
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      Get.offAll(() => MainNavigationScreen());
      Get.snackbar(
        'Thành công',
        'Đăng nhập thành công!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException {
      // Generic error message to prevent enumeration
      Get.snackbar(
        'Lỗi đăng nhập',
        'Tài khoản hoặc mật khẩu không chính xác.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (_) {
      Get.snackbar(
        'Lỗi',
        'Có lỗi xảy ra, vui lòng thử lại sau.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      isLoading.value = true;
      final trimmedEmail = email.trim();
      final trimmedUsername = username.trim();
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: trimmedEmail,
            password: password,
          );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': trimmedEmail,
        'name': trimmedUsername.isEmpty
            ? trimmedEmail.split('@')[0]
            : trimmedUsername,
        'phone': 'Chưa cập nhật',
        'dob': 'Chưa cập nhật',
        'gender': 'Không tiết lộ',
        'avatar': 'assets/images/1.png',
      });

      await userCredential.user!.sendEmailVerification();
      await _auth.signOut(); // Force sign out to require email verification

      Get.offAll(() => MainNavigationScreen());
      Get.snackbar(
        'Đăng ký thành công',
        'Vui lòng kiểm tra email để xác thực tài khoản trước khi đăng nhập.',
        backgroundColor: Colors.blueAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } on FirebaseAuthException {
      // Generic error message to prevent email enumeration
      Get.snackbar(
        'Lỗi',
        'Có lỗi xảy ra hoặc email đã được sử dụng.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (_) {
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi không xác định.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    // Mark current device as inactive in Firestore before signing out
    await _deviceManagementService.logOutDevice();

    await _auth.signOut();
    Get.offAll(() => MainNavigationScreen());
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email.trim());
      Get.back();
      Get.snackbar(
        'Đã gửi liên kết',
        'Vui lòng kiểm tra hộp thư Gmail để đặt lại mật khẩu.',
        backgroundColor: Colors.blueAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
      );
    } on FirebaseAuthException {
      // Generic error to prevent email enumeration
      Get.snackbar(
        'Lỗi',
        'Nếu email hợp lệ, chúng tôi đã gửi liên kết khôi phục.',
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserInfo(String field, String newValue) async {
    final user = _auth.currentUser;
    if (newValue.isEmpty || user == null) return;

    String firestoreField = '';
    switch (field) {
      case 'name':
        firestoreField = 'name';
        break;
      case 'email':
        firestoreField = 'email';
        break;
      case 'phone':
        firestoreField = 'phone';
        break;
      case 'dob':
        firestoreField = 'dob';
        break;
      case 'gender':
        firestoreField = 'gender';
        break;
      case 'avatar':
        firestoreField = 'avatar';
        break;
    }

    if (firestoreField.isEmpty) return;

    try {
      if (firestoreField == 'avatar') {
        _applyLocalUserInfo(field, newValue);
        await _cacheUserInfo(user.uid, firestoreField, newValue);
        Get.snackbar(
          'Thành công',
          'Đã đổi ảnh đại diện!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return;
      }

      if (firestoreField == 'email') {
        // Must update Firebase Auth first and await its completion
        await user.verifyBeforeUpdateEmail(newValue);
        Get.snackbar(
          'Kiá»ƒm tra email',
          'LiÃªn káº¿t xÃ¡c nháº­n Ä‘Ã£ Ä‘Æ°á»£c gá»­i. Email sáº½ Ä‘Æ°á»£c cáº­p nháº­t sau khi báº¡n xÃ¡c thá»±c.',
          backgroundColor: Colors.blueAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
        );
        return;
      }

      _applyLocalUserInfo(field, newValue);
      await _cacheUserInfo(user.uid, firestoreField, newValue);

      await _syncUserInfoToFirestore(user, firestoreField, newValue);

      Get.snackbar(
        'Thành công',
        'Đã cập nhật thông tin thành công!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        Get.snackbar(
          'Lỗi bảo mật',
          'Vui lòng đăng xuất và đăng nhập lại để thay đổi thông tin nhạy cảm.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Lỗi',
          'Không thể cập nhật email. Email không hợp lệ hoặc đã tồn tại.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Không thể lưu thông tin lên Firestore: $e');
      Get.snackbar(
        'Lỗi đồng bộ Firebase',
        'Không thể ghi vào users/${user.uid}. Hãy kiểm tra Firestore rules.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> loadActiveDevices() async {
    final user = _auth.currentUser;
    if (user == null) {
      activeDevices.clear();
      return;
    }

    try {
      final currentDeviceId = await _deviceManagementService
          .getCurrentDeviceId();
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('devices')
          .where('isActive', isEqualTo: true)
          .get();

      activeDevices.value = snapshot.docs.map((doc) {
        final data = doc.data();
        final deviceName = data['deviceName']?.toString().trim();
        final os = data['os']?.toString().trim();
        final labelParts = [
          if (deviceName != null && deviceName.isNotEmpty)
            deviceName
          else
            'Unknown Device',
          if (os != null && os.isNotEmpty) os,
        ];
        final isCurrentDevice = doc.id == currentDeviceId;
        final label =
            '${labelParts.join(' - ')}${isCurrentDevice ? ' (Thiáº¿t bá»‹ nÃ y)' : ''}';
        return '$label||${doc.id}';
      }).toList();
    } catch (e) {
      debugPrint('Lá»—i táº£i danh sÃ¡ch thiáº¿t bá»‹: $e');
    }
  }

  Future<void> removeDevice(String device) async {
    final user = _auth.currentUser;
    final parts = device.split('||');
    if (user == null || parts.length < 2) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('devices')
          .doc(parts.last)
          .update({'isActive': false});
      activeDevices.remove(device);
    } catch (e) {
      debugPrint('Lá»—i xoÃ¡ thiáº¿t bá»‹: $e');
      Get.snackbar(
        'Lá»—i',
        'KhÃ´ng thá»ƒ Ä‘Äƒng xuáº¥t thiáº¿t bá»‹ nÃ y.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    if (newPassword != confirmNewPassword) return;
    try {
      final user = _auth.currentUser;
      final email = user?.email;
      if (user == null || email == null || email.isEmpty) {
        Get.snackbar(
          'Lá»—i',
          'Báº¡n cáº§n Ä‘Äƒng nháº­p Ä‘á»ƒ Ä‘á»•i máº­t kháº©u.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
      if (newPassword.length < 8 ||
          !RegExp(r'(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(newPassword)) {
        Get.snackbar(
          'Lá»—i',
          'Máº­t kháº©u má»›i cáº§n Ã­t nháº¥t 8 kÃ½ tá»±, cÃ³ chá»¯ hoa, chá»¯ thÆ°á»ng vÃ  sá»‘.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      Get.back();
      Get.snackbar(
        'Thành công',
        'Đổi mật khẩu thành công!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        Get.snackbar(
          'Lỗi bảo mật',
          'Vui lòng đăng xuất và đăng nhập lại để thực hiện thay đổi mật khẩu.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Lỗi',
          'Lỗi khi đổi mật khẩu.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _syncSocialUserDocument(User user, String fallbackName) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email ?? '',
      'name': user.displayName ?? user.email?.split('@')[0] ?? fallbackName,
      'phone': user.phoneNumber ?? 'Chưa cập nhật',
      'dob': 'Chưa cập nhật',
      'gender': 'Không tiết lộ',
      'avatar': user.photoURL ?? 'assets/images/1.png',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user != null) {
        try {
          await _syncSocialUserDocument(user, 'Người dùng Google');
        } catch (e) {
          debugPrint('Không thể đồng bộ hồ sơ Google: $e');
          await _auth.signOut();
          Get.snackbar(
            'Lỗi đồng bộ',
            'Không thể tạo hồ sơ người dùng Google. Vui lòng thử lại.',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }

        // Kiểm tra xem user đã tồn tại trong Firestore chưa
        try {
          DocumentSnapshot doc = await _firestore
              .collection('users')
              .doc(user.uid)
              .get();
          if (!doc.exists) {
            await _firestore.collection('users').doc(user.uid).set({
              'uid': user.uid,
              'email': user.email ?? '',
              'name':
                  user.displayName ??
                  user.email?.split('@')[0] ??
                  'Người dùng Google',
              'phone': user.phoneNumber ?? 'Chưa cập nhật',
              'dob': 'Chưa cập nhật',
              'gender': 'Không tiết lộ',
              'avatar': user.photoURL ?? 'assets/images/1.png',
            });
          }
        } catch (e) {
          debugPrint('KhÃ´ng thá»ƒ táº¡o há»“ sÆ¡ Google: $e');
        }

        Get.offAll(() => MainNavigationScreen());
        Get.snackbar(
          'Thành công',
          'Đăng nhập Google thành công!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Lỗi đăng nhập Google: $e");
      Get.snackbar(
        'Lỗi',
        'Đăng nhập Google thất bại. Vui lòng thử lại.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      isLoading.value = true;
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.token,
        );

        UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );
        User? user = userCredential.user;

        if (user != null) {
          try {
            await _syncSocialUserDocument(user, 'Người dùng Facebook');
          } catch (e) {
            debugPrint('Không thể đồng bộ hồ sơ Facebook: $e');
            await _auth.signOut();
            Get.snackbar(
              'Lỗi đồng bộ',
              'Không thể tạo hồ sơ người dùng Facebook. Vui lòng thử lại.',
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
            );
            return;
          }

          // Kiểm tra xem user đã tồn tại trong Firestore chưa
          DocumentSnapshot doc = await _firestore
              .collection('users')
              .doc(user.uid)
              .get();
          if (!doc.exists) {
            await _firestore.collection('users').doc(user.uid).set({
              'uid': user.uid,
              'email': user.email ?? '',
              'name':
                  user.displayName ??
                  user.email?.split('@')[0] ??
                  'Người dùng Facebook',
              'phone': user.phoneNumber ?? 'Chưa cập nhật',
              'dob': 'Chưa cập nhật',
              'gender': 'Không tiết lộ',
              'avatar': user.photoURL ?? 'assets/images/1.png',
            });
          }

          Get.offAll(() => MainNavigationScreen());
          Get.snackbar(
            'Thành công',
            'Đăng nhập Facebook thành công!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      } else if (result.status == LoginStatus.cancelled) {
        debugPrint("Người dùng hủy đăng nhập Facebook");
      } else {
        debugPrint("Lỗi đăng nhập Facebook: ${result.message}");
        Get.snackbar(
          'Lỗi',
          'Đăng nhập Facebook thất bại: ${result.message}',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Lỗi đăng nhập Facebook: $e");
      Get.snackbar(
        'Lỗi',
        'Đăng nhập Facebook thất bại. Vui lòng thử lại.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void addPaymentMethod(Map<String, dynamic> method) {
    if (method['isDefault'] == true) {
      for (var pm in paymentMethods) {
        pm['isDefault'] = false;
      }
    }
    paymentMethods.add(method);
    paymentMethods.refresh();
  }

  void deletePaymentMethod(String id) {
    paymentMethods.removeWhere((pm) => pm['id'] == id);
    if (paymentMethods.isNotEmpty &&
        !paymentMethods.any((pm) => pm['isDefault'] == true)) {
      paymentMethods[0]['isDefault'] = true;
    }
    paymentMethods.refresh();
  }

  void setDefaultPaymentMethod(String id) {
    for (var pm in paymentMethods) {
      if (pm['id'] == id) {
        pm['isDefault'] = true;
      } else {
        pm['isDefault'] = false;
      }
    }
    paymentMethods.refresh();
  }
}
