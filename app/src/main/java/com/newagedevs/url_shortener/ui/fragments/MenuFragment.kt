package com.newagedevs.url_shortener.ui.fragments

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.core.app.ShareCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.recyclerview.widget.LinearLayoutManager
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
import androidx.core.net.toUri

class MenuFragment : Fragment(R.layout.fragment_menu) {

    private val viewModel: MainViewModel by activityViewModels()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val proFeatureLayout = view.findViewById<MaterialCardView>(R.id.pro_feature_layout)
        val premiumStatusLayout = view.findViewById<MaterialCardView>(R.id.premium_status_layout)
        val inHouseAdsContainer = view.findViewById<MaterialCardView>(R.id.in_house_ads_container)
        val upgradeButton = view.findViewById<com.google.android.material.button.MaterialButton>(R.id.upgrade_button)
        val productPrice = view.findViewById<TextView>(R.id.product_price)
        val inHouseAdView = view.findViewById<InHouseBannerAdsView>(R.id.in_house_ad_view)
        val menuRecyclerView = view.findViewById<androidx.recyclerview.widget.RecyclerView>(R.id.menu_recycler_view)

        // Setup menu list
        val adapter = MenuAdapter { onMenuClicked(it) }
        menuRecyclerView.layoutManager = LinearLayoutManager(requireContext())
        menuRecyclerView.adapter = adapter
        adapter.submitList(MenuUtils.get(requireContext()))

        // Upgrade button
        upgradeButton.setOnClickListener {
            (activity as? MainActivity)?.purchase()
        }

        // Observe price
        viewModel.productPrice.observe(viewLifecycleOwner) { price ->
            productPrice.text = price
        }

        // Observe pro status
        viewModel.isProUser.observe(viewLifecycleOwner) { isPro ->
            proFeatureLayout.visibility = if (isPro) View.GONE else View.VISIBLE
            premiumStatusLayout.visibility = if (isPro) View.VISIBLE else View.GONE
            inHouseAdsContainer.visibility = if (isPro) View.GONE else View.VISIBLE

            if (!isPro) {
                inHouseAdView.setAdsData(Ads.list) { appLink ->
                    startActivity(Intent(Intent.ACTION_VIEW, appLink.toUri()))
                }
            }
        }
    }

    private fun onMenuClicked(item: MenuAdapter.MenuItem) {
        val context = requireContext()
        when (item.title) {
            getString(R.string.rate_us) -> {
                MaterialAlertDialogBuilder(context)
                    .setTitle(R.string.are_you_enjoying)
                    .setMessage(getString(R.string.rate_message, getString(R.string.app_name)))
                    .setNegativeButton(getString(R.string.cancel)) { dialog, _ ->
                        dialog.dismiss()
                    }.setPositiveButton(getString(R.string.rate)) { _, _ ->
                        startActivity(Intent(Intent.ACTION_VIEW, Constants.APP_STORE_ID.toUri()))
                    }
                    .show()
            }

            getString(R.string.share) -> {
                ShareCompat.IntentBuilder.from(requireActivity())
                    .setType("text/plain")
                    .setChooserTitle(getString(R.string.share_app_with))
                    .setText("${Constants.APP_STORE_BASE_URL}${context.packageName}")
                    .startChooser()
            }

            getString(R.string.feedback) -> {
                startActivity(Intent(context, FeedbackActivity::class.java))
            }

            getString(R.string.other_app) -> {
                startActivity(Intent(Intent.ACTION_VIEW, Constants.PUBLISHER_NAME.toUri()))
            }

            getString(R.string.about) -> {
                startActivity(Intent(context, AboutActivity::class.java))
            }
        }
    }
}