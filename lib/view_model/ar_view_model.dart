import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:world_casa/model/ar_model.dart';

class ARViewModel extends ChangeNotifier {
  // Quản lý các Manager
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  // Trạng thái dữ liệu
  final List<ARPlaneAnchor> _anchors = [];
  final List<ARNode> _nodes = [];
  int _selectedModelIndex = 0;
  bool _isDisposed = false;
  bool isSupported = true;
  String errorMessage = "";
  int planesDetected = 0;
  bool arSessionReady = false;

  // Danh sách model (Dữ liệu này có thể lấy từ Repository)
  final List<ModelOption> modelOptions = const [
    ModelOption(
      label: 'Model 3',
      assetPath: 'assets/glb_models/b1-transformed.glb',
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

    // Validate managers are not null
    if (sessionManager == null ||
        objectManager == null ||
        anchorManager == null) {
      handleManagersNull();
      return;
    }

    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;

    try {
      debugPrint('Initializing AR Session...');

      // Check if session manager is ready
      if (arSessionManager == null) {
        throw Exception('ARSessionManager is null after onARViewCreated');
      }

      // Initialize AR Session with feature point and plane detection enabled
      await arSessionManager!.onInitialize(
        showAnimatedGuide: true,
        showPlanes: true,
        showFeaturePoints: true,
        showWorldOrigin: false,
        handleTaps: true,
      );
      debugPrint('✅ AR Session initialized successfully');

      // Add small delay to ensure rendering is set up
      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize Object Manager
      if (arObjectManager == null) {
        throw Exception('ARObjectManager is null');
      }
      debugPrint('Initializing AR Object Manager...');
      await arObjectManager!.onInitialize();
      debugPrint('✅ AR Object Manager initialized successfully');

      // Set up tap handler
      arSessionManager?.onPlaneOrPointTap = handlePlaneTap;
      isSupported = true;
      arSessionReady = true;
      errorMessage = "";
      notifyListeners();
      debugPrint('✅ AR initialization complete - Ready to detect planes');
      debugPrint('📍 Feature Points: ENABLED');
      debugPrint('📐 Plane Detection: ENABLED (Horizontal & Vertical)');
    } on Exception catch (e, stackTrace) {
      isSupported = false;
      errorMessage = "AR Session creation failed: ${e.toString()}";
      debugPrint('❌ AR initialization error: $errorMessage');
      debugPrint('Stack trace: $stackTrace');
      notifyListeners();
    } catch (e, stackTrace) {
      isSupported = false;
      errorMessage = "Unexpected error during AR initialization: $e";
      debugPrint('❌ Unexpected error: $errorMessage');
      debugPrint('Stack trace: $stackTrace');
      notifyListeners();
    }
  }

  /// Handle case when AR managers are null
  void handleManagersNull() {
    isSupported = false;
    errorMessage =
        "Failed to initialize AR session. Please check if the device supports ARCore and permissions are granted.";
    debugPrint('AR Managers are null: $errorMessage');
    notifyListeners();
  }

  Future<void> handlePlaneTap(List<ARHitTestResult> hitTestResults) async {
    if (_isDisposed) return;

    debugPrint(
      '🎯 Plane tap detected! Results count: ${hitTestResults.length}',
    );

    if (hitTestResults.isEmpty) {
      debugPrint('⚠️ No hit test results - tap on empty area');
      return;
    }

    planesDetected = hitTestResults.length;
    notifyListeners();

    final hit = hitTestResults.first;
    final anchor = ARPlaneAnchor(transformation: hit.worldTransform);

    try {
      debugPrint('Attempting to add anchor...');
      bool? didAddAnchor = await arAnchorManager?.addAnchor(anchor);
      if (didAddAnchor != true) {
        debugPrint('Failed to add anchor');
        return;
      }

      debugPrint(
        'Anchor added successfully. Creating node with model: ${selectedModel.assetPath}',
      );

      final node = ARNode(
        type: NodeType.localGLTF2,
        uri: selectedModel.assetPath,
        scale: vector.Vector3.all(selectedModel.scale),
        position: vector.Vector3.zero(),
        rotation: vector.Vector4(1, 0, 0, 0),
      );

      debugPrint('Node created. Attempting to add node to object manager...');
      bool? didAddNode = await arObjectManager?.addNode(
        node,
        planeAnchor: anchor,
      );

      if (didAddNode == true) {
        debugPrint('Node added successfully');
        _anchors.add(anchor);
        _nodes.add(node);
        notifyListeners();
      } else {
        debugPrint('Failed to add node to object manager');
        await arAnchorManager?.removeAnchor(anchor);
      }
    } catch (e, stackTrace) {
      debugPrint('Error in handlePlaneTap: $e');
      debugPrint('Stack trace: $stackTrace');
      errorMessage = "Failed to place model: $e";
      notifyListeners();

      // Clean up anchor if it was added but node failed
      try {
        await arAnchorManager?.removeAnchor(anchor);
      } catch (cleanupError) {
        debugPrint('Error cleaning up anchor: $cleanupError');
      }
    }
  }

  void nextModel() {
    _selectedModelIndex = (_selectedModelIndex + 1) % modelOptions.length;
    notifyListeners(); // Thông báo UI cập nhật nếu cần
  }

  Future<void> disposeSession() async {
    arSessionManager?.onPlaneOrPointTap = (_) {};

    for (var node in List<ARNode>.from(_nodes)) {
      await arObjectManager?.removeNode(node);
    }
    _nodes.clear();

    for (var anchor in List<ARPlaneAnchor>.from(_anchors)) {
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
    // Best-effort cleanup while leaving Flutter dispose synchronous.
    disposeSession();
    super.dispose();
  }
}
