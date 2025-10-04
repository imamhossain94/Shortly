package com.newagedevs.url_shortener.helper

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import com.applovin.mediation.MaxAd
import com.applovin.mediation.MaxAdListener
import com.applovin.mediation.MaxAdViewAdListener
import com.applovin.mediation.MaxError
import com.applovin.mediation.MaxReward
import com.applovin.mediation.MaxRewardedAdListener
import com.applovin.mediation.ads.MaxAdView
import com.applovin.mediation.ads.MaxInterstitialAd
import com.applovin.mediation.ads.MaxRewardedAd
import com.newagedevs.url_shortener.BuildConfig
import com.newagedevs.url_shortener.R
import java.util.concurrent.TimeUnit
import kotlin.math.pow
import com.applovin.mediation.nativeAds.MaxNativeAdListener
import com.applovin.mediation.nativeAds.MaxNativeAdLoader
import com.applovin.mediation.nativeAds.MaxNativeAdView
import com.applovin.mediation.nativeAds.MaxNativeAdViewBinder

interface ApplovinAdsManagerListener {
    fun onUserRewarded(maxReward: MaxReward)
}

class ApplovinAdsManager(private val context: Activity, private val listener: ApplovinAdsManagerListener? = null) {
    private var retryAttempt = 0.0
    private var rewardRetryAttempt = 0.0
    private var nativeAdRetryAttempt = 0.0

    private var interstitialAd: MaxInterstitialAd? = null
    private var rewardedAd: MaxRewardedAd? = null

    private var nativeAdLoader: MaxNativeAdLoader? = null
    private var loadedNativeAd: MaxAd? = null

    private val bannerId = BuildConfig.banner_AdUnit
    private val interstitialId: String = BuildConfig.interstitial_AdUnit
    private val rewardId: String = BuildConfig.reward_AdUnit
    private val nativeAdUnitId: String = BuildConfig.native_AdUnit

    // Add a handler for retry operations
    private val retryHandler = Handler(Looper.getMainLooper())

    init {
        // Preload interstitial and rewarded ads
        preloadInterstitialAd()
        preloadRewardedAd()
    }

