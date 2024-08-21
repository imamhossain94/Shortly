package com.newagedevs.url_shortener.ui.fragments

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import androidx.core.app.ShareCompat
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.inhouseads.InHouseBannerAdsView
import com.newagedevs.url_shortener.ui.adapters.MenuAdapter
import com.newagedevs.url_shortener.utils.Ads
import com.newagedevs.url_shortener.utils.Constants
import com.newagedevs.url_shortener.utils.MenuUtils
import com.newagedevs.url_shortener.utils.openMailApp


class MenuFragment : Fragment(R.layout.fragment_menu) {

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val inHouseAdView: InHouseBannerAdsView = view.findViewById(R.id.in_house_ad_view)
        val menuRecyclerView: RecyclerView = view.findViewById(R.id.menu_recycler_view)

        inHouseAdView.setAdsData(Ads.list) { appLink ->
            val intent = Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse(appLink)
            }
            startActivity(intent)
        }

        val adapter = MenuAdapter { onMenuClicked(it) }
        menuRecyclerView.adapter = adapter
        adapter.submitList(MenuUtils.get(requireContext()))

    }

    private fun onMenuClicked(obj: MenuAdapter.MenuItem) {
        when (obj.title) {
            getString(R.string.rate_us) -> {
                MaterialAlertDialogBuilder(requireContext())
                    .setTitle("Are You Enjoying?")
                    .setMessage("If you like Shortly, please give it a 5 starts rating in Google Play, Thank You")
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
            getString(R.string.feedback) -> openMailApp(requireContext(), "Feedback on Shortly App", Constants.FEEDBACK_MAIL)
            getString(R.string.other_app) -> startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(Constants.PUBLISHER_NAME)))
            getString(R.string.about) -> {
                // requireContext().startActivity(Intent(requireContext(), AboutActivity::class.java)
            }
        }
    }






}
