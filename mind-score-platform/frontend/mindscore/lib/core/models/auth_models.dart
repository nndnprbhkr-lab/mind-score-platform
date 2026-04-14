// Data models for authentication and core assessment entities.
//
// This file contains the transfer objects that flow between the MindScore
// Flutter client and the .NET backend.  Models are intentionally immutable
// (const constructors) and expose factory constructors for JSON
// deserialisation, matching the pattern recommended by dart:convert.

// ─── TestModel ────────────────────────────────────────────────────────────────

/// Represents a single assessment available to the user.
///
/// Tests are fetched from `GET /api/tests` and displayed on the dashboard.
/// Each test maps to either the MPI (MindType Profile Inventory) or the
/// MindScore cognitive assessment.
class TestModel {
  /// Unique server-assigned identifier (UUID).
  final String id;

  /// Human-readable name shown in the UI (e.g. "MindType Assessment").
  final String name;

  /// Total number of questions in this assessment.
  final int questionCount;

  const TestModel({
    required this.id,
    required this.name,
    required this.questionCount,
  });

  /// Deserialises a [TestModel] from a JSON map returned by the API.
  factory TestModel.fromJson(Map<String, dynamic> j) => TestModel(
        id: j['id'] as String,
        name: j['name'] as String,
        questionCount: j['questionCount'] as int,
      );
}

// ─── ApiQuestionModel ─────────────────────────────────────────────────────────

/// A single question as returned by `GET /api/questions?testId=<id>`.
///
/// The API model contains only the question metadata.  Answer options (Likert
/// scale labels) are added client-side in [TestNotifier.loadTest] to avoid
/// storing static option text in the database.
class ApiQuestionModel {
  /// Unique server-assigned identifier (UUID).
  final String id;

  /// Identifier of the parent assessment.
  final String testId;

  /// The question text displayed to the user.
  final String text;

  /// Zero-based display order within the assessment.
  final int order;

  const ApiQuestionModel({
    required this.id,
    required this.testId,
    required this.text,
    required this.order,
  });

  /// Deserialises an [ApiQuestionModel] from a JSON map.
  factory ApiQuestionModel.fromJson(Map<String, dynamic> j) => ApiQuestionModel(
        id: j['id'] as String,
        testId: j['testId'] as String,
        text: j['text'] as String,
        order: j['order'] as int,
      );
}

// ─── ResultModel ─────────────────────────────────────────────────────────────

/// A scored assessment result returned by the API after submission or retrieval.
///
/// Results are polymorphic — the same model carries both MPI personality results
/// and MindScore cognitive results.  The [typeCode] field distinguishes them:
/// - MPI results: [typeCode] is a 4-letter code such as `EOLS`.
/// - MindScore results: [typeCode] is the sentinel value `MIND_SCORE`.
///
/// Use [hasMpiData] to branch between the two result types in the UI.
class ResultModel {
  /// Unique result identifier (UUID).
  final String id;

  /// The assessment this result belongs to.
  final String testId;

  /// Human-readable name of the assessment (e.g. "MindType Assessment").
  final String testName;

  /// Overall normalised score (0–100).
  final double score;

  /// MPI type code (e.g. `EOLS`) or `MIND_SCORE` for cognitive assessments.
  final String? typeCode;

  /// Human-readable personality or tier name (e.g. "The Strategist").
  final String? typeName;

  /// Emoji associated with the personality or score tier (e.g. `🧠`).
  final String? emoji;

  /// Short motivational tagline for the result (e.g. "Born to lead.").
  final String? tagline;

  /// Raw dimension scores — a JSON list for MindScore, a JSON map for MPI.
  final dynamic dimensionScores;

  /// Extended insight data — strengths, growth areas, career paths, etc.
  final Map<String, dynamic>? insights;

  /// UTC timestamp when the result was created on the server.
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

  /// `true` if this result contains MPI personality data (not a MindScore result).
  ///
  /// Used to decide which result provider and UI branch to activate.
  bool get hasMpiData =>
      typeCode != null && typeCode!.isNotEmpty && typeCode != 'MIND_SCORE';

  /// Deserialises a [ResultModel] from the API's JSON response.
  factory ResultModel.fromJson(Map<String, dynamic> j) => ResultModel(
        id: j['id'] as String,
        testId: j['testId'] as String,
        testName: j['testName'] as String,
        score: (j['score'] as num).toDouble(),
        typeCode: j['typeCode'] as String?,
        typeName: j['typeName'] as String?,
        emoji: j['emoji'] as String?,
        tagline: j['tagline'] as String?,
        dimensionScores: j['dimensionScores'],
        insights: j['insights'] as Map<String, dynamic>?,
        createdAtUtc: DateTime.parse(j['createdAtUtc'] as String),
      );
}

// ─── Request models ───────────────────────────────────────────────────────────

/// Payload for `POST /api/auth/login`.
class LoginRequest {
  /// Registered email address.
  final String email;

  /// Plain-text password (transmitted over HTTPS; never stored client-side).
  final String password;

  const LoginRequest({required this.email, required this.password});

  /// Serialises the request to a JSON-compatible map.
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

/// Payload for `POST /api/auth/register`.
class RegisterRequest {
  /// Display name shown in the UI and stored in the user profile.
  final String name;

  /// Email address used for login and communication.
  final String email;

  /// Plain-text password — hashed on the server using BCrypt.
  final String password;

  /// Optional date of birth — used to assign an age band for MindScore norms.
  final DateTime? dateOfBirth;

  /// Optional country or region of residence.
  final String? domicile;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.dateOfBirth,
    this.domicile,
  });

  /// Serialises the request to a JSON-compatible map, omitting optional
  /// fields when they are `null`.
  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
        if (domicile != null) 'domicile': domicile,
      };
}

/// Payload for `POST /api/auth/guest`.
///
/// Guest users do not need an email address.  A synthetic email is generated
/// server-side so the same user table and auth pipeline can be reused.
class GuestLoginRequest {
  /// Display name chosen by the guest user.
  final String name;

  /// Optional date of birth — required to take the MindScore assessment,
  /// which uses age-band normalisation.
  final DateTime? dateOfBirth;

  const GuestLoginRequest({required this.name, this.dateOfBirth});

  /// Serialises the request to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'name': name,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      };
}

// ─── AuthResponse ─────────────────────────────────────────────────────────────

/// The server's response to any successful authentication request.
///
/// Contains the JWT [token] required for subsequent authenticated API calls,
/// plus user metadata used to populate [AuthState].
class AuthResponse {
  /// Server-assigned user identifier (UUID string).
  final String userId;

  /// User's display name.
  final String name;

  /// User's email address (may be a synthetic address for guest users).
  final String email;

  /// JWT access token — must be included in the `Authorization: Bearer` header
  /// for all protected endpoints.
  final String token;

  /// `true` if the user has the `admin` role and may access the admin panel.
  final bool isAdmin;

  /// `true` if this is a temporary guest session.
  ///
  /// Guest users are limited in what they can save or access, but can still
  /// complete assessments and view results within a single session.
  final bool isGuest;

  /// `true` if the user's date of birth has been recorded on the server.
  ///
  /// The MindScore assessment requires a date of birth for age-band-normalised
  /// scoring.  When `false`, the UI gates the MindScore assessment behind a
  /// DOB collection step.
  final bool hasDob;

  const AuthResponse({
    required this.userId,
    required this.name,
    required this.email,
    required this.token,
    this.isAdmin = false,
    this.isGuest = false,
    this.hasDob = false,
  });

  /// Deserialises an [AuthResponse] from the API's JSON response.
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String,
      token: json['accessToken'] as String,
      isAdmin: json['isAdmin'] as bool? ?? false,
      isGuest: json['isGuest'] as bool? ?? false,
      hasDob: json['hasDob'] as bool? ?? false,
    );
  }
}
