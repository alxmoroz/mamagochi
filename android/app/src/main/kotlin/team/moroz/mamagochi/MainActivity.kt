package team.moroz.mamagochi

import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge display for Android 15+ compatibility
        // This ensures proper handling of system bars in Android 15+
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}
