import 'package:grow_right_mobile/models/tflite_model.dart';

List<TfliteModel> scannerList = [
  const TfliteModel(
    disease: "Coffee Detection",
    modelPath: "assets/tflite_models/coffee_model/coffee_model.tflite",
    labelPath: "assets/tflite_models/coffee_model/labels.txt",
    accuracy: "90",
  ),

  const TfliteModel(
    disease: "Mango Detection",
    modelPath: "assets/tflite_models/mango_model/model_unquant.tflite",
    labelPath: "assets/tflite_models/mango_model/labels.txt",
    accuracy: "94",
  ),

  const TfliteModel(
    disease: "Wheat Detection",
    modelPath: "assets/tflite_models/Wheat_model/Wheat_model.tflite",
    labelPath: "assets/tflite_models/Wheat_model/labels.txt",
    accuracy: "90",
  ),

];
