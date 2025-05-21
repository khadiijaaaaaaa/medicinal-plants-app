class IdentificationHistory {
  int? historyId;
  int? userId;
  int plantId;
  String imagePath;
  String? identificationDate;
  bool? wasToxic;

  IdentificationHistory({
    this.historyId,
    this.userId,
    required this.plantId,
    required this.imagePath,
    this.identificationDate,
    this.wasToxic,
  });

  Map<String, dynamic> toMap() {
    return {
      'history_id': historyId,
      'user_id': userId,
      'plant_id': plantId,
      'image_path': imagePath,
      'identification_date': identificationDate,
      'was_toxic': wasToxic != null ? (wasToxic! ? 1 : 0) : null,
    };
  }

  factory IdentificationHistory.fromMap(Map<String, dynamic> map) {
    return IdentificationHistory(
      historyId: map['history_id'],
      userId: map['user_id'],
      plantId: map['plant_id'],
      imagePath: map['image_path'],
      identificationDate: map['identification_date'],
      wasToxic: map['was_toxic'] == 1,
    );
  }
}