import 'package:Flui/core/app/app.dart';
import 'package:Flui/core/services/auth_services.dart';
import 'package:Flui/core/services/user_service.dart';
import 'package:Flui/feature_auth/data/repositories/auth_repository.dart';
import 'package:Flui/feature_auth/data/repositories/user_repository.dart';
import 'package:Flui/firebase_options.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreUserService _firestoreUserService = FirestoreUserService(
    _firestore,
  );
  final UserRepository _userRepo = UserRepository(_firestoreUserService);
  final FirebaseAuthService _authService = FirebaseAuthService(
    _auth,
    _firestore,
  );
  final user = AuthRepository(_authService, _userRepo).getCurrentUser();
  if (user != null) {
    await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  runApp(ProviderScope(child: const MyApp()));
}
