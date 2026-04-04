class TestModel {
  final String id;
  final String name;
  final int questionCount;

  const TestModel({required this.id, required this.name, required this.questionCount});

  factory TestModel.fromJson(Map<String, dynamic> j) => TestModel(
        id: j['id'] as String,
        name: j['name'] as String,
        questionCount: j['questionCount'] as int,
      );
}

class ApiQuestionModel {
  final String id;
  final String testId;
  final String text;
  final int order;

  const ApiQuestionModel({
    required this.id,
    required this.testId,
    required this.text,
    required this.order,
  });

  factory ApiQuestionModel.fromJson(Map<String, dynamic> j) => ApiQuestionModel(
        id: j['id'] as String,
        testId: j['testId'] as String,
        text: j['text'] as String,
        order: j['order'] as int,
      );
}

class ResultModel {
  final String id;
  final String testId;
  final String testName;
  final double score;
  // MPI enriched fields (null for legacy/non-MPI results)
  final String? typeCode;
  final String? typeName;
  final String? emoji;
  final String? tagline;
  final Map<String, dynamic>? dimensionScores;
  final Map<String, dynamic>? insights;
  final DateTime createdAtUtc;

  const ResultModel({
    required this.id,
    required this.testId,
    required this.testName,
    required this.score,
    this.typeCode,
    this.typeName,
    this.emoji,
    this.tagline,
    this.dimensionScores,
    this.insights,
    required this.createdAtUtc,
  });

  bool get hasMpiData => typeCode != null && typeCode!.isNotEmpty;

  factory ResultModel.fromJson(Map<String, dynamic> j) => ResultModel(
        id: j['id'] as String,
        testId: j['testId'] as String,
        testName: j['testName'] as String,
        score: (j['score'] as num).toDouble(),
        typeCode: j['typeCode'] as String?,
        typeName: j['typeName'] as String?,
        emoji: j['emoji'] as String?,
        tagline: j['tagline'] as String?,
        dimensionScores: j['dimensionScores'] as Map<String, dynamic>?,
        insights: j['insights'] as Map<String, dynamic>?,
        createdAtUtc: DateTime.parse(j['createdAtUtc'] as String),
      );
}

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String email;
  final String password;

  const RegisterRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class AuthResponse {
  final String userId;
  final String email;
  final String token;
  final bool isAdmin;

  const AuthResponse({
    required this.userId,
    required this.email,
    required this.token,
    this.isAdmin = false,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'] as String,
      email: json['email'] as String,
      token: json['accessToken'] as String,
      isAdmin: json['isAdmin'] as bool? ?? false,
    );
  }
}
