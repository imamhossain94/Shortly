package com.newagedevs.url_shortener.ui.activities

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.FrameLayout
import android.widget.LinearLayout
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.navigation.NavController
import androidx.navigation.findNavController
import androidx.navigation.ui.setupWithNavController
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.limurse.iap.DataWrappers
import com.limurse.iap.IapConnector
import com.limurse.iap.PurchaseServiceListener
import com.newagedevs.url_shortener.BuildConfig
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.helper.ApplovinAdsManager
import com.newagedevs.url_shortener.ui.viewmodel.MainViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : AppCompatActivity() {

    private val viewModel: MainViewModel by viewModels()

    private lateinit var adsContainer: LinearLayout
    private lateinit var nativeAdsContainer: FrameLayout
    private var adsManager: ApplovinAdsManager? = null
    private var iapConnector: IapConnector? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_main)
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, 0)
            insets
        }

        adsContainer = findViewById(R.id.ads_container)
        nativeAdsContainer = findViewById(R.id.native_ads_container)

        // Pro features
        iapConnector = IapConnector(
            context = this@MainActivity,
            nonConsumableKeys = listOf(BuildConfig.PRODUCT_ID),
            key = BuildConfig.BASE_64_KEY,
            enableLogging = true
        )

        iapConnector?.addPurchaseListener(object : PurchaseServiceListener {
            override fun onPricesUpdated(iapKeyPrices: Map<String, List<DataWrappers.ProductDetails>>) {
                val productDetails = iapKeyPrices[BuildConfig.PRODUCT_ID]?.first()
                viewModel.setProductPrice("${productDetails?.price}/")
            }

            override fun onProductPurchased(purchaseInfo: DataWrappers.PurchaseInfo) {
                viewModel.setPro(true)
            }

            override fun onProductRestored(purchaseInfo: DataWrappers.PurchaseInfo) {
                if(purchaseInfo.sku == BuildConfig.PRODUCT_ID && purchaseInfo.purchaseState == 1) {
                    viewModel.setPro(true)
                }
            }

            override fun onPurchaseFailed(purchaseInfo: DataWrappers.PurchaseInfo?, billingResponseCode: Int?) { }
        })

        viewModel.isProUser.observe(this) { isPro ->
            if (isPro) {
                adsContainer.visibility = View.GONE
                adsContainer.removeAllViews()

                nativeAdsContainer.visibility = View.GONE
                nativeAdsContainer.removeAllViews()
            } else {
                adsManager = ApplovinAdsManager(this)
                adsManager?.createBannerAd(adsContainer)
                adsManager?.createNativeAds(nativeAdsContainer)
            }
        }
    }

    override fun onPostCreate(savedInstanceState: Bundle?) {
        super.onPostCreate(savedInstanceState)
        setupBottomNavigation()
        handleSharedIntent(intent) // Move here to ensure NavController is ready
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleSharedIntent(intent)
    }

    private fun handleSharedIntent(intent: Intent) {
        if (intent.action == Intent.ACTION_SEND && intent.type == "text/plain") {
            val sharedUrl = intent.getStringExtra(Intent.EXTRA_TEXT)
            sharedUrl?.let {
                // Ensure NavController is available before navigating
                val navController = findNavControllerSafe() ?: return

                val bundle = Bundle().apply {
                    putString("shared_url", it)
                }

                navController.navigate(R.id.nav_shortener, bundle)
            }
        }
    }

    private fun findNavControllerSafe(): NavController? {
        return try {
            findNavController(R.id.nav_host_fragment)
        } catch (e: IllegalStateException) {
            null // NavController is not available yet
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        adsManager?.destroyAds()
    }

    private fun setupBottomNavigation() {
        val navController = findNavControllerSafe()
        val navView: BottomNavigationView = findViewById(R.id.bottom_navigation)
        navView.setupWithNavController(navController ?: return)
    }

    fun purchase() {
        iapConnector?.purchase(this, BuildConfig.PRODUCT_ID)
    }

    fun showAds() {
        adsManager?.showInterstitialAd()
    }
}
