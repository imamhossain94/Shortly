package com.newagedevs.url_shortener

import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        // Draw behind the system bars from the very first frame. FlutterActivity extends
        // android.app.Activity rather than ComponentActivity, so androidx's
        // enableEdgeToEdge() is unavailable here; this is the call it makes underneath.
        // Flutter's SystemUiMode.edgeToEdge does the same thing, but only once the Dart
        // side has started, which leaves the splash window laid out inset.
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }
}
