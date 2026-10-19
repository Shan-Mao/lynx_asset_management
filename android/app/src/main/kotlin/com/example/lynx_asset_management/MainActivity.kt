package com.example.lynx_asset_management

import android.app.WallpaperColors
import android.app.WallpaperManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL_NAME =
            "com.example.lynx_asset_management/wallpaper_colors"
    }

    private var channel: MethodChannel? = null
    private var colorsListener: WallpaperManager.OnColorsChangedListener? = null
    private val executor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val methodChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        channel = methodChannel
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getWallpaperColors" -> readWallpaperColors(result)
                else -> result.notImplemented()
            }
        }

        registerColorsListener()
    }

    /**
     * Reads the wallpaper colors from the system.
     *
     * This is deliberately different from [android.R.color.system_accent*]:
     * several Xiaomi HyperOS/MIUI builds never refresh those resources for
     * third-party apps and leave them at the AOSP default blue. The
     * WallpaperManager still reports the actual wallpaper colors, so we use
     * them as the seed for the Material 3 scheme on those devices.
     */
    private fun readWallpaperColors(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O_MR1) {
            result.success(null)
            return
        }

        val manager = WallpaperManager.getInstance(this)
        executor.execute {
            val payload = try {
                buildPayload(manager.getWallpaperColors(WallpaperManager.FLAG_SYSTEM))
            } catch (_: Throwable) {
                buildPayload(null)
            }
            runOnUiThread { result.success(payload) }
        }
    }

    private fun buildPayload(
        colors: WallpaperColors?,
    ): Map<String, Any?> = mapOf(
        "manufacturer" to Build.MANUFACTURER,
        "sdkInt" to Build.VERSION.SDK_INT,
        "colors" to colors?.let {
            listOfNotNull(
                it.primaryColor.toArgb(),
                it.secondaryColor?.toArgb(),
                it.tertiaryColor?.toArgb(),
            )
        },
    )

    private fun registerColorsListener() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O_MR1) return

        val listener = WallpaperManager.OnColorsChangedListener { colors, which ->
            if ((which and WallpaperManager.FLAG_SYSTEM) == 0) {
                return@OnColorsChangedListener
            }
            channel?.invokeMethod("wallpaperColorsChanged", buildPayload(colors))
        }
        colorsListener = listener
        WallpaperManager.getInstance(this)
            .addOnColorsChangedListener(listener, Handler(Looper.getMainLooper()))
    }

    override fun onDestroy() {
        colorsListener?.let { listener ->
            try {
                WallpaperManager.getInstance(this)
                    .removeOnColorsChangedListener(listener)
            } catch (_: Throwable) {
                // Ignore – the activity is going away anyway.
            }
        }
        colorsListener = null
        channel?.setMethodCallHandler(null)
        channel = null
        executor.shutdown()
        super.onDestroy()
    }
}
