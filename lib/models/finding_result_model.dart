class FindingResultModel {
  final String disease;
  final String scannedImage;
  final String confidence;
  final String resultLabel;
  final String createdAt;

  FindingResultModel({
    required this.disease,
    required this.scannedImage,
    required this.confidence,
    required this.resultLabel,
    required this.createdAt,
  });

  // from json
  factory FindingResultModel.fromJson(Map<String, dynamic> json) {
    return FindingResultModel(
      disease: json['disease'],
      scannedImage: json['scanned_image'],
      confidence: json['confidence'],
      resultLabel: json['result_label'],
      createdAt: json['created_at'],
    );
  }

  // to string
  @override
  String toString() {
    return 'FindingResultModel(disease: $disease, scannedImage: $scannedImage, confidence: $confidence, resultLabel: $resultLabel, createdAt: $createdAt)';
  }
}
