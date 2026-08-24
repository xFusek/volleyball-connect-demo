import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthBloc({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance,
      super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        emit(Authenticated(user.uid));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: event.email,
            password: event.password,
          );
      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': event.fullName,
          'email': event.email,
          'phone': event.phone,
          'image': 'https://via.placeholder.com/150',
          'lastActive': DateTime.now(),
          'isOnline': false,
        });

        await _firestore.collection('profiles').doc(user.uid).set({
          'fullName': event.fullName,
          'location': 'Poland',
          'birthday': DateTime(2000, 1, 1),
          'height': 0,
          'courtPosition': '',
          'coverImageURL': 'https://via.placeholder.com/600x200',
          'profileImageURL': 'https://via.placeholder.com/150',
          'postsCount': 0,
          'friendsCount': 0,
          'matchesCount': 0,
        });

        await user.sendEmailVerification();
        emit(Authenticated(user.uid));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Błąd rejestracji'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _firebaseAuth.signOut();
    emit(Unauthenticated());
  }

 Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        emit(Unauthenticated());
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
      User? user = _firebaseAuth.currentUser;

      if (user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': googleUser.displayName ?? 'Unknown',
            'email': googleUser.email,
            'image': googleUser.photoUrl ?? 'https://via.placeholder.com/150',
            'lastActive': DateTime.now(),
            'isOnline': false,
          });

          await _firestore.collection('profiles').doc(user.uid).set({
            'fullName': googleUser.displayName ?? 'Unknown',
            'location': 'Poland',
            'birthday': DateTime(2000, 1, 1),
            'height': 0,
            'courtPosition': '',
            'coverImageURL': 'https://via.placeholder.com/600x200',
            'profileImageURL': googleUser.photoUrl ?? 'https://via.placeholder.com/150',
            'postsCount': 0,
            'friendsCount': 0,
            'matchesCount': 0,
          });
        }

        emit(Authenticated(user.uid));
      }
    } catch (e) {
      emit(AuthFailure('Failed to sign in with Google: $e'));
    }
  }
}
