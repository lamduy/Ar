import 'dart:io';

import 'package:ar_flutter_plugin_2/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin_2/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_2/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_2/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_2/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin_2/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:world_casa/model/ar_model.dart';

class ARViewModel extends ChangeNotifier {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  final List<ARPlaneAnchor> _anchors = [];
  final List<ARNode> _nodes = [];
  int _selectedModelIndex = 0;
  bool _isDisposed = false;
  bool _isPlacingNode = false;
  bool isSupported = true;
  String errorMessage = '';
  int planesDetected = 0;
  bool arSessionReady = false;
  final Map<String, String> _glbAssetCache = {};

  final List<ModelOption> modelOptions = const [
    ModelOption(
      label: 'Model 3',
      assetPath: 'assets/glb_models/b1_transformed.glb',
      scale: 1,
    ),
  ];

  ModelOption get selectedModel => modelOptions[_selectedModelIndex];

  Future<void> onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
  ) async {
    if (_isDisposed) return;

    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;

    try {
      await arSessionManager!.onInitialize(
        showAnimatedGuide: true,
        showPlanes: true,
        showFeaturePoints: true,
        showWorldOrigin: false,
        handleTaps: true,
      );

      await arObjectManager!.onInitialize();

      // Preload selected model to avoid first-tap native crashes while loading.
      await _resolveNodeSource(selectedModel.assetPath);

      arSessionManager?.onPlaneOrPointTap = handlePlaneTap;
      isSupported = true;
      arSessionReady = true;
      errorMessage = '';
      notifyListeners();
    } on Exception catch (e, stackTrace) {
      isSupported = false;
      errorMessage = 'AR Session creation failed: ${e.toString()}';
      debugPrint('AR initialization error: $errorMessage');
      debugPrint('Stack trace: $stackTrace');
      notifyListeners();
    } catch (e, stackTrace) {
      isSupported = false;
      errorMessage = 'Unexpected error during AR initialization: $e';
      debugPrint('Unexpected error: $errorMessage');
      debugPrint('Stack trace: $stackTrace');
      notifyListeners();
    }
  }

  void handleManagersNull() {
    isSupported = false;
    errorMessage =
        'Failed to initialize AR session. Please check if the device supports ARCore and permissions are granted.';
    notifyListeners();
  }

  Future<void> handlePlaneTap(List<ARHitTestResult> hitTestResults) async {
    if (_isDisposed || _isPlacingNode) return;

    if (hitTestResults.isEmpty) {
      return;
    }

    ARHitTestResult? planeHit;
    ARHitTestResult? pointHit;
    for (final result in hitTestResults) {
      if (result.type == ARHitTestResultType.plane) {
        planeHit = result;
        break;
      }
      if (result.type == ARHitTestResultType.point && pointHit == null) {
        pointHit = result;
      }
    }
    final instantHit = planeHit ?? pointHit ?? hitTestResults.first;

    _isPlacingNode = true;
    planesDetected = hitTestResults.length;
    notifyListeners();
    ARPlaneAnchor? anchor;

    try {
      final (nodeType, nodeUri) = await _resolveNodeSource(
        selectedModel.assetPath,
      );
      bool? didAddNode;
      ARNode node;

      if (planeHit != null) {
        anchor = ARPlaneAnchor(transformation: planeHit.worldTransform);
        final didAddAnchor = await arAnchorManager?.addAnchor(anchor);
        if (didAddAnchor != true) {
          return;
        }

        node = ARNode(
          type: nodeType,
          uri: nodeUri,
          scale: vector.Vector3.all(selectedModel.scale),
          position: vector.Vector3.zero(),
          rotation: vector.Vector4(1, 0, 0, 0),
        );
        didAddNode = await arObjectManager?.addNode(node, planeAnchor: anchor);
      } else {
        // Instant placement: place immediately from hit transform without
        // waiting for a detected plane anchor.
        node = ARNode(
          type: nodeType,
          uri: nodeUri,
          scale: vector.Vector3.all(selectedModel.scale),
          transformation: instantHit.worldTransform,
        );
        didAddNode = await arObjectManager?.addNode(node);
      }

      if (didAddNode == true) {
        if (anchor != null) {
          _anchors.add(anchor);
        }
        _nodes.add(node);
        notifyListeners();
      } else if (anchor != null) {
        await arAnchorManager?.removeAnchor(anchor);
      }
    } catch (e, stackTrace) {
      debugPrint('Error in handlePlaneTap: $e');
      debugPrint('Stack trace: $stackTrace');
      errorMessage = 'Failed to place model: $e';
      notifyListeners();

      try {
        if (anchor != null) {
          await arAnchorManager?.removeAnchor(anchor);
        }
      } catch (_) {}
    } finally {
      _isPlacingNode = false;
    }
  }

  Future<(NodeType, String)> _resolveNodeSource(String assetPath) async {
    final isGlb = assetPath.toLowerCase().endsWith('.glb');
    if (!isGlb) {
      return (NodeType.localGLTF2, assetPath);
    }

    if (_glbAssetCache.containsKey(assetPath)) {
      return (NodeType.fileSystemAppFolderGLB, _glbAssetCache[assetPath]!);
    }

    final byteData = await rootBundle.load(assetPath);
    final directory = await getApplicationDocumentsDirectory();
    final fileName = assetPath.split('/').last;
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
      flush: true,
    );

    _glbAssetCache[assetPath] = fileName;
    return (NodeType.fileSystemAppFolderGLB, fileName);
  }

  void nextModel() {
    _selectedModelIndex = (_selectedModelIndex + 1) % modelOptions.length;
    notifyListeners();
  }

  Future<void> disposeSession() async {
    arSessionManager?.onPlaneOrPointTap = (_) {};

    for (final node in List<ARNode>.from(_nodes)) {
      await arObjectManager?.removeNode(node);
    }
    _nodes.clear();

    for (final anchor in List<ARPlaneAnchor>.from(_anchors)) {
      await arAnchorManager?.removeAnchor(anchor);
    }
    _anchors.clear();

    arSessionManager?.dispose();
    arSessionManager = null;
    arObjectManager = null;
    arAnchorManager = null;
  }

  void selectModel(int index) {
    _selectedModelIndex = index;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    disposeSession();
    super.dispose();
  }
}

