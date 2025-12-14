import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Retorna o usuário atual ou null
  User? get currentUser => _auth.currentUser;

  // Stream para monitorar se o usuário logou/deslogou
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    try {
      // 1. Inicia o fluxo de login nativo do Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Usuário cancelou

      // 2. Obtém os detalhes de autenticação (tokens)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Cria uma credencial para o Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Faz o login no Firebase com essa credencial
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception('Esta conta já existe com credenciais diferentes.');
        case 'invalid-credential':
          throw Exception('As credenciais fornecidas estão inválidas.');
        case 'operation-not-allowed':
          throw Exception('Login com Google não está habilitado no Firebase.');
        case 'user-disabled':
          throw Exception('Esta conta foi desabilitada.');
        case 'user-not-found':
          throw Exception('Nenhuma conta encontrada com estas credenciais.');
        case 'wrong-password':
          throw Exception('Senha incorreta.');
        case 'invalid-verification-code':
          throw Exception('Código de verificação inválido.');
        case 'invalid-verification-id':
          throw Exception('ID de verificação inválido.');
        default:
          throw Exception('Erro de autenticação: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado no login: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
