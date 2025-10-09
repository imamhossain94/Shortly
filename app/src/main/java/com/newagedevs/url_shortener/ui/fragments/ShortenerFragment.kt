package com.newagedevs.url_shortener.ui.fragments

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.FrameLayout
import android.widget.Spinner
import android.widget.TextView
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.fragment.app.viewModels
import com.google.android.material.button.MaterialButton
import com.google.android.material.button.MaterialButtonToggleGroup
import com.google.android.material.card.MaterialCardView
import com.google.android.material.progressindicator.CircularProgressIndicator
import com.google.android.material.textfield.TextInputEditText
import com.google.android.material.textfield.TextInputLayout
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.data.model.UrlData
import com.newagedevs.url_shortener.helper.ApplovinAdsManager
import com.newagedevs.url_shortener.ui.activities.MainActivity
import com.newagedevs.url_shortener.ui.activities.ResultActivity
import com.newagedevs.url_shortener.ui.viewmodel.MainViewModel
import com.newagedevs.url_shortener.ui.viewmodel.UrlViewModel
import com.newagedevs.url_shortener.utils.Ads
import com.newagedevs.url_shortener.utils.Providers
import com.newagedevs.url_shortener.utils.isValidUrl
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class ShortenerFragment : Fragment(R.layout.fragment_shortener) {

    @Inject
    lateinit var adsManager: ApplovinAdsManager

    private lateinit var inputUrlLayout: TextInputLayout
    private lateinit var inputUrl: TextInputEditText
    private lateinit var providerSpinner: Spinner
    private lateinit var actionButton: MaterialButton
    private lateinit var toggleButtonGroup: MaterialButtonToggleGroup
    private lateinit var removeAdsMCV: MaterialCardView
    private lateinit var progressIndicator: CircularProgressIndicator
    private lateinit var premiumDescription: TextView

    private lateinit var nativeAdsContainer: FrameLayout

    private val viewModel: UrlViewModel by viewModels()
    private val mainViewModel: MainViewModel by activityViewModels()

    private var selectedProvider: String = ""
    private var hasRequestedNativeAd = false

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        // Initialize views
        inputUrl = view.findViewById(R.id.input_url)
        inputUrlLayout = view.findViewById(R.id.urlInputLayout)
        providerSpinner = view.findViewById(R.id.provider_spinner)
        actionButton = view.findViewById(R.id.shorten_button)
        toggleButtonGroup = view.findViewById(R.id.toggleButton)
        removeAdsMCV = view.findViewById(R.id.remove_ads_mcv)
        progressIndicator = view.findViewById(R.id.progress_indicator)
        premiumDescription = view.findViewById<TextView>(R.id.premium_description)

        nativeAdsContainer = view.findViewById(R.id.native_ads_container)

        // Setup provider spinner
        setupProviderSpinner()

        // Set initial toggle state
        toggleButtonGroup.check(R.id.btn_shortener)
        updateUiForMode(isShortenMode = true)

        // Toggle listener
        toggleButtonGroup.addOnButtonCheckedListener { _, checkedId, isChecked ->
            if (!isChecked) return@addOnButtonCheckedListener // Only react when selected

            val isShortenMode = checkedId == R.id.btn_shortener
            updateUiForMode(isShortenMode)
        }

        // Remove ads card click
        removeAdsMCV.setOnClickListener {
            (activity as? MainActivity)?.purchase()
        }

        // Main action button
        actionButton.setOnClickListener {
            handleUrlAction()
        }

        mainViewModel.productPrice.observe(viewLifecycleOwner) { price ->
            premiumDescription.text = "Join 500+ users • Only $price/lifetime • Limited Time!"
        }

        // Observe pro status
        mainViewModel.isProUser.observe(viewLifecycleOwner) { isPro ->
            removeAdsMCV.visibility = if (isPro) View.GONE else View.VISIBLE

            // Only request native ad once and only for non-pro users
            if (!isPro && !hasRequestedNativeAd) {
                hasRequestedNativeAd = true
                // Use post to ensure view is fully laid out
                nativeAdsContainer.post {
                    // User is not pro - initialize ads
                    adsManager.createNativeAds( nativeAdsContainer)
                }
            } else if (isPro) {
                // Clean up ad container for pro users
                nativeAdsContainer.removeAllViews()
                nativeAdsContainer.visibility = View.GONE
            }
        }

        // Handle shared URL (e.g., from share intent)
        arguments?.getString("shared_url")?.let { sharedUrl ->
            inputUrl.setText(sharedUrl)
            arguments?.clear()
            // Auto-trigger if valid
            if (sharedUrl.isValidUrl()) {
                view.post { actionButton.performClick() }
            }
        }
    }

    private fun setupProviderSpinner() {
        val providers = Providers.list
        val adapter = ArrayAdapter(
            requireContext(),
            android.R.layout.simple_spinner_item,
            providers
        )
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        providerSpinner.adapter = adapter

        // Set initial selection
        selectedProvider = providers.firstOrNull() ?: ""

        // Spinner item selection listener
        providerSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                selectedProvider = providers[position]
            }

            override fun onNothingSelected(parent: AdapterView<*>?) {
                // Do nothing
            }
        }
    }

    private fun updateUiForMode(isShortenMode: Boolean) {
        if (isShortenMode) {
            inputUrlLayout.hint = getString(R.string.enter_long_url_here)
            actionButton.setText(R.string.shorten)
            providerSpinner.isEnabled = true
        } else {
            inputUrlLayout.hint = getString(R.string.enter_short_url_here)
            actionButton.setText(R.string.expand)
            providerSpinner.isEnabled = false
        }
    }

    private fun handleUrlAction() {
        mainViewModel.incrementClickCount()
        val isProUser = mainViewModel.isProUser.value ?: false
        val clickCount = mainViewModel.clickCount.value ?: 0

        val url = inputUrl.text.toString().trim()
        if (url.isEmpty()) {
            inputUrlLayout.error = getString(R.string.url_required)
            return
        }

        if (!url.isValidUrl()) {
            inputUrlLayout.error = getString(R.string.invalid_url)
            return
        }

        // Clear error if valid
        inputUrlLayout.error = null

        val resultLiveData = when (toggleButtonGroup.checkedButtonId) {
            R.id.btn_shortener -> {
                viewModel.shortenUrl(selectedProvider, url)
            }
            R.id.btn_expender -> {
                viewModel.expendUrl(url)
            }
            else -> {
                Toast.makeText(requireContext(), R.string.select_action, Toast.LENGTH_SHORT).show()
                return
            }
        }

        progressIndicator.visibility = View.VISIBLE
        actionButton.isEnabled = false

        val observeResult: (UrlData) -> Unit = { result ->
            actionButton.isEnabled = true
            progressIndicator.visibility = View.INVISIBLE

            if (result.success == true) {
                val intent = Intent(requireContext(), ResultActivity::class.java)
                intent.putExtra("url_data", result)
                startActivity(intent)
            } else {
                Toast.makeText(requireContext(), getString(R.string.operation_failed), Toast.LENGTH_SHORT).show()
            }
            progressIndicator.visibility = View.INVISIBLE
        }

        // Show ad if needed (non-pro user, 3+ clicks)
        if (!isProUser && clickCount >= 3) {
            mainViewModel.resetClickCount()
            (activity as? MainActivity)?.showAds()
        }

        resultLiveData.observe(viewLifecycleOwner, observeResult)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        hasRequestedNativeAd = false
    }
}