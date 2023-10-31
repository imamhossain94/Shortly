package com.newagedevs.url_shortener.view.ui.share

import android.content.Context
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.databinding.ActivityShareBinding
import com.newagedevs.url_shortener.utils.DarkModeUtils
import com.skydoves.bindables.BindingActivity
import org.koin.android.viewmodel.ext.android.viewModel

class ShareActivity : BindingActivity<ActivityShareBinding>(R.layout.activity_share) {

    private val vm: ShareViewModel by viewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding {
            viewModel = vm
        }


    }

    override fun attachBaseContext(context: Context?) {
        if (Build.VERSION.SDK_INT <= 28) {
            super.attachBaseContext(context?.let { DarkModeUtils.createDarkModeContextWrapper(it) })
        } else {
            super.attachBaseContext(context)
        }
    }

    override fun onBackPressed() {
        if (Build.VERSION.SDK_INT == Build.VERSION_CODES.O && isTaskRoot
            && fragmentManager?.backStackEntryCount == 0
        ) {
            finishAfterTransition()
        } else {
            super.onBackPressed()
        }
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        if (Build.VERSION.SDK_INT <= 28) {
            val res = resources
            res.configuration.setTo(DarkModeUtils.createDarkModeConfig(this, newConfig))
        }
    }

}