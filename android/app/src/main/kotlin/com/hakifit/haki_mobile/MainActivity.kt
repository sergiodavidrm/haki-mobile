package com.hakifit.haki_mobile

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Intent
import androidx.core.content.FileProvider
import com.snap.creativekit.SnapCreative
import com.snap.creativekit.api.SnapCreativeKitCompletionCallback
import com.snap.creativekit.api.SnapCreativeKitSendError
import com.snap.creativekit.models.SnapLiveCameraContent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Compartir un sticker a la cámara de Snapchat (Creative Kit, SDK oficial):
        // lib/features/share/data/snapchat_share.dart
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "haki/snapchat")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isInstalled" -> result.success(isSnapchatInstalled())
                    "shareSticker" -> try {
                        shareSticker(
                            path = call.argument<String>("path")!!,
                            widthDp = call.argument<Int>("widthDp") ?: 240,
                            heightDp = call.argument<Int>("heightDp") ?: 240,
                            withSticker = call.argument<Boolean>("withSticker") ?: true,
                            result = result,
                        )
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
        val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", File(path))
        val clip = ClipData.newUri(contentResolver, "Haki", uri)
        (getSystemService(CLIPBOARD_SERVICE) as ClipboardManager).setPrimaryClip(clip)
    }

    private fun isSnapchatInstalled(): Boolean = try {
        packageManager.getPackageInfo(SNAPCHAT, 0)
        true
    } catch (e: Exception) {
        false
    }

    // Abre la cámara de Snapchat con el sticker encima ("Share to Camera") con
    // el SDK oficial de Creative Kit (Client ID del manifest). Responde a Flutter
    // cuando Snapchat abrió o con el motivo del error.
    private fun shareSticker(path: String, widthDp: Int, heightDp: Int, withSticker: Boolean, result: MethodChannel.Result) {
        val api = SnapCreative.getApi(this)
        val content = SnapLiveCameraContent()
        if (withSticker) {
            val sticker = SnapCreative.getMediaFactory(this).getSnapStickerFromFile(File(path))
            sticker.setWidthDp(widthDp.toFloat())
            sticker.setHeightDp(heightDp.toFloat())
            sticker.setPosX(0.5f)
            sticker.setPosY(0.5f)
            content.setSnapSticker(sticker)
        }
        api.sendWithCompletionHandler(content, object : SnapCreativeKitCompletionCallback {
            override fun onSendSuccess() = result.success(true)
            override fun onSendFailed(error: SnapCreativeKitSendError) =
                result.error("snapchat", error.name, null)
        })
    }

    companion object {
        private const val SNAPCHAT = "com.snapchat.android"
    }
}
