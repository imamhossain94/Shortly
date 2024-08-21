package com.newagedevs.url_shortener.ui.activities

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.animation.AlphaAnimation
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.newagedevs.url_shortener.R
import dagger.hilt.android.AndroidEntryPoint

@SuppressLint("CustomSplashScreen")
@AndroidEntryPoint
class SplashActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash)
        initConfig()

        val alpha = AlphaAnimation(0f, 1f)
        alpha.duration = 1000

        val splashImage = findViewById<ImageView>(R.id.logo)
        val tv = findViewById<TextView>(R.id.developerName)
        splashImage.startAnimation(alpha)
        tv.startAnimation(alpha)


        Handler(Looper.getMainLooper()).postDelayed({
            startActivity(Intent(this, MainActivity::class.java))
            finish()
        }, 2000)
    }

    fun initConfig() {

    }

}
