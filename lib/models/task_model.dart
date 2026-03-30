import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { open, accepted, inProgress, completed, verified, cancelled }
enum TaskCategory { emergencyResponse, cleanupRecovery, reliefDistribution, medicalAssistance, preparedness, other }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String barangay;
  final String city;
  final TaskCategory category;
  final List<String> tags;
  final int points;
  final int volunteersNeeded;
  final int volunteersAccepted;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final TaskStatus status;
  final String createdBy;
  final String? acceptedBy;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final String? imageUrl;
  final bool isUrgent;
  final double? latitude;
  final double? longitude;
  final String? verificationNote;
  final List<String> verificationPhotos;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.barangay,
    required this.city,
    required this.category,
    this.tags = const [],
    required this.points,
    this.volunteersNeeded = 1,
    this.volunteersAccepted = 0,
    required this.scheduledStart,
    required this.scheduledEnd,
    this.status = TaskStatus.open,
    required this.createdBy,
    this.acceptedBy,
    this.acceptedAt,
    this.completedAt,
    this.imageUrl,
    this.isUrgent = false,
    this.latitude,
    this.longitude,
    this.verificationNote,
    this.verificationPhotos = const [],
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      barangay: d['barangay'] ?? '',
      city: d['city'] ?? '',
      category: _categoryFromString(d['category']),
      tags: List<String>.from(d['tags'] ?? []),
      points: d['points'] ?? 0,
      volunteersNeeded: d['volunteersNeeded'] ?? 1,
      volunteersAccepted: d['volunteersAccepted'] ?? 0,
      scheduledStart: (d['scheduledStart'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledEnd: (d['scheduledEnd'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(hours: 2)),
      status: _statusFromString(d['status']),
      createdBy: d['createdBy'] ?? '',
      acceptedBy: d['acceptedBy'],
      acceptedAt: (d['acceptedAt'] as Timestamp?)?.toDate(),
      completedAt: (d['completedAt'] as Timestamp?)?.toDate(),
      imageUrl: d['imageUrl'],
      isUrgent: d['isUrgent'] ?? false,
      latitude: (d['latitude'] as num?)?.toDouble(),
      longitude: (d['longitude'] as num?)?.toDouble(),
      verificationNote: d['verificationNote'],
      verificationPhotos: List<String>.from(d['verificationPhotos'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'barangay': barangay,
        'city': city,
        'category': category.name,
        'tags': tags,
        'points': points,
        'volunteersNeeded': volunteersNeeded,
        'volunteersAccepted': volunteersAccepted,
        'scheduledStart': Timestamp.fromDate(scheduledStart),
        'scheduledEnd': Timestamp.fromDate(scheduledEnd),
        'status': status.name,
        'createdBy': createdBy,
        'acceptedBy': acceptedBy,
        'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
        'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
        'imageUrl': imageUrl,
        'isUrgent': isUrgent,
        'latitude': latitude,
        'longitude': longitude,
        'verificationNote': verificationNote,
        'verificationPhotos': verificationPhotos,
      };

  static TaskStatus _statusFromString(String? s) {
    switch (s) {
      case 'accepted': return TaskStatus.accepted;
      case 'inProgress': return TaskStatus.inProgress;
      case 'completed': return TaskStatus.completed;
      case 'verified': return TaskStatus.verified;
      case 'cancelled': return TaskStatus.cancelled;
      default: return TaskStatus.open;
    }
  }

  static TaskCategory _categoryFromString(String? s) {
    switch (s) {
      case 'cleanupRecovery': return TaskCategory.cleanupRecovery;
      case 'reliefDistribution': return TaskCategory.reliefDistribution;
      case 'medicalAssistance': return TaskCategory.medicalAssistance;
      case 'preparedness': return TaskCategory.preparedness;
      case 'other': return TaskCategory.other;
      default: return TaskCategory.emergencyResponse;
    }
  }

  String get categoryLabel {
    switch (category) {
      case TaskCategory.emergencyResponse: return 'Emergency Response';
      case TaskCategory.cleanupRecovery: return 'Cleanup & Recovery';
      case TaskCategory.reliefDistribution: return 'Relief Distribution';
      case TaskCategory.medicalAssistance: return 'Medical Assistance';
      case TaskCategory.preparedness: return 'Preparedness';
      case TaskCategory.other: return 'Other';
    }
  }

  TaskModel copyWith({TaskStatus? status, String? acceptedBy, DateTime? acceptedAt, DateTime? completedAt, String? verificationNote, List<String>? verificationPhotos}) {
    return TaskModel(
      id: id, title: title, description: description,
      barangay: barangay, city: city, category: category, tags: tags,
      points: points, volunteersNeeded: volunteersNeeded, volunteersAccepted: volunteersAccepted,
      scheduledStart: scheduledStart, scheduledEnd: scheduledEnd,
      status: status ?? this.status,
      createdBy: createdBy,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      imageUrl: imageUrl, isUrgent: isUrgent,
      latitude: latitude, longitude: longitude,
      verificationNote: verificationNote ?? this.verificationNote,
      verificationPhotos: verificationPhotos ?? this.verificationPhotos,
    );
  }

  // ─── Mock data ─────────────────────────────────────────────────────────────
  static List<TaskModel> get mockTasks => [
    TaskModel(
      id: 'task_1',
      title: 'Medical Assistance for Injured Individuals',
      description: 'Provide first aid and medical support to flood victims in Brgy. Rizal. Volunteers with medical background preferred.',
      barangay: 'Brgy. Rizal', city: 'Iloilo City',
      category: TaskCategory.medicalAssistance,
      tags: const ['Injured People', 'Urgent', 'Medical'],
      points: 250, volunteersNeeded: 10, volunteersAccepted: 4,
      scheduledStart: DateTime(2026, 3, 21, 14, 0),
      scheduledEnd: DateTime(2026, 3, 21, 18, 0),
      createdBy: 'uid_admin', isUrgent: true,
      latitude: 10.7202, longitude: 122.5621,
    ),
    TaskModel(
      id: 'task_2',
      title: 'Debris Clearing – Brgy. San Pedro',
      description: 'Clear flood debris from main road and drainage canals to restore passage for relief vehicles.',
      barangay: 'Brgy. San Pedro', city: 'Iloilo City',
      category: TaskCategory.cleanupRecovery,
      tags: const ['Cleanup', 'Physical Work'],
      points: 150, volunteersNeeded: 20, volunteersAccepted: 12,
      scheduledStart: DateTime(2026, 3, 22, 8, 0),
      scheduledEnd: DateTime(2026, 3, 22, 12, 0),
      createdBy: 'uid_admin',
      latitude: 10.7180, longitude: 122.5600,
    ),
    TaskModel(
      id: 'task_3',
      title: 'Relief Pack Distribution – Evacuation Center',
      description: 'Sort and distribute food packs, hygiene kits, and clothing to displaced families.',
      barangay: 'Brgy. Molo', city: 'Iloilo City',
      category: TaskCategory.reliefDistribution,
      tags: const ['Relief', 'Food', 'Families'],
      points: 120, volunteersNeeded: 15, volunteersAccepted: 8,
      scheduledStart: DateTime(2026, 3, 23, 9, 0),
      scheduledEnd: DateTime(2026, 3, 23, 15, 0),
      createdBy: 'uid_admin',
    ),
  ];
}
