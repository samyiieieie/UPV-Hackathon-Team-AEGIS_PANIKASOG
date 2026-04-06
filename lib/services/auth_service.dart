import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentFirebaseUser => _auth.currentUser;

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String username,
    required String address,
    required List<String> skills,
    required List<String> preferredTasks,
    String? usedReferralCode,
  }) async {
    // Check username uniqueness
    final usernameSnap = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (usernameSnap.docs.isNotEmpty) {
      throw FirebaseAuthException(
        code: 'username-already-in-use',
        message: 'This username is already taken.',
      );
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName('$firstName $lastName');

    final referralCode = _generateReferralCode(user.uid);

    int bonusPoints = 0;
    String? validatedReferral;
    if (usedReferralCode != null && usedReferralCode.isNotEmpty) {
      final referrerSnap = await _db
          .collection('users')
          .where('referralCode', isEqualTo: usedReferralCode)
          .limit(1)
          .get();
      if (referrerSnap.docs.isNotEmpty) {
        validatedReferral = usedReferralCode;
        bonusPoints = 100;
        await referrerSnap.docs.first.reference.update({
          'points': FieldValue.increment(100),
        });
      }
    }

    final userModel = UserModel(
      uid: user.uid,
      email: email,
      phoneNumber: phoneNumber,
      firstName: firstName,
      lastName: lastName,
      username: username,
      address: address,
      skills: skills,
      preferredTasks: preferredTasks,
      referralCode: referralCode,
      usedReferralCode: validatedReferral,
      points: bonusPoints,
      dateJoined: DateTime.now(),
    );
    await _db.collection('users').doc(user.uid).set(userModel.toFirestore());
    await user.sendEmailVerification();
    return userModel;
  }

  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _fetchUserModel(credential.user!.uid);
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'sign-in-cancelled',
          message: 'Google sign-in was cancelled.',
        );
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        // Split display name into first and last
        final fullName = user.displayName ?? 'User';
        final nameParts = fullName.split(' ');
        final firstName = nameParts.first;
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        final username = 'user_${user.uid.substring(0, 6)}';
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          firstName: firstName,
          lastName: lastName,
          username: username,
          referralCode: _generateReferralCode(user.uid),
          avatarUrl: user.photoURL,
          dateJoined: DateTime.now(),
        );
        await _db.collection('users').doc(user.uid).set(userModel.toFirestore());
        return userModel;
      }
      return UserModel.fromFirestore(doc);
    } catch (e, st) {
      print("Google sign-in failed: $e");
      print(st);
      rethrow;
    }
  }

  Future<UserModel> _fetchUserModel(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'User profile not found.',
      );
    }
    return UserModel.fromFirestore(doc);
  }

  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      return await _fetchUserModel(user.uid);
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ─── Change Password (NEW) ───────────────────────────────────────────────
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    if (user.email == null) throw Exception('No email associated with this account');

    // Re-authenticate user
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Update password
    await user.updatePassword(newPassword);
  }

  String _generateReferralCode(String uid) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random.secure();
    final base = uid.substring(0, 4).toUpperCase();
    final suffix = List.generate(4, (_) => chars[rng.nextInt(chars.length)]).join();
    return '$base$suffix';
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  static bool isValidPhilippinePhone(String phone) {
    return RegExp(r'^\+63[0-9]{10}$').hasMatch(phone);
  }
}