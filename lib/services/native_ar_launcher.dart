import 'dart:io';

import 'package:flutter/services.dart';

class NativeArModel {
  final String label;
  final String assetPath;
  final double scaleToUnits;

  const NativeArModel({
    required this.label,
    required this.assetPath,
    this.scaleToUnits = 0.35,
  });

  Map<String, Object> toJson() => {
    'label': label,
    'assetPath': assetPath,
    'scaleToUnits': scaleToUnits,
  };
}

class NativeArLauncher {
  static const MethodChannel _channel = MethodChannel('world_casa/native_ar');

  static const List<NativeArModel> defaultModels = [
    NativeArModel(label: 'Duck', assetPath: 'assets/glb_models/Duck.glb'),
    NativeArModel(
      label: 'Chair',
      assetPath: 'assets/glb_models/b1_transformed.glb',
    ),
    NativeArModel(
      label: 'WRC v3',
      assetPath: 'assets/glb_models/WRC1025-808E_v3-transformed.glb',
    ),
    NativeArModel(
      label: 'WRC v4',
      assetPath: 'assets/glb_models/WRC1025-808E_v4-transformed.glb',
    ),
  ];

  static Future<void> open({List<NativeArModel> models = defaultModels}) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError(
        'Native ARCore view is only available on Android.',
      );
    }

    await _channel.invokeMethod<void>('openAR', {
      'models': models.map((model) => model.toJson()).toList(),
    });
  }
}
