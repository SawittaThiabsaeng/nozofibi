package com.nozofibi.app

import io.flutter.embedding.android.FlutterActivity

import android.os.Build
import android.os.Bundle
import android.window.OnBackInvokedDispatcher
import androidx.core.view.WindowCompat

class MainActivity : FlutterActivity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		if (Build.VERSION.SDK_INT >= 34) {
			WindowCompat.setDecorFitsSystemWindows(window, false)
		}
		super.onCreate(savedInstanceState)
	}
}
