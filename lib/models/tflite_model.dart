class TfliteModel {
  final String disease;
  final String modelPath;
  final String labelPath;
  final String accuracy;

  const TfliteModel({
    required this.labelPath,
    required this.disease,
    required this.modelPath,
    required this.accuracy,
  });
}
