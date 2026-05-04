package com.example.world_casa

import android.app.Activity
import android.os.Build
import android.os.Bundle
import android.view.Gravity
import android.view.MotionEvent
import android.widget.FrameLayout
import android.widget.HorizontalScrollView
import android.widget.LinearLayout
import android.widget.TextView
import com.google.ar.core.Config
import com.google.ar.core.Plane
import com.google.ar.core.TrackingState
import io.flutter.FlutterInjector
import io.github.sceneview.ar.ARSceneView
import io.github.sceneview.ar.node.AnchorNode
import io.github.sceneview.math.Scale
import io.github.sceneview.node.ModelNode
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import org.json.JSONArray

class NativeArActivity : Activity() {
    private lateinit var sceneView: ARSceneView
    private lateinit var statusText: TextView
    private lateinit var pickerRow: LinearLayout
    private val mainScope = CoroutineScope(Dispatchers.Main)
    private var placedNodes = 0
    private val maxPlacedNodes = 3
    private lateinit var models: List<NativeArModel>
    private var selectedModelIndex = 0

    private val selectedModel: NativeArModel
        get() = models[selectedModelIndex]

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        models = parseModels(intent.getStringExtra(EXTRA_MODELS_JSON))

        sceneView = ARSceneView(
            context = this,
            sessionConfiguration = { session, config ->
                config.apply {
                    planeFindingMode = Config.PlaneFindingMode.HORIZONTAL
                    lightEstimationMode = Config.LightEstimationMode.ENVIRONMENTAL_HDR
                    depthMode = when (session.isDepthModeSupported(Config.DepthMode.AUTOMATIC)) {
                        true -> Config.DepthMode.AUTOMATIC
                        false -> Config.DepthMode.DISABLED
                    }
                    focusMode = Config.FocusMode.AUTO
                }
            }
        )

        statusText = TextView(this).apply {
            setTextColor(0xFFFFFFFF.toInt())
            setBackgroundColor(0x99000000.toInt())
            setPadding(28, 16, 28, 16)
        }

        pickerRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(24, 18, 24, 18)
        }
        val pickerScroll = HorizontalScrollView(this).apply {
            isHorizontalScrollBarEnabled = false
            setBackgroundColor(0xCCFFFFFF.toInt())
            addView(
                pickerRow,
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.WRAP_CONTENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT
                )
            )
        }

        val root = FrameLayout(this).apply {
            addView(
                sceneView,
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT
                )
            )
            addView(
                statusText,
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.WRAP_CONTENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT,
                    Gravity.TOP or Gravity.CENTER_HORIZONTAL
                ).apply {
                    topMargin = 36
                    leftMargin = 24
                    rightMargin = 24
                }
            )
            addView(
                pickerScroll,
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT,
                    Gravity.BOTTOM
                )
            )
        }
        setContentView(root)

        renderModelPicker()
        showStatus(initialStatusMessage())

        sceneView.planeRenderer.isEnabled = true
        sceneView.planeRenderer.isVisible = true
        sceneView.onTrackingFailureChanged = { reason ->
            if (reason != null) {
                showStatus("AR tracking issue: ${reason.name}", isError = true)
            } else {
                showStatus("${selectedModel.label} selected. Tap a plane to place.")
            }
        }
        sceneView.setOnGestureListener(
            onSingleTapConfirmed = { motionEvent: MotionEvent, node ->
                if (node != null) {
                    true
                } else {
                    placeModelOnPlane(motionEvent)
                    true
                }
            }
        )
    }

    private fun initialStatusMessage(): String {
        val isEmulator = Build.FINGERPRINT.contains("generic") ||
            Build.MODEL.contains("Emulator") ||
            Build.MODEL.contains("sdk_gphone")

        return if (isEmulator) {
            "Emulator detected. Use an ARCore AVD with Camera Back = VirtualScene."
        } else {
            "${selectedModel.label} selected. Tap a plane to place."
        }
    }

    private fun placeModelOnPlane(motionEvent: MotionEvent) {
        if (placedNodes >= maxPlacedNodes) {
            showStatus("Too many objects. Restart AR to clear the scene.", isError = true)
            return
        }

        val frame = sceneView.frame ?: run {
            showStatus("AR frame is not ready yet.", isError = true)
            return
        }

        val planeHit = frame.hitTest(motionEvent).firstOrNull { hit ->
            val trackable = hit.trackable
            trackable is Plane &&
                trackable.trackingState == TrackingState.TRACKING &&
                trackable.isPoseInPolygon(hit.hitPose)
        } ?: run {
            showStatus("No tracked plane at this position.", isError = true)
            return
        }

        val model = selectedModel
        val modelAssetKey = FlutterInjector.instance()
            .flutterLoader()
            .getLookupKeyForAsset(model.assetPath)

        showStatus("Loading ${model.label}...")
        mainScope.launch {
            val modelInstance = sceneView.modelLoader.loadModelInstance(modelAssetKey)
                ?: run {
                    showStatus("Failed to load ${model.label}.", isError = true)
                    return@launch
                }

            val anchorNode = AnchorNode(sceneView.engine, planeHit.createAnchor())
            val modelNode = ModelNode(
                modelInstance = modelInstance,
                scaleToUnits = model.scaleToUnits
            ).apply {
                scale = Scale(1.0f)
            }

            anchorNode.addChildNode(modelNode)
            sceneView.addChildNode(anchorNode)
            placedNodes += 1
            showStatus("${model.label} placed. Tap another plane to add more.")
        }
    }

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
                        if (index == selectedModelIndex) 0xFFFFFFFF.toInt() else 0xFF222222.toInt()
                    )
                    setBackgroundColor(
                        if (index == selectedModelIndex) 0xFF1E5EFF.toInt() else 0xFFE9ECF2.toInt()
                    )
                    setOnClickListener {
                        selectedModelIndex = index
                        renderModelPicker()
                        showStatus("${model.label} selected. Tap a plane to place.")
                    }
                },
                LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    rightMargin = 14
                }
            )
        }
    }

    private fun showStatus(message: String, isError: Boolean = false) {
        statusText.text = message
        statusText.setBackgroundColor(
            if (isError) 0xCCB00020.toInt() else 0x99000000.toInt()
        )
    }

    override fun onDestroy() {
        mainScope.cancel()
        sceneView.destroy()
        super.onDestroy()
    }

    companion object {
        const val EXTRA_MODELS_JSON = "modelsJson"
    }

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
                    assetPath = item.optString("assetPath", "assets/glb_models/Duck.glb"),
                    scaleToUnits = item.optDouble("scaleToUnits", 0.35).toFloat()
                )
            }.ifEmpty { fallback }
        } catch (_: Exception) {
            fallback
        }
    }
}