    // Function to create banner ads
    fun createBannerAd(view: LinearLayout) {
        val bannerAdsListener = BannerAdsListener(view)
        val adView = MaxAdView(bannerId, context).apply {
            setListener(bannerAdsListener)
            layoutParams = FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                context.resources.getDimensionPixelSize(R.dimen.banner_height)
            )
        }
        view.addView(adView)
        adView.loadAd()
    }

    // Function to preload interstitial ads
    private fun preloadInterstitialAd() {
        interstitialAd = MaxInterstitialAd(interstitialId, context).apply {
            setListener(InterstitialAdsListener())
            loadAd()
        }
    }

    // Function to preload rewarded ads
    private fun preloadRewardedAd() {
        rewardedAd = MaxRewardedAd.getInstance(rewardId, context).apply {
            setListener(RewardAdsListener())
            loadAd()
        }
    }

    // Function to create native ads
    fun createNativeAds(containerView: FrameLayout) {
        // Check if context is still valid
        if (context.isFinishing || context.isDestroyed) {
            return
        }

        // Clear the container first
        containerView.removeAllViews()
        containerView.visibility = View.GONE

        // Create a native ad loader if not already created
        if (nativeAdLoader == null) {
            nativeAdLoader = MaxNativeAdLoader(nativeAdUnitId)
        }

        nativeAdLoader?.setNativeAdListener(object : MaxNativeAdListener() {
            override fun onNativeAdLoaded(nativeAdView: MaxNativeAdView?, ad: MaxAd) {
                // Check if context is still valid
                if (context.isFinishing || context.isDestroyed) {
                    return
                }

                // Clean up any pre-existing native ad to prevent memory leaks
                loadedNativeAd?.let { oldAd ->
                    nativeAdLoader?.destroy(oldAd)
                }

                // Save reference to the ad
                loadedNativeAd = ad

                // Reset retry attempt on successful load
                nativeAdRetryAttempt = 0.0

                // Create a native ad view and render the ad
                val adView = createNativeAdView()
                nativeAdLoader?.render(adView, ad)

                // Add the native ad view to the container
                containerView.removeAllViews()
                containerView.addView(adView)
                containerView.visibility = View.VISIBLE
            }

            override fun onNativeAdLoadFailed(adUnitId: String, error: MaxError) {
                // Check if context is still valid before retrying
                if (context.isFinishing || context.isDestroyed) {
                    return
                }

                // Handle failed ad load
                containerView.visibility = View.GONE

                // Implement exponential backoff for retries with maximum retry limit
                nativeAdRetryAttempt++

                // Limit retry attempts to prevent infinite retries
                if (nativeAdRetryAttempt > 5) {
                    return
                }

                val delayMillis = TimeUnit.SECONDS.toMillis(
                    2.0.pow(4.0.coerceAtMost(nativeAdRetryAttempt)).toLong()
                )

                retryHandler.postDelayed({
                    // Double-check context validity before retry
                    if (!context.isFinishing && !context.isDestroyed) {
                        nativeAdLoader?.loadAd()
                    }
                }, delayMillis)
            }

            override fun onNativeAdClicked(ad: MaxAd) {
                // Handle ad click event if needed
            }

            override fun onNativeAdExpired(ad: MaxAd) {
                // Check if context is still valid
                if (!context.isFinishing && !context.isDestroyed) {
                    // Load a new ad when the current one expires
                    nativeAdLoader?.loadAd()
                }
            }
        })

        // Start loading the native ad
        nativeAdLoader?.loadAd()
    }

    // Function to create a native ad view binder
    private fun createNativeAdBinder(): MaxNativeAdViewBinder {
        return MaxNativeAdViewBinder.Builder(R.layout.view_native_ads)
            .setTitleTextViewId(R.id.title_text_view)
            .setBodyTextViewId(R.id.body_text_view)
            .setAdvertiserTextViewId(R.id.advertiser_text_view)
            .setIconImageViewId(R.id.icon_image_view)
            .setMediaContentViewGroupId(R.id.media_view_container)
            .setOptionsContentViewGroupId(R.id.options_view)
            .setStarRatingContentViewGroupId(R.id.star_rating_view)
            .setCallToActionButtonId(R.id.cta_button)
            .build()
    }

    // Function to create a native ad view
    private fun createNativeAdView(): MaxNativeAdView {
        return MaxNativeAdView(createNativeAdBinder(), context)
    }

    // Function to show preloaded interstitial ads
    fun showInterstitialAd(loaded: () -> Unit = { }, failed: () -> Unit = { }) {
        if (interstitialAd?.isReady == true) {
            interstitialAd?.showAd(context)
            loaded.invoke()
        } else {
            failed.invoke()
        }
    }

    // Function to show preloaded reward ads
    fun showRewardAd(
        failed: () -> Unit
    ) {
        if (rewardedAd?.isReady == true) {
            rewardedAd?.showAd(context)
        } else {
            failed.invoke()
        }
    }

    // Destroy all ads to free resources
    fun destroyAds() {
        interstitialAd?.destroy()
        rewardedAd?.destroy()

        // Clean up native ad resources
        loadedNativeAd?.let { ad ->
            nativeAdLoader?.destroy(ad)
        }
        loadedNativeAd = null

        nativeAdLoader?.destroy()
        nativeAdLoader = null
    }

    // Listener for banner ads
    class BannerAdsListener(private val view: LinearLayout) : MaxAdViewAdListener {
        override fun onAdLoaded(maxAd: MaxAd) {
            view.visibility = View.VISIBLE
        }

        override fun onAdDisplayed(maxAd: MaxAd) {
            view.visibility = View.VISIBLE
        }

        override fun onAdHidden(maxAd: MaxAd) {
            view.visibility = View.GONE
        }

        override fun onAdLoadFailed(maxAdUnitId: String, error: MaxError) {
            view.visibility = View.GONE
        }

        override fun onAdDisplayFailed(maxAd: MaxAd, error: MaxError) {
            view.visibility = View.GONE
        }

        override fun onAdClicked(maxAd: MaxAd) {}
        override fun onAdExpanded(maxAd: MaxAd) {}
        override fun onAdCollapsed(maxAd: MaxAd) {}
    }

    // Listener for interstitial ads
    inner class InterstitialAdsListener : MaxAdListener {
        override fun onAdLoaded(maxAd: MaxAd) {
            retryAttempt = 0.0
        }

        override fun onAdLoadFailed(adUnitId: String, error: MaxError) {
            retryAttempt++
            val delayMillis = TimeUnit.SECONDS.toMillis(
                2.0.pow(6.0.coerceAtMost(retryAttempt)).toLong()
            )
            Handler(Looper.getMainLooper()).postDelayed({
                preloadInterstitialAd()
            }, delayMillis)
        }

        override fun onAdDisplayFailed(maxAd: MaxAd, error: MaxError) {}
        override fun onAdDisplayed(maxAd: MaxAd) {}
        override fun onAdClicked(maxAd: MaxAd) {}
        override fun onAdHidden(maxAd: MaxAd) {
            preloadInterstitialAd() // Preload the next ad
        }
    }

    // Listener for reward ads
    inner class RewardAdsListener : MaxRewardedAdListener {
        override fun onAdLoaded(maxAd: MaxAd) {
            rewardRetryAttempt = 0.0
        }

        override fun onAdLoadFailed(adUnitId: String, error: MaxError) {
            rewardRetryAttempt++
            val delayMillis = TimeUnit.SECONDS.toMillis(
                2.0.pow(6.0.coerceAtMost(rewardRetryAttempt)).toLong()
            )
            Handler(Looper.getMainLooper()).postDelayed({
                preloadRewardedAd()
            }, delayMillis)
        }

        override fun onAdDisplayFailed(ad: MaxAd, error: MaxError) {}
        override fun onAdDisplayed(maxAd: MaxAd) {}
        override fun onAdClicked(maxAd: MaxAd) {}
        override fun onAdHidden(maxAd: MaxAd) {
            preloadRewardedAd() // Preload the next ad
        }

        override fun onUserRewarded(maxAd: MaxAd, maxReward: MaxReward) {
            listener?.onUserRewarded(maxReward)
        }
    }
}