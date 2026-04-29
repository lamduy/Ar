import 'package:ar_flutter_plugin_2/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_2/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:world_casa/model/ar_model.dart';
import 'package:world_casa/view_model/ar_view_model.dart';

class ARScreen extends StatefulWidget {
  const ARScreen({super.key});

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  final ARViewModel _viewModel = ARViewModel();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  late Future<bool> _permissionFuture;

  @override
  void initState() {
    super.initState();
    _permissionFuture = _requestPermissions();
  }

  Future<bool> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    debugPrint('Camera permission status: $cameraStatus');
    return cameraStatus.isGranted;
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _viewModel.disposeSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR World Casa'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<bool>(
        future: _permissionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!) {
            return _buildPermissionErrorUI();
          }

          return Stack(
            children: [
              Positioned.fill(
                child: _viewModel.isSupported
                    ? ARView(
                        onARViewCreated: (sm, om, am, lm) {
                          debugPrint(
                            'ARView created - SM: ${sm != null}, OM: ${om != null}, AM: ${am != null}',
                          );
                          try {
                            if (sm != null && om != null && am != null) {
                              _viewModel.onARViewCreated(sm, om, am);
                            } else {
                              debugPrint('❌ Managers are null!');
                              _viewModel.handleManagersNull();
                            }
                          } catch (e, stackTrace) {
                            debugPrint('❌ Error in onARViewCreated: $e');
                            debugPrint('Stack trace: $stackTrace');
                            _viewModel.errorMessage =
                                'Failed to initialize AR: $e';
                            _viewModel.isSupported = false;
                            _viewModel.notifyListeners();
                          }
                        },
                        planeDetectionConfig: PlaneDetectionConfig.horizontal,
                      )
                    : _buildErrorUI(),
              ),
              // Scanning status overlay
              if (_viewModel.isSupported)
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Scanning face...',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Drag the camera to find a flat surface and tap to place.',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              _buildModelPicker(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPermissionErrorUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 60, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            'Quyền truy cập Camera bị từ chối',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'AR World Casa cần quyền truy cập camera để hoạt động. Vui lòng cấp quyền trong cài đặt.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
            },
            child: const Text('Mở cài đặt'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quay lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildModelPicker() {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.05,
      minChildSize: 0.05,
      maxChildSize: 0.7,
      snap: true,
      snapSizes: const [0.15, 0.45, 0.7],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 5),
            ],
          ),
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, child) {
              return CustomScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const Text(
                          'Choose a model to place',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.8,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final model = _viewModel.modelOptions[index];
                        final isSelected = _viewModel.selectedModel == model;
                        return _buildProductCard(model, isSelected, index);
                      }, childCount: _viewModel.modelOptions.length),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductCard(ModelOption model, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => _viewModel.selectModel(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chair, size: 40, color: Colors.blueGrey),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                model.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Không thể khởi tạo AR',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _viewModel.errorMessage.isEmpty
                    ? 'Thiết bị của bạn có thể không hỗ trợ AR hoặc ARCore chưa được cài đặt. Vui lòng cập nhật Google Play Services.'
                    : _viewModel.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => {
                Navigator.pop(context),
                _viewModel.disposeSession(),
              },
              child: const Text('Quay lại'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _permissionFuture = _requestPermissions();
                });
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}


