package com.hexmonarch.hexmonarch

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings
import android.view.HapticFeedbackConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Hosts the "hexmonarch/native" channel:
 *  - clock: wall clock + elapsedRealtime + boot count (+ network time when the OS has it)
 *    so the Dart catch-up engine can detect manual clock spoofing.
 *  - haptic: rich vibration primitives (VibrationEffect.Composition on API 30+,
 *    predefined effects / HapticFeedbackConstants as fallbacks).
 *  - exportFile / importFile: system file picker (Storage Access Framework) so a
 *    save can be moved to Drive, a cable, or a new phone. No storage permission.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "hexmonarch/native"
    private val reqExport = 4201
    private val reqImport = 4202
    private val maxImportBytes = 32 * 1024 * 1024

    private var pendingResult: MethodChannel.Result? = null
    private var pendingBytes: ByteArray? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "clock" -> result.success(readClock())
                    "haptic" -> {
                        haptic(call.argument<String>("type") ?: "tick")
                        result.success(null)
                    }
                    "exportFile" -> {
                        val name = call.argument<String>("name") ?: "hexmonarch.hexsave"
                        val bytes = call.argument<ByteArray>("bytes")
                        if (bytes == null || pendingResult != null) {
                            result.error("busy", "Another file dialog is open", null)
                        } else {
                            pendingResult = result
                            pendingBytes = bytes
                            val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                                addCategory(Intent.CATEGORY_OPENABLE)
                                type = "application/octet-stream"
                                putExtra(Intent.EXTRA_TITLE, name)
                            }
                            launchPicker(intent, reqExport)
                        }
                    }
                    "importFile" -> {
                        if (pendingResult != null) {
                            result.error("busy", "Another file dialog is open", null)
                        } else {
                            pendingResult = result
                            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                                addCategory(Intent.CATEGORY_OPENABLE)
                                type = "*/*"
                            }
                            launchPicker(intent, reqImport)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun launchPicker(intent: Intent, code: Int) {
        try {
            @Suppress("DEPRECATION")
            startActivityForResult(intent, code)
        } catch (e: Exception) {
            val r = pendingResult
            pendingResult = null
            pendingBytes = null
            r?.error("no_picker", "No file picker available on this device", null)
        }
    }

    @Deprecated("FlutterActivity is not a ComponentActivity; the classic callback is the supported path")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != reqExport && requestCode != reqImport) {
            @Suppress("DEPRECATION")
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val result = pendingResult
        val bytes = pendingBytes
        pendingResult = null
        pendingBytes = null
        val uri = data?.data
        if (result == null) return
        if (resultCode != Activity.RESULT_OK || uri == null) {
            // Cancelled by the user.
            if (requestCode == reqExport) result.success(false) else result.success(null)
            return
        }
        try {
            if (requestCode == reqExport) {
                contentResolver.openOutputStream(uri, "wt").use { out ->
                    if (out == null) throw IllegalStateException("Cannot open the chosen file")
                    out.write(bytes ?: ByteArray(0))
                }
                result.success(true)
            } else {
                val read = contentResolver.openInputStream(uri).use { input ->
                    if (input == null) throw IllegalStateException("Cannot open the chosen file")
                    val buffer = java.io.ByteArrayOutputStream()
                    val chunk = ByteArray(64 * 1024)
                    while (true) {
                        val n = input.read(chunk)
                        if (n < 0) break
                        buffer.write(chunk, 0, n)
                        if (buffer.size() > maxImportBytes) throw IllegalStateException("File is too large to be a save")
                    }
                    buffer.toByteArray()
                }
                result.success(read)
            }
        } catch (e: Exception) {
            result.error("io", e.message ?: "File access failed", null)
        }
    }

    private fun readClock(): Map<String, Any?> {
        val bootCount = try {
            Settings.Global.getInt(contentResolver, Settings.Global.BOOT_COUNT)
        } catch (_: Exception) {
            -1
        }
        var networkTime: Long? = null
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            try {
                networkTime = SystemClock.currentNetworkTimeClock().millis()
            } catch (_: Exception) {
                // No network time fix yet (fully offline device) — that's fine.
            }
        }
        return mapOf(
            "wall" to System.currentTimeMillis(),
            "elapsed" to SystemClock.elapsedRealtime(),
            "bootCount" to bootCount,
            "networkTime" to networkTime,
        )
    }

    private fun vibrator(): Vibrator? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager)?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }
    }

    private fun haptic(type: String) {
        val view = window?.decorView
        val vib = vibrator()
        when (type) {
            // Hex border crossing: the lightest crisp tick the hardware offers.
            "tick" -> {
                if (!composition(vib, intArrayOf(VibrationEffect.Composition.PRIMITIVE_TICK), floatArrayOf(0.7f))) {
                    view?.performHapticFeedback(HapticFeedbackConstants.CLOCK_TICK)
                }
            }
            // UI confirmation (button press, module socketed).
            "click" -> {
                if (!composition(vib, intArrayOf(VibrationEffect.Composition.PRIMITIVE_CLICK), floatArrayOf(0.6f))) {
                    view?.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY)
                }
            }
            // Territory capture: heavy dual-pulse.
            "capture" -> {
                val ok = composition(
                    vib,
                    intArrayOf(VibrationEffect.Composition.PRIMITIVE_THUD, VibrationEffect.Composition.PRIMITIVE_THUD),
                    floatArrayOf(1f, 1f),
                    intArrayOf(0, 110),
                )
                if (!ok) waveform(vib, longArrayOf(0, 70, 90, 70), intArrayOf(0, 255, 0, 255))
            }
            // Something went wrong / hostile event.
            "warn" -> {
                val ok = composition(
                    vib,
                    intArrayOf(VibrationEffect.Composition.PRIMITIVE_QUICK_RISE, VibrationEffect.Composition.PRIMITIVE_QUICK_FALL),
                    floatArrayOf(0.8f, 0.8f),
                )
                if (!ok) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        view?.performHapticFeedback(HapticFeedbackConstants.REJECT)
                    } else {
                        waveform(vib, longArrayOf(0, 40, 60, 40), intArrayOf(0, 180, 0, 180))
                    }
                }
            }
            // Level up / prestige: rising spin.
            "surge" -> {
                val ok = composition(
                    vib,
                    intArrayOf(
                        VibrationEffect.Composition.PRIMITIVE_SLOW_RISE,
                        VibrationEffect.Composition.PRIMITIVE_THUD,
                        VibrationEffect.Composition.PRIMITIVE_CLICK,
                    ),
                    floatArrayOf(0.6f, 1f, 1f),
                    intArrayOf(0, 0, 80),
                )
                if (!ok) waveform(vib, longArrayOf(0, 30, 40, 60, 40, 120), intArrayOf(0, 90, 0, 170, 0, 255))
            }
        }
    }

    private fun composition(
        vib: Vibrator?,
        primitives: IntArray,
        scales: FloatArray,
        delays: IntArray = IntArray(primitives.size),
    ): Boolean {
        if (vib == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return false
        if (!vib.areAllPrimitivesSupported(*primitives)) return false
        val comp = VibrationEffect.startComposition()
        for (i in primitives.indices) comp.addPrimitive(primitives[i], scales[i], delays[i])
        vib.vibrate(comp.compose())
        return true
    }

    private fun waveform(vib: Vibrator?, timings: LongArray, amplitudes: IntArray) {
        if (vib == null || !vib.hasVibrator()) return
        val amps = if (vib.hasAmplitudeControl()) amplitudes else IntArray(amplitudes.size) { if (it % 2 == 1) 255 else 0 }
        vib.vibrate(VibrationEffect.createWaveform(timings, amps, -1))
    }
}
