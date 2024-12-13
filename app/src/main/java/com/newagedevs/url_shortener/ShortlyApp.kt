package com.newagedevs.url_shortener

import android.app.Application
import dagger.hilt.android.HiltAndroidApp
import android.content.Context
import android.os.Build
import android.webkit.WebView
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.ProcessLifecycleOwner
import com.applovin.mediation.MaxAd
import com.applovin.mediation.MaxAdListener
import com.applovin.mediation.MaxError
import com.applovin.mediation.ads.MaxAppOpenAd
import com.applovin.sdk.AppLovinMediationProvider
import com.applovin.sdk.AppLovinSdk
import com.applovin.sdk.AppLovinSdkInitializationConfiguration

@HiltAndroidApp
class ShortlyApp : Application() {

    private lateinit var appOpenManager: AppOpenManager

    override fun onCreate() {
        super.onCreate()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val process = getProcessName()
            if (packageName != process) WebView.setDataDirectorySuffix(process)
        }

        initializeAppLovinSdk()
    }

    private fun initializeAppLovinSdk() {
        val initConfig = AppLovinSdkInitializationConfiguration.builder(BuildConfig.applovinSdkKey, this)
            .setMediationProvider(AppLovinMediationProvider.MAX)
            .build()

        AppLovinSdk.getInstance(this).initialize(initConfig) { sdkConfig ->
            appOpenManager = AppOpenManager(this@ShortlyApp)
        }
    }


    inner class AppOpenManager(context: Context) : MaxAdListener {
        private val appOpenAd: MaxAppOpenAd?
        private val context: Context

        //Ads ID here
        private val ADS_UNIT = BuildConfig.appOpen_AdUnit

        private var lifecycleEventObserver = LifecycleEventObserver { _, event ->
            when (event) {
                Lifecycle.Event.ON_STOP -> {  }
                Lifecycle.Event.ON_START -> {
                    showAdIfReady()
                }
                else -> {}
            }
        }

        init {
            ProcessLifecycleOwner.get().lifecycle.addObserver(lifecycleEventObserver)
            this.context = context
            appOpenAd = MaxAppOpenAd(ADS_UNIT, context)
            appOpenAd.setListener(this)
            appOpenAd.loadAd()
        }

        private fun showAdIfReady() {
            if (appOpenAd == null || !AppLovinSdk.getInstance(context).isInitialized) return

            if (appOpenAd.isReady) {
                appOpenAd.showAd(ADS_UNIT)
            } else {
                appOpenAd.loadAd()
            }
        }

        override fun onAdLoaded(ad: MaxAd) { }
        override fun onAdLoadFailed(adUnitId: String, error: MaxError) {}
        override fun onAdDisplayed(ad: MaxAd) { }
        override fun onAdClicked(ad: MaxAd) {}
        override fun onAdHidden(ad: MaxAd) {
            appOpenAd!!.loadAd()
        }

        override fun onAdDisplayFailed(ad: MaxAd, error: MaxError) {
            appOpenAd!!.loadAd()
        }
    }

}