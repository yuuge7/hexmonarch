package com.hexmonarch.hexmonarch

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.view.View
import android.webkit.WebChromeClient
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * A small in-app video player: the publisher's own YouTube embed inside a WebView, shown as a
 * Flutter platform view ("hexmonarch/tape"). Nothing is bundled or downloaded, the video is
 * streamed by its official player, so it needs a connection; without one the frame says so.
 */
class TapeViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val video = (args as? Map<*, *>)?.get("video") as? String ?: ""
        return TapeView(context, video)
    }
}

@SuppressLint("SetJavaScriptEnabled")
class TapeView(context: Context, video: String) : PlatformView {
    private val web = WebView(context)
    private var failed = false

    init {
        web.setBackgroundColor(Color.BLACK)
        web.settings.javaScriptEnabled = true
        web.settings.domStorageEnabled = true
        // The whole point is that it starts on its own.
        web.settings.mediaPlaybackRequiresUserGesture = false
        web.webChromeClient = WebChromeClient()
        web.webViewClient = object : WebViewClient() {
            // Links in the player would leave the frame: stay on the tape.
            override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean =
                request.isForMainFrame

            override fun onReceivedError(view: WebView, request: WebResourceRequest, error: WebResourceError) {
                if (failed || request.url.host?.contains("youtube") != true) return
                failed = true
                view.loadDataWithBaseURL(null, page("<p>NO SIGNAL</p>"), "text/html", "utf-8", null)
            }
        }
        // Embeds must say who is asking: the app id as the page origin does that.
        val frame = "<iframe src=\"https://www.youtube.com/embed/$video?autoplay=1&playsinline=1&rel=0\" " +
            "allow=\"autoplay; encrypted-media\" referrerpolicy=\"strict-origin-when-cross-origin\"></iframe>"
        web.loadDataWithBaseURL("https://${context.packageName}", page(frame), "text/html", "utf-8", null)
        live = this
    }

    private fun page(body: String) = "<!doctype html><html><head>" +
        "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">" +
        "<style>html,body{margin:0;height:100%;background:#000;overflow:hidden}" +
        "iframe{border:0;width:100%;height:100%}" +
        "p{margin:0;height:100%;display:flex;align-items:center;justify-content:center;" +
        "color:#566070;font:600 12px monospace;letter-spacing:3px}</style></head>" +
        "<body>$body</body></html>"

    fun pause() = web.onPause()

    fun resume() = web.onResume()

    override fun getView(): View = web

    override fun dispose() {
        if (live === this) live = null
        web.stopLoading()
        web.loadUrl("about:blank")
        web.destroy()
    }

    companion object {
        /** The player on screen, if any, so the activity can silence it in the background. */
        var live: TapeView? = null
    }
}
