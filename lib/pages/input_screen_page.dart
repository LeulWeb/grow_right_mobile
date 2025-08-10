import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:grow_right_mobile/models/tflite_model.dart';
import 'package:grow_right_mobile/utils/show_snackbar.dart';
import 'package:grow_right_mobile/widgets/icon_builder_widget.dart';
import 'package:grow_right_mobile/models/finding_result_model.dart';

class InputScreen extends StatefulWidget {
  final TfliteModel scanner;
  const InputScreen({super.key, required this.scanner});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  File? image;
  bool isLoading = false;
  bool isModelInitialized = false;
  Interpreter? interpreter;
  List<String>? labels;

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Future<void> initTflite() async {
    try {
      Logger().d(
        "Loading model: ${widget.scanner.modelPath}, labels: ${widget.scanner.labelPath}",
      );
      // Load the model from assets
      interpreter = await Interpreter.fromAsset(widget.scanner.modelPath);
      // Load labels (assuming labels are stored in a text file)
      final labelData = await DefaultAssetBundle.of(
        context,
      ).loadString(widget.scanner.labelPath);
      labels = labelData.split('\n').where((line) => line.isNotEmpty).toList();
      Logger().i("Model and labels loaded successfully. Labels: $labels");
      setState(() {
        isModelInitialized = true;
      });
    } catch (e) {
      Logger().e("Failed to load model or labels: $e");
      setState(() {
        isModelInitialized = false;
      });
      if (mounted) {
        showSnackBar(context, "Failed to load model or labels: $e", Colors.red);
      }
    }
  }

  Future<List<double>> _preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception("Failed to decode image");

    const w = 224, h = 224;
    final resized = img.copyResize(decoded, width: w, height: h);

    // Force RGB byte order (3 channels)
    final rgb = resized.getBytes(order: img.ChannelOrder.rgb); // length = w*h*3

    // Normalize to [0,1]
    return List<double>.generate(rgb.length, (i) => rgb[i] / 255.0);
  }

  Future<List<dynamic>?> scanImage(String imagePath) async {
    if (!isModelInitialized || interpreter == null || labels == null) {
      showSnackBar(
        context,
        "Model not initialized. Please try again.",
        Colors.red,
      );
      return null;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Preprocess image
      final inputData = await _preprocessImage(File(imagePath));

      // Prepare input tensor [1, 224, 224, 3]
      final input = List.generate(
        1,
        (_) => List.generate(
          224,
          (_) => List.generate(224, (_) => List.filled(3, 0.0)),
        ),
      );
      int pixelIndex = 0;
      for (int i = 0; i < 224; i++) {
        for (int j = 0; j < 224; j++) {
          input[0][i][j][0] = inputData[pixelIndex++]; // Red
          input[0][i][j][1] = inputData[pixelIndex++]; // Green
          input[0][i][j][2] = inputData[pixelIndex++]; // Blue
        }
      }

      // Prepare output tensor [1, numClasses]
      final output = List.filled(
        1 * labels!.length,
        0.0,
      ).reshape([1, labels!.length]);

      // Run inference
      interpreter!.run(input, output);

      // Process output
      final confidence = output[0].map((e) => e.toDouble()).toList();
      Logger().d("Output tensor: $confidence");
      final maxIndex = confidence.indexOf(
        confidence.reduce((a, b) => a > b ? a : b),
      );
      final resultLabel = labels![maxIndex];
      final confidenceScore = (confidence[maxIndex] * 100).toStringAsFixed(4);

      // Create FindingResultModel
      final result = FindingResultModel(
        confidence: "$confidenceScore%",
        disease: widget.scanner.disease,
        resultLabel: resultLabel,
        scannedImage: image!, // Pass file path as string
        createdAt: DateTime.now().toIso8601String(),
      );

      // Push result to scanResult screen
      if (mounted) {
        context.push('/scanResult', extra: result);
      }
    } catch (e) {
      Logger().e("Inference failed: $e");
      if (mounted) {
        showSnackBar(context, "Inference failed: $e", Colors.red);
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    // Delay initTflite to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initTflite();
    });
  }

  @override
  void dispose() {
    interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      context.pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconBuilderWidget(
                            icon:
                                '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="currentColor" d="M19 11H7.14l3.63-4.36a1 1 0 1 0-1.54-1.28l-5 6a1 1 0 0 0-.09.15c0 .05 0 .08-.07.13A1 1 0 0 0 4 12a1 1 0 0 0 .07.36c0 .05 0 .08.07.13a1 1 0 0 0 .09.15l5 6A1 1 0 0 0 10 19a1 1 0 0 0 .64-.23a1 1 0 0 0 .13-1.41L7.14 13H19a1 1 0 0 0 0-2"/></svg>',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.scanner.disease,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: image == null
                        ? Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: SvgPicture.string(
                              '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><g fill="none"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M20.33 17.657c.11-.366.17-.755.17-1.157v-9a4 4 0 0 0-4-4h-9a4 4 0 0 0-4 4v9.07m16.83 1.087l-.088-.104l-2.466-2.976a2 2 0 0 0-3.073-.008l-1.312 1.566l-.214.261m7.153 1.26a4 4 0 0 1-3.713 2.842m0 0l-.117.002h-9a4 4 0 0 1-4-3.93m13.117 3.928l-.093-.106l-3.347-3.996m-9.676.175l.177-.201l3.206-3.827a2 2 0 0 1 3.066 0l3.227 3.853"/><circle cx="15.091" cy="8.909" r="1.5" fill="currentColor"/></g></svg>',
                              width: 64,
                              color: Colors.grey[600],
                            ),
                          )
                        : Image.file(image!, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "This scan is for informational purposes only.",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          pickImage(ImageSource.gallery);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              IconBuilderWidget(
                                icon:
                                    '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-width="1.5"><path stroke-linecap="round" d="M22 13.438c0 3.77 0 5.656-1.172 6.828S17.771 21.438 14 21.438h-4c-3.771 0-5.657 0-6.828-1.172S2 17.209 2 13.438S2 7.78 3.172 6.609S6.229 5.438 10 5.438h4c3.771 0 5.657 0 6.828 1.171c.664.664.952 1.556 1.076 2.891"/><path d="M3.988 6c.112-.931.347-1.574.837-2.063C5.765 3 7.279 3 10.307 3h3.211c3.028 0 4.541 0 5.482.937c.49.489.725 1.132.837 2.063"/><circle cx="17.5" cy="9.938" r="1.5"/><path stroke-linecap="round" d="m2 13.938l1.752-1.533a2.3 2.3 0 0 1 3.14.105l4.29 4.29a2 2 0 0 0 2.564.221l.299-.21a3 3 0 0 1 3.731.226l3.224 2.9"/></g></svg>',
                              ),
                              const SizedBox(width: 12),
                              const Text("Pick from Gallery"),
                              const Spacer(),
                              IconBuilderWidget(
                                icon:
                                    '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="currentColor" d="M4 11v2h12l-5.5 5.5l1.42 1.42L19.84 12l-7.92-7.92L10.5 5.5L16 11z"/></svg>',
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          pickImage(ImageSource.camera);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              IconBuilderWidget(
                                icon:
                                    '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"><path d="M5.833 19.708h12.334a3.083 3.083 0 0 0 3.083-3.083V9.431a3.083 3.083 0 0 0-3.083-3.084h-1.419c-.408 0-.8-.163-1.09-.452l-1.15-1.151a1.54 1.54 0 0 0-1.09-.452h-2.836c-.41 0-.8.163-1.09.452l-1.15 1.151c-.29.29-.682.452-1.09.452H5.833A3.083 3.083 0 0 0 2.75 9.431v7.194a3.083 3.083 0 0 0 3.083 3.083"/><path d="M12 16.625a4.111 4.111 0 1 0 0-8.222a4.111 4.111 0 0 0 0 8.222"/></g></svg>',
                              ),
                              const SizedBox(width: 12),
                              const Text("Take Photo"),
                              const Spacer(),
                              IconBuilderWidget(
                                icon:
                                    '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="currentColor" d="M4 11v2h12l-5.5 5.5l1.42 1.42L19.84 12l-7.92-7.92L10.5 5.5L16 11z"/></svg>',
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: isLoading || !isModelInitialized
                  ? null
                  : () {
                      if (image == null) {
                        showSnackBar(context, "No image selected", Colors.red);
                        return;
                      }
                      scanImage(image!.path);
                    },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isModelInitialized
                      ? Theme.of(context).primaryColor
                      : Colors.grey, // Disable button color if not initialized
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isLoading ? "Loading..." : "Scan for Disease",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
