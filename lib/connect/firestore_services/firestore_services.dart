import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OnlineStatusService {
  final FirebaseFirestore _firestore;
  final Connectivity _connectivity;
  StreamSubscription? _connectivitySubscription;
  bool _isDisposed = false;

  OnlineStatusService({
    FirebaseFirestore? firestore,
    Connectivity? connectivity,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _connectivity = connectivity ?? Connectivity();

  Future<void> init(String userId) async {
    if (_isDisposed) return;

    try {
      await _firestore.collection('Users').doc(userId).set({
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
        status,
      ) async {
        if (_isDisposed) return;
        await _updateStatus(userId, status != ConnectivityResult.none);
      }, onError: (e) => print('Connectivity error: $e'));

      _firestore
          .collection('Users')
          .doc(userId)
          .snapshots()
          .listen((_) {})
          .onDone(() async {
            if (!_isDisposed) {
              await _updateStatus(userId, false);
            }
          });
    } catch (e) {
      print('OnlineStatusService init error: $e');
    }
  }

  Future<void> _updateStatus(String userId, bool isOnline) async {
    if (_isDisposed) return;

    try {
      await _firestore.collection('Users').doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to update status: $e');
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}
