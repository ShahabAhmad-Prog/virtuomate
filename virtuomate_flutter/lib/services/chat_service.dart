import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Realtime coach chat messages in Firestore: users/{uid}/coachChat/{id}
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    this.emotion,
    required this.createdAt,
  });

  final String id;
  final bool isUser;
  final String text;
  final String? emotion;
  final DateTime createdAt;

  factory ChatMessage.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final ts = data['createdAt'];
    DateTime created = DateTime.now();
    if (ts is Timestamp) created = ts.toDate();
    return ChatMessage(
      id: doc.id,
      isUser: data['isUser'] == true,
      text: (data['text'] as String?) ?? '',
      emotion: data['emotion'] as String?,
      createdAt: created,
    );
  }
}

class ChatService {
  ChatService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>>? get _col {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('coachChat');
  }

  Stream<List<ChatMessage>> watchMessages({int limit = 120}) {
    final col = _col;
    if (col == null) return Stream.value(const []);
    return col
        .orderBy('createdAt', descending: false)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs.map(ChatMessage.fromDoc).toList(),
        );
  }

  Future<void> addUserMessage(String text) async {
    final col = _col;
    if (col == null) return;
    await col.add({
      'isUser': true,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addCoachMessage(String text, {String? emotion}) async {
    final col = _col;
    if (col == null) return;
    await col.add({
      'isUser': false,
      'text': text.trim(),
      if (emotion != null) 'emotion': emotion,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> seedWelcomeIfEmpty() async {
    final col = _col;
    if (col == null) return;
    final existing = await col.limit(1).get();
    if (existing.docs.isNotEmpty) return;
    await addCoachMessage(
      "Hi! I'm your VirtuoMate coach. Ask about interviews, presentations, or career goals.",
      emotion: 'Focused',
    );
  }
}
