package com.hakifit.haki_mobile

import android.app.PendingIntent
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.File

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Compartir un sticker a la cámara de Snapchat (Creative Kit, sin SDK):
        // lib/features/share/data/snapchat_share.dart
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "haki/snapchat")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isInstalled" -> result.success(isSnapchatInstalled())
                    "shareSticker" -> try {
                        shareSticker(
                            path = call.argument<String>("path")!!,
                            clientId = call.argument<String>("clientId")!!,
                            appName = call.argument<String>("appName") ?: "Haki",
                            widthDp = call.argument<Int>("widthDp") ?: 240,
                            heightDp = call.argument<Int>("heightDp") ?: 240,
                            withSticker = call.argument<Boolean>("withSticker") ?: true,
                        )
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("snapchat", e.message, null)
                    }
                    else -> result.notImplemented()
                }
            }
        // Copiar el sticker como imagen (pegarlo en una historia de Instagram)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "haki/clipboard")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "copyImage" -> try {
                        copyImage(call.argument<String>("path")!!)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("clipboard", e.message, null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun copyImage(path: String) {
        val uri = FileProvider.getUriForFile(this, "$packageName.haki_share", File(path))
        val clip = ClipData.newUri(contentResolver, "Haki", uri)
        (getSystemService(CLIPBOARD_SERVICE) as ClipboardManager).setPrimaryClip(clip)
    }

    private fun isSnapchatInstalled(): Boolean = try {
        packageManager.getPackageInfo(SNAPCHAT, 0)
        true
    } catch (e: Exception) {
        false
    }

    // Abre la cámara de Snapchat con el sticker encima ("Share to Camera"):
    // https://github.com/Snapchat/creative-kit
    private fun shareSticker(path: String, clientId: String, appName: String, widthDp: Int, heightDp: Int, withSticker: Boolean) {
        val uri = FileProvider.getUriForFile(this, "$packageName.haki_share", File(path))
        grantUriPermission(SNAPCHAT, uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)

        val back = PendingIntent.getActivity(
            this, 0, Intent(this, MainActivity::class.java),
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_IMMUTABLE
            else PendingIntent.FLAG_ONE_SHOT,
        )
        val sticker = JSONObject()
            .put("uri", uri.toString())
            .put("posX", 0.5)
            .put("posY", 0.5)
            .put("rotation", 0)
            .put("widthDp", widthDp)
            .put("heightDp", heightDp)

        val intent = Intent(Intent.ACTION_SEND).apply {
            setPackage(SNAPCHAT)
            setDataAndType(Uri.parse("snapchat://creativekit/camera"), "*/*")
            putExtra("CLIENT_ID", clientId)
            putExtra("CLIENT_APP_NAME", appName)
            putExtra("RESULT_INTENT_EXTRA", back)
            // Sin sticker = solo la cámara (prueba para separar config de imagen)
            if (withSticker) putExtra("sticker", sticker.toString())
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivity(intent)
    }

    companion object {
        private const val SNAPCHAT = "com.snapchat.android"
    }
}
