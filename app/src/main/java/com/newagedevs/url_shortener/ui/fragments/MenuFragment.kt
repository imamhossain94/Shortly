package com.newagedevs.url_shortener.ui.fragments

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.TextView
import androidx.core.app.ShareCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.card.MaterialCardView
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.inhouseads.InHouseBannerAdsView
import com.newagedevs.url_shortener.ui.activities.AboutActivity
import com.newagedevs.url_shortener.ui.activities.FeedbackActivity
import com.newagedevs.url_shortener.ui.activities.MainActivity
import com.newagedevs.url_shortener.ui.adapters.MenuAdapter
import com.newagedevs.url_shortener.ui.viewmodel.MainViewModel
import com.newagedevs.url_shortener.utils.Ads
import com.newagedevs.url_shortener.utils.Constants
import com.newagedevs.url_shortener.utils.MenuUtils
import com.newagedevs.url_shortener.utils.openMailApp


class MenuFragment : Fragment(R.layout.fragment_menu) {

    private val viewModel: MainViewModel by activityViewModels()

    private lateinit var proFeatureLayout: MaterialCardView
    private lateinit var upgradeButton: Button
    private lateinit var inHouseAdsContainer: MaterialCardView
    private lateinit var productPrice: TextView
    private lateinit var inHouseAdView: InHouseBannerAdsView
    private lateinit var menuRecyclerView: RecyclerView

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        proFeatureLayout = view.findViewById(R.id.pro_feature_layout)
        upgradeButton = view.findViewById(R.id.upgrade_button)
        inHouseAdsContainer = view.findViewById(R.id.in_house_ads_container)
        productPrice = view.findViewById(R.id.product_price)
        inHouseAdView = view.findViewById(R.id.in_house_ad_view)
        menuRecyclerView = view.findViewById(R.id.menu_recycler_view)

        val adapter = MenuAdapter { onMenuClicked(it) }
        menuRecyclerView.adapter = adapter
        adapter.submitList(MenuUtils.get(requireContext()))

        upgradeButton.setOnClickListener {
            (activity as? MainActivity)?.purchase()
        }

        viewModel.productPrice.observe(viewLifecycleOwner) { price ->
            view.post {
                try {
                    productPrice.text = price
                } catch (_:Exception) {}
            }
        }

        viewModel.isProUser.observe(viewLifecycleOwner) { isPro ->
            view.post {
                try {
                    if (isPro) {
                        proFeatureLayout.visibility = View.GONE
                        inHouseAdsContainer.visibility = View.GONE
                    } else {
                        inHouseAdsContainer.visibility = View.VISIBLE
                        inHouseAdView.setAdsData(Ads.list) { appLink ->
                            val intent = Intent(Intent.ACTION_VIEW).apply {
                                data = Uri.parse(appLink)
                            }
                            startActivity(intent)
                        }
                    }
                } catch (_:Exception) {}
            }
        }

    }

    private fun onMenuClicked(obj: MenuAdapter.MenuItem) {
        when (obj.title) {
            getString(R.string.rate_us) -> {
                MaterialAlertDialogBuilder(requireContext())
                    .setTitle("Are You Enjoying?")
                    .setMessage("If you like ${getString(R.string.app_name)}, please give it a 5 starts rating in Google Play, Thank You")
                    .setNegativeButton("Cancel") { dialog, _ ->
                        dialog.dismiss()
                    }
                    .setPositiveButton("Rate") { dialog, _ ->
                        startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(Constants.APP_STORE_ID)))
                        dialog.dismiss()
                    }.show()
            }
            getString(R.string.share) -> ShareCompat.IntentBuilder(requireContext())
                .setType("text/plain")
                .setChooserTitle("Share ${getString(R.string.app_name)} with:")
                .setText(Constants.APP_STORE_BASE_URL + requireContext().packageName)
                .startChooser()
            getString(R.string.feedback) -> requireContext().startActivity(Intent(requireContext(), FeedbackActivity::class.java))
            getString(R.string.other_app) -> startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(Constants.PUBLISHER_NAME)))
            getString(R.string.about) -> requireContext().startActivity(Intent(requireContext(), AboutActivity::class.java))
        }
    }

}
