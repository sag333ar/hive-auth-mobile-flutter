package com.hiveauth.authsigner

import io.flutter.embedding.android.FlutterActivity

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.View
import android.webkit.JavascriptInterface
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.webkit.WebViewAssetLoader
import com.google.gson.Gson
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    var webView: WebView? = null
    var result: MethodChannel.Result? = null
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        if (webView == null) {
            setupView()
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.hiveauth.hiveauthsigner/bridge"
        ).setMethodCallHandler { call, result ->
            this.result = result
            val publicKey = call.argument<String?>("publicKey")
            val privateKey = call.argument<String?>("privateKey")
            val accountName = call.argument<String?>("accountName")
            val data = call.argument<String?>("data")
            val key = call.argument<String?>("key")
            val challenge = call.argument<String?>("challenge")
            val userKey = call.argument<String?>("userKey")

            val memo = call.argument<String>("memo")
            if (call.method == "getProofOfKey" && publicKey != null && privateKey != null && memo != null) {
                webView?.evaluateJavascript("getProofOfKey('$privateKey', '$publicKey', '$memo');", null)
            } else if (call.method == "validateHiveKey" && accountName != null && userKey != null) {
                webView?.evaluateJavascript("validateHiveKey('$accountName', '$userKey');", null)
            } else if (call.method == "decrypt" && data != null && key != null) {
                webView?.evaluateJavascript("decrypt('$accountName', '$key');", null)
            } else if (call.method == "encrypt" && data != null && key != null) {
                webView?.evaluateJavascript("encrypt('$accountName', '$key');", null)
            } else if (call.method == "signChallenge" && challenge != null && key != null) {
                webView?.evaluateJavascript("signChallenge('$challenge', '$key');", null)
            }
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun setupView() {
        val params = FrameLayout.LayoutParams(0, 0)
        webView = WebView(activity)
        val decorView = activity.window.decorView as FrameLayout
        decorView.addView(webView, params)
        webView?.visibility = View.GONE
        webView?.settings?.javaScriptEnabled = true
        webView?.settings?.domStorageEnabled = true
//        webView?.webChromeClient = WebChromeClient()
        WebView.setWebContentsDebuggingEnabled(true)
        val assetLoader = WebViewAssetLoader.Builder()
            .addPathHandler("/assets/", WebViewAssetLoader.AssetsPathHandler(this))
            .build()
        val client: WebViewClient = object : WebViewClient() {
            @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
            override fun shouldInterceptRequest(
                view: WebView,
                request: WebResourceRequest
            ): WebResourceResponse? {
                return assetLoader.shouldInterceptRequest(request.url)
            }

            override fun shouldInterceptRequest(
                view: WebView,
                url: String
            ): WebResourceResponse? {
                return assetLoader.shouldInterceptRequest(Uri.parse(url))
            }
        }
        webView?.webViewClient = client
        webView?.addJavascriptInterface(WebAppInterface(this), "Android")
        webView?.loadUrl("https://appassets.androidplatform.net/assets/index.html")
    }
}

class WebAppInterface(private val mContext: Context) {
    @JavascriptInterface
    fun postMessage(message: String) {
        val main = mContext as? MainActivity ?: return
        val gson = Gson()
        val dataObject = gson.fromJson(message, JSEvent::class.java)
        when (dataObject.type) {
            JSBridgeAction.GET_PROOF_OF_KEY.value -> {
                main.result?.success(message)
            }
            JSBridgeAction.VALIDATE_HIVE_KEY.value -> {
                main.result?.success(message)
            }
            JSBridgeAction.ENCRYPT.value -> {
                main.result?.success(message)
            }
            JSBridgeAction.DECRYPT.value -> {
                main.result?.success(message)
            }
            JSBridgeAction.SIGN_CHALLENGE.value -> {
                main.result?.success(message)
            }
        }
    }
}

data class JSEvent(
    val type: String,
    val error: String,
    val data: String,
)

enum class JSBridgeAction(val value: String) {
    GET_PROOF_OF_KEY("getProofOfKey"),
    VALIDATE_HIVE_KEY("validateHiveKey"),
    ENCRYPT("encrypt"),
    DECRYPT("decrypt"),
    SIGN_CHALLENGE("signChallenge"),
}

