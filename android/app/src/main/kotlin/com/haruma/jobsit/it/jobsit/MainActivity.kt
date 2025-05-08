package com.haruma.jobsit.it.jobsit

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import java.io.File
import androidx.core.net.toUri

class MainActivity : FlutterActivity() {

    companion object {

        private const val CHANNEL = "com.haruma.jobsit.it.MethodChannel"

        private const val REQUEST_REQUEST_EXTERNAL_STORAGE_PERMISSION = 1002

    }

    private val continuation: Channel<Any?> = Channel()

    private suspend fun requestStoragePermission(

    ): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            activity.requestPermissions(
                arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE),
                REQUEST_REQUEST_EXTERNAL_STORAGE_PERMISSION
            )
        } else {
            val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION,
                "package:${activity.packageName}".toUri())
            activity.startActivityForResult(intent, REQUEST_REQUEST_EXTERNAL_STORAGE_PERMISSION)
        }
        continuation.receive()
        return checkStoragePermission()
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            REQUEST_REQUEST_EXTERNAL_STORAGE_PERMISSION -> {
                runBlocking { continuation.send(data?.data) }
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_REQUEST_EXTERNAL_STORAGE_PERMISSION) {
            runBlocking { continuation.send(null) }
        }
    }

    private fun checkStoragePermission(

    ): Boolean {
        return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            activity.checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED &&
                    activity.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
        } else {
            Environment.isExternalStorageManager()
        }
    }

    private fun externalStorageDirectory(
    ): String {
        return Environment.getExternalStorageDirectory().absolutePath
    }

    private fun resolveUri(uri: Uri): String? {
        var result: String? = null
        val provider = uri.authority
        var path = uri.path?.let { Uri.decode(it) }
        when (provider) {
            "com.android.externalstorage.documents" -> {
                if (path?.startsWith("/document/primary:") == true) {
                    result = path.substring("/document/primary:".length)
                    result = "${externalStorageDirectory()}${if (result.isEmpty()) "" else "/$result"}"
                }
                if (path?.startsWith("/tree/primary:") == true) {
                    result = path.substring("/tree/primary:".length)
                    result = "${externalStorageDirectory()}${if (result.isEmpty()) "" else "/$result"}"
                }
            }
            "me.zhanghai.android.files.file_provider" -> {
                path = Uri.decode(path ?: "")
                if (path?.startsWith("/file://") == true) {
                    result = path.substring(1).toUri().path
                }
            }
            "com.speedsoftware.rootexplorer.fileprovider" -> {
                if (path?.startsWith("/root/") == true) {
                    result = path.substring("/root".length)
                }
            }
            "pl.solidexplorer2.files" -> {
                result = path
            }
            "bin.mt.plus.fp" -> {
                result = path
            }
            "in.mfile.files" -> {
                result = path
            }
            else -> {
                if (path != null && path.startsWith("/") && File(path).exists()) {
                    result = path
                }
            }
        }
        return result
    }


    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result -> CoroutineScope(Dispatchers.Main).launch {
                when (call.method) {
                    "requestStoragePermission" -> {
                        result.success(requestStoragePermission())
                    }
                    "checkStoragePermission" -> {
                        result.success(checkStoragePermission())
                    }
                    "resolveUri" -> {
                        val path = call.argument<String>("path")!!
                        result.success(resolveUri(path.toUri()))
                    }
                }
            }
        }
    }

}
