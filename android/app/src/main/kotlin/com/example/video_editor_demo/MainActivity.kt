package com.example.video_editor_demo


import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.MediaStore
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.video_editor_demo/media"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "scanFile") {
                val filePath = call.argument<String>("path")
                scanFile(filePath)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun scanFile(filePath: String?) {
        val mediaScanIntent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
        val fileUri: Uri = Uri.fromFile(File(filePath))
        mediaScanIntent.data = fileUri
        sendBroadcast(mediaScanIntent)
    }
}
