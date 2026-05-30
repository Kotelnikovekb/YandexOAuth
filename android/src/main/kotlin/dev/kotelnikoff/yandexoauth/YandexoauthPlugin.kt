package dev.kotelnikoff.yandexoauth

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import com.yandex.authsdk.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.security.MessageDigest
import java.util.Locale

/** YandexoauthPlugin */
class YandexoauthPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    PluginRegistry.ActivityResultListener {
    
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var context: Context? = null
    
    private var yandexSdk: YandexAuthSdk? = null
    private var pendingResult: Result? = null
    private val requestLoginYandex = 100

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "yandexoauth")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "start" -> startYandexSdk(result)
            "yandexAuth" -> authorizeWithYandex(result)
            "logoutYandex" -> logoutYandex(result)
            "getCertificateFingerprint" -> getCertificateFingerprint(call, result)
            else -> result.notImplemented()
        }
    }

    private fun startYandexSdk(result: Result) {
        val ctx = context ?: run {
            result.error("CONTEXT_NOT_FOUND", "Application context is null", null)
            return
        }
        try {
            yandexSdk = YandexAuthSdk.create(
                YandexAuthOptions(ctx, true)
            )
            result.success(true)
        } catch (e: Exception) {
            result.error("YANDEX_INIT_ERROR", e.message, e.stackTraceToString())
        }
    }

    private fun authorizeWithYandex(result: Result) {
        if (pendingResult != null) {
            result.error(
                "YANDEX_PENDING_REQUEST",
                "Прошлый запрос авторизации еще не завершен",
                null
            )
            return
        }

        val sdk = yandexSdk
        if (sdk == null) {
            result.error(
                "YANDEX_NOT_INITIALIZED",
                "Сначала вызовите start для инициализации Yandex SDK",
                null
            )
            return
        }

        val act = activity
        if (act == null) {
            result.error(
                "ACTIVITY_NOT_FOUND",
                "Activity is null. Plugin must be attached to an activity.",
                null
            )
            return
        }

        pendingResult = result

        try {
            val intent = sdk.contract.createIntent(act, YandexAuthLoginOptions())
            act.startActivityForResult(intent, requestLoginYandex)
        } catch (e: Exception) {
            pendingResult = null
            result.error("YANDEX_AUTHORIZE_ERROR", e.message, e.stackTraceToString())
        }
    }

    private fun getCertificateFingerprint(call: MethodCall, result: Result) {
        val ctx = context ?: run {
            result.error("CONTEXT_NOT_FOUND", "Application context is null", null)
            return
        }
        try {
            val algorithm = (call.arguments as? String)?.uppercase(Locale.ROOT) ?: "SHA1"
            val packageInfo = getSigningPackageInfo(ctx)
            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.signingInfo?.apkContentsSigners
            } else {
                @Suppress("DEPRECATION")
                packageInfo.signatures
            }

            if (signatures.isNullOrEmpty()) {
                result.error(
                    "FINGERPRINT_NOT_FOUND",
                    "Не удалось получить подпись приложения",
                    null
                )
                return
            }

            val digest = MessageDigest.getInstance(algorithm)
            digest.update(signatures[0].toByteArray())
            val fingerprint = digest.digest().joinToString(":") { byte ->
                "%02X".format(byte)
            }

            result.success(
                mapOf(
                    "success" to true,
                    "type" to algorithm,
                    "fingerprint" to fingerprint,
                    "packageName" to ctx.packageName
                )
            )
        } catch (e: Exception) {
            result.error(
                "FINGERPRINT_ERROR",
                e.message ?: "Не удалось получить fingerprint сертификата",
                e.stackTraceToString()
            )
        }
    }

    private fun logoutYandex(result: Result) {
        val ctx = context ?: run {
            result.error("CONTEXT_NOT_FOUND", "Application context is null", null)
            return
        }
        pendingResult = null
        ctx.getSharedPreferences("authsdk", Context.MODE_PRIVATE)
            .edit()
            .clear()
            .apply()
        yandexSdk = null
        result.success(
            mapOf(
                "success" to true,
                "provider" to "yandex"
            )
        )
    }

    private fun getSigningPackageInfo(ctx: Context): PackageInfo {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            ctx.packageManager.getPackageInfo(
                ctx.packageName,
                PackageManager.GET_SIGNING_CERTIFICATES
            )
        } else {
            @Suppress("DEPRECATION")
            ctx.packageManager.getPackageInfo(
                ctx.packageName,
                PackageManager.GET_SIGNATURES
            )
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == requestLoginYandex) {
            handleYandexActivityResult(resultCode, data)
            return true
        }
        return false
    }

    private fun handleYandexActivityResult(resultCode: Int, data: Intent?) {
        val result = pendingResult ?: return
        val sdk = yandexSdk

        if (sdk == null) {
            pendingResult = null
            result.error("YANDEX_NOT_INITIALIZED", "Yandex SDK не инициализирован", null)
            return
        }

        if (resultCode == Activity.RESULT_CANCELED) {
            pendingResult = null
            result.error("YANDEX_CANCELLED", "Пользователь отменил вход через Яндекс", null)
            return
        }

        try {
            when (val authResult = sdk.contract.parseResult(resultCode, data)) {
                is YandexAuthResult.Success -> {
                    onSuccessAuth(authResult.token, result)
                }
                is YandexAuthResult.Failure -> {
                    pendingResult = null
                    result.error(
                        "YANDEX_AUTH_ERROR",
                        authResult.exception.message,
                        authResult.exception.stackTraceToString()
                    )
                }
                YandexAuthResult.Cancelled -> {
                    pendingResult = null
                    result.error("YANDEX_CANCELLED", "Пользователь отменил вход через Яндекс", null)
                }
            }
        } catch (e: YandexAuthException) {
            pendingResult = null
            result.error("YANDEX_AUTH_ERROR", e.message, e.stackTraceToString())
        }
    }

    private fun onSuccessAuth(
        token: YandexAuthToken,
        result: Result
    ) {
        result.success(
            mapOf(
                "success" to true,
                "token" to token.value,
                "expiresIn" to token.expiresIn
            )
        )
        pendingResult = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
