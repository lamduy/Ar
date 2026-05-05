package com.example.world_casa

import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.view.Gravity
import android.view.MotionEvent
import android.widget.*
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.lifecycleScope
import com.google.ar.core.*
import io.flutter.FlutterInjector
import io.github.sceneview.ar.ARSceneView
import io.github.sceneview.ar.node.AnchorNode
import io.github.sceneview.math.Scale
import io.github.sceneview.node.ModelNode
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONArray
import androidx.appcompat.app.AppCompatActivity
class NativeArActivity : AppCompatActivity() {

    private lateinit var sceneView: ARSceneView
    private lateinit var statusText: TextView
    private lateinit var pickerRow: LinearLayout

    private var placedNodes = 0
    private val maxPlacedNodes = 3

    private lateinit var models: List<NativeArModel>
    private var selectedModelIndex = 0

    private val selectedModel: NativeArModel
        get() = models.getOrElse(selectedModelIndex) { models.first() }

    companion object {
        const val EXTRA_MODELS_JSON = "modelsJson"
        private const val CAMERA_PERMISSION_REQUEST_CODE = 100
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (!hasCameraPermission()) {
            requestCameraPermission()
        } else {
            initializeArScene()
        }
    }

    // ================= PERMISSION =================

    private fun hasCameraPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            android.Manifest.permission.CAMERA
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestCameraPermission() {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(android.Manifest.permission.CAMERA),
            CAMERA_PERMISSION_REQUEST_CODE
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == CAMERA_PERMISSION_REQUEST_CODE &&
            grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        ) {
            initializeArScene()
        } else {
            Toast.makeText(this, "Camera permission required", Toast.LENGTH_LONG).show()
            finish()
        }
    }

    // ================= INIT =================

    private fun initializeArScene() {
        models = parseModels(intent.getStringExtra(EXTRA_MODELS_JSON))

        sceneView = ARSceneView(this).apply {
            sessionConfiguration = { _, config ->
                config.planeFindingMode = Config.PlaneFindingMode.HORIZONTAL
                config.lightEstimationMode = Config.LightEstimationMode.ENVIRONMENTAL_HDR
                config.focusMode = Config.FocusMode.AUTO
            }
        }

       // lifecycle.addObserver(sceneView)

        setupUI()

        sceneView.post {
            if (!isFinishing) {
                setupArListeners()
            }
        }
    }

    private fun setupUI() {
        statusText = TextView(this).apply {
            setTextColor(0xFFFFFFFF.toInt())
            setBackgroundColor(0x99000000.toInt())
            setPadding(28, 16, 28, 16)
            text = "Initializing AR..."
        }

        pickerRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(24, 18, 24, 18)
        }

        val pickerScroll = HorizontalScrollView(this).apply {
            isHorizontalScrollBarEnabled = false
            setBackgroundColor(0xCCFFFFFF.toInt())
            addView(pickerRow)
        }

        val root = FrameLayout(this).apply {
            addView(sceneView)
            addView(statusText, FrameLayout.LayoutParams(-2, -2,
                Gravity.TOP or Gravity.CENTER_HORIZONTAL).apply { topMargin = 48 })

            addView(pickerScroll, FrameLayout.LayoutParams(-1, -2, Gravity.BOTTOM))
        }

        setContentView(root)
    }

    // ================= AR =================

    private fun setupArListeners() {
        sceneView.planeRenderer.isVisible = true
        sceneView.planeRenderer.isEnabled = true

        sceneView.onTrackingFailureChanged = { reason ->
            when (reason) {
                null -> showStatus("${selectedModel.label} selected. Tap a plane to place.")
                TrackingFailureReason.INSUFFICIENT_LIGHT -> showStatus("Too dark", true)
                TrackingFailureReason.EXCESSIVE_MOTION -> showStatus("Move slower", true)
                TrackingFailureReason.INSUFFICIENT_FEATURES -> showStatus("Point camera at textured surface", true)
                else -> showStatus("Tracking issue: ${reason.name}", true)
            }
        }

        sceneView.setOnGestureListener(
            onSingleTapConfirmed = { motionEvent: MotionEvent, node ->
                if (node == null) {
                    placeModelOnPlane(motionEvent)
                }
                true
            }
        )

        renderModelPicker()
    }

    private fun placeModelOnPlane(motionEvent: MotionEvent) {

        if (sceneView.cameraNode.trackingState != TrackingState.TRACKING) {
            showStatus("Move device to detect surface")
            return
        }

        if (placedNodes >= maxPlacedNodes) {
            showStatus("Limit reached!", true)
            return
        }

        val frame = sceneView.frame ?: return

        val hitResult = frame.hitTest(motionEvent).firstOrNull { hit ->
            val trackable = hit.trackable
            trackable is Plane && trackable.trackingState == TrackingState.TRACKING
        } ?: return

        val model = selectedModel

        val modelAssetKey = FlutterInjector.instance()
            .flutterLoader()
            .getLookupKeyForAsset(model.assetPath)

        lifecycleScope.launch {
            try {
                val modelInstance = withContext(Dispatchers.IO) {
                    sceneView.modelLoader.loadModelInstance(modelAssetKey)
                }

                modelInstance?.let {
                    val anchorNode = AnchorNode(sceneView.engine, hitResult.createAnchor())

                    val modelNode = ModelNode(modelInstance = it)
                    val s = model.scaleToUnits
                    modelNode.scale = Scale(s, s, s)

                    anchorNode.addChildNode(modelNode)
                    sceneView.addChildNode(anchorNode)

                    placedNodes++
                    showStatus("${model.label} placed!")
                }

            } catch (e: Exception) {
                showStatus("Error: ${e.message}", true)
            }
        }
    }

    // ================= UI =================

    private fun renderModelPicker() {
        pickerRow.removeAllViews()

        models.forEachIndexed { index, model ->
            pickerRow.addView(
                TextView(this).apply {
                    text = model.label
                    textSize = 14f
                    gravity = Gravity.CENTER
                    setPadding(28, 18, 28, 18)

                    setTextColor(
                        if (index == selectedModelIndex) 0xFFFFFFFF.toInt()
                        else 0xFF222222.toInt()
                    )

                    setBackgroundColor(
                        if (index == selectedModelIndex) 0xFF1E5EFF.toInt()
                        else 0xFFE9ECF2.toInt()
                    )

                    setOnClickListener {
                        selectedModelIndex = index
                        renderModelPicker()
                        showStatus("${model.label} selected")
                    }
                },
                LinearLayout.LayoutParams(-2, -2).apply {
                    rightMargin = 14
                }
            )
        }
    }

    private fun showStatus(message: String, isError: Boolean = false) {
        statusText.text = message
        statusText.setBackgroundColor(
            if (isError) 0xCCB00020.toInt()
            else 0x99000000.toInt()
        )
    }

    // ================= CLEANUP =================

    override fun onDestroy() {
        if (::sceneView.isInitialized) {
            try {
                sceneView.destroy()
            } catch (_: Exception) {}
        }
        super.onDestroy()
    }

    // ================= MODEL =================

    private data class NativeArModel(
        val label: String,
        val assetPath: String,
        val scaleToUnits: Float
    )

    private fun parseModels(modelsJson: String?): List<NativeArModel> {
        val fallback = listOf(
            NativeArModel("Duck", "assets/glb_models/Duck.glb", 0.35f)
        )

        if (modelsJson.isNullOrBlank()) return fallback

        return try {
            val array = JSONArray(modelsJson)
            List(array.length()) { index ->
                val item = array.getJSONObject(index)
                NativeArModel(
                    label = item.optString("label", "Model ${index + 1}"),
                    assetPath = item.optString("assetPath", fallback[0].assetPath),
                    scaleToUnits = item.optDouble("scaleToUnits", 0.35).toFloat()
                )
            }.ifEmpty { fallback }
        } catch (_: Exception) {
            fallback
        }
    }
}