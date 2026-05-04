package com.example.world_casa

import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "world_casa/native_ar"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openAR" -> {
                    val modelsJson = JSONArray()
                    val models = call.argument<List<Map<String, Any>>>("models").orEmpty()
                    models.forEach { model ->
                        modelsJson.put(JSONObject().apply {
                            put("label", model["label"] as? String ?: "Model")
                            put("assetPath", model["assetPath"] as? String ?: "assets/glb_models/Duck.glb")
                            put("scaleToUnits", (model["scaleToUnits"] as? Number)?.toDouble() ?: 0.35)
                        })
                    }
                    val intent = Intent(this, NativeArActivity::class.java).apply {
                        putExtra(NativeArActivity.EXTRA_MODELS_JSON, modelsJson.toString())
                    }
                    startActivity(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
