package com.phantom220.realliferpg.posecamera

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Color
import android.view.Gravity
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.pose.PoseDetection
import com.google.mlkit.vision.pose.PoseDetector
import com.google.mlkit.vision.pose.PoseDetectorOptions
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.UsedByGodot
import java.util.concurrent.Executors

/**
 * On-device camera + bundled pose model. No network client is used here.
 * Permission is requested on first start; call startCamera() again after granting it.
 */
class RealLifePoseCameraPlugin(godot: Godot) : GodotPlugin(godot) {
    private val cameraExecutor = Executors.newSingleThreadExecutor()
    @Volatile private var latestLandmarks: ArrayList<HashMap<String, Any>> = arrayListOf()
    @Volatile private var running = false
    @Volatile private var requestActive = false
    private var cameraProvider: ProcessCameraProvider? = null
    private var previewView: PreviewView? = null
    private var detector: PoseDetector? = null

    override fun getPluginName() = "RealLifePoseCamera"

    @UsedByGodot
    fun hasCameraPermission(): Boolean =
        ContextCompat.checkSelfPermission(getActivity(), Manifest.permission.CAMERA) ==
            PackageManager.PERMISSION_GRANTED

    @UsedByGodot
    fun startCamera(): Boolean {
        val activity = getActivity()
        if (!hasCameraPermission()) {
            ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.CAMERA), 7401)
            return false
        }
        if (running || requestActive) return true
        requestActive = true
        val owner = activity as? LifecycleOwner ?: run { requestActive = false; return false }

        val options = PoseDetectorOptions.Builder()
            .setDetectorMode(PoseDetectorOptions.STREAM_MODE)
            .build()
        detector = PoseDetection.getClient(options)

        val view = PreviewView(activity).apply {
            setBackgroundColor(Color.BLACK)
            scaleType = PreviewView.ScaleType.FILL_CENTER
        }
        previewView = view
        val heightPx = (activity.resources.displayMetrics.density * 250).toInt()
        activity.addContentView(
            view,
            FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, heightPx, Gravity.TOP)
        )

        val providerFuture = ProcessCameraProvider.getInstance(activity)
        providerFuture.addListener({
            if (!requestActive) {
                detector?.close()
                detector = null
                removePreview()
                return@addListener
            }
            try {
                val provider = providerFuture.get()
                cameraProvider = provider
                val preview = Preview.Builder().build().also { it.setSurfaceProvider(view.surfaceProvider) }
                val analysis = ImageAnalysis.Builder()
                    .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                    .setTargetResolution(android.util.Size(480, 360))
                    .build()
                analysis.setAnalyzer(cameraExecutor) { proxy ->
                    val mediaImage = proxy.image
                    val activeDetector = detector
                    if (mediaImage == null || activeDetector == null) {
                        proxy.close()
                    } else {
                        val input = InputImage.fromMediaImage(mediaImage, proxy.imageInfo.rotationDegrees)
                        activeDetector.process(input)
                            .addOnSuccessListener { pose ->
                                val rotated = proxy.imageInfo.rotationDegrees % 180 != 0
                                val width = (if (rotated) mediaImage.height else mediaImage.width).toFloat().coerceAtLeast(1f)
                                val height = (if (rotated) mediaImage.width else mediaImage.height).toFloat().coerceAtLeast(1f)
                                val next = ArrayList<HashMap<String, Any>>(33)
                                for (index in 0..32) {
                                    val landmark = pose.getLandmark(index)
                                    if (landmark == null) {
                                        next.add(hashMapOf("x" to 0f, "y" to 0f, "confidence" to 0f))
                                    } else {
                                        next.add(hashMapOf(
                                            "x" to (landmark.position.x / width),
                                            "y" to (landmark.position.y / height),
                                            "confidence" to landmark.inFrameLikelihood
                                        ))
                                    }
                                }
                                latestLandmarks = next
                            }
                            .addOnFailureListener { latestLandmarks = arrayListOf() }
                            .addOnCompleteListener { proxy.close() }
                    }
                }
                provider.unbindAll()
                provider.bindToLifecycle(owner, CameraSelector.DEFAULT_BACK_CAMERA, preview, analysis)
                running = true
            } catch (_: Exception) {
                running = false
                requestActive = false
                detector?.close()
                detector = null
                removePreview()
            }
        }, ContextCompat.getMainExecutor(activity))
        return true
    }

    @UsedByGodot
    fun getLatestLandmarks(): ArrayList<HashMap<String, Any>> = latestLandmarks

    @UsedByGodot
    fun isCameraRunning(): Boolean = running

    @UsedByGodot
    fun stopCamera() {
        requestActive = false
        running = false
        latestLandmarks = arrayListOf()
        cameraProvider?.unbindAll()
        cameraProvider = null
        detector?.close()
        detector = null
        getActivity().runOnUiThread { removePreview() }
    }

    private fun removePreview() {
        val view = previewView ?: return
        (view.parent as? ViewGroup)?.removeView(view)
        previewView = null
    }

    override fun onMainPause() {
        stopCamera()
        super.onMainPause()
    }

    override fun onMainDestroy() {
        stopCamera()
        cameraExecutor.shutdown()
        super.onMainDestroy()
    }
}
