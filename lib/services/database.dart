import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;

  // Atualiza o ID do usuário
  void setUserId(String? userId) {
    _userId = userId;
  }

  // Referência à coleção do usuário específico
  CollectionReference? get _userFoodCollection {
    if (_userId == null) return null;
    return _firestore.collection('users').doc(_userId).collection('food_logs');
  }

  // Adicionar alimento com tratamento de erro
  Future<void> addFoodEntry(Map<String, dynamic> data) async {
    if (_userFoodCollection == null) {
      throw Exception('Usuário não autenticado. Faça login novamente.');
    }
    try {
      await _userFoodCollection!.add(data);
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'permission-denied':
          throw Exception(
            'Sem permissão para salvar dados. Verifique as configurações.',
          );
        case 'unavailable':
          throw Exception(
            'Serviço temporariamente indisponível. Tente novamente.',
          );
        case 'deadline-exceeded':
          throw Exception('Tempo de conexão esgotado. Verifique sua internet.');
        default:
          throw Exception('Erro ao salvar: ${e.message ?? e.code}');
      }
    } catch (e) {
      throw Exception('Erro inesperado ao salvar: $e');
    }
  }

  // Stream para ouvir mudanças em tempo real
  Stream<QuerySnapshot?> getFoodEntries() {
    if (_userFoodCollection == null) {
      return Stream.empty();
    }
    return _userFoodCollection!.orderBy('date', descending: true).snapshots();
  }

  // Deletar alimento
  Future<void> deleteFoodEntry(String documentId) async {
    if (_userFoodCollection == null) {
      throw Exception('Usuário não autenticado. Faça login novamente.');
    }
    try {
      await _userFoodCollection!.doc(documentId).delete();
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'permission-denied':
          throw Exception('Sem permissão para deletar dados.');
        case 'not-found':
          throw Exception('Item não encontrado.');
        case 'unavailable':
          throw Exception(
            'Serviço temporariamente indisponível. Tente novamente.',
          );
        default:
          throw Exception('Erro ao deletar: ${e.message ?? e.code}');
      }
    } catch (e) {
      throw Exception('Erro inesperado ao deletar: $e');
    }
  }

  // Referência ao documento de configurações do usuário
  DocumentReference? get _userSettingsDoc {
    if (_userId == null) return null;
    return _firestore.collection('users').doc(_userId);
  }

  // Buscar metas de macros do usuário
  Future<Map<String, dynamic>?> getMacroGoals() async {
    if (_userSettingsDoc == null) {
      throw Exception('Usuário não autenticado.');
    }
    try {
      final doc = await _userSettingsDoc!.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['macroGoals'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao carregar metas: $e');
    }
  }

  // Salvar metas de macros do usuário
  Future<void> saveMacroGoals(Map<String, dynamic> goals) async {
    if (_userSettingsDoc == null) {
      throw Exception('Usuário não autenticado.');
    }
    try {
      await _userSettingsDoc!.set({
        'macroGoals': goals,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw Exception('Erro ao salvar metas: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}
