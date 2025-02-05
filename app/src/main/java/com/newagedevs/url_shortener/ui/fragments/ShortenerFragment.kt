package com.newagedevs.url_shortener.ui.fragments

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.ArrayAdapter
import android.widget.Spinner
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
import com.newagedevs.url_shortener.ui.activities.MainActivity
import com.newagedevs.url_shortener.ui.activities.ResultActivity
import com.newagedevs.url_shortener.ui.viewmodel.MainViewModel
import com.newagedevs.url_shortener.ui.viewmodel.UrlViewModel
import com.newagedevs.url_shortener.utils.Ads
import com.newagedevs.url_shortener.utils.Providers
import com.newagedevs.url_shortener.utils.isValidUrl
import dagger.hilt.android.AndroidEntryPoint
import okhttp3.internal.notify


@AndroidEntryPoint
class ShortenerFragment : Fragment(R.layout.fragment_shortener) {

    private lateinit var inputUrlLayout: TextInputLayout
    private lateinit var providerDropDownLayout: MaterialCardView
    private lateinit var inputUrl: TextInputEditText
    private lateinit var providerDropDown: Spinner
    private lateinit var actionButton: MaterialButton
    private lateinit var toggleButtonGroup: MaterialButtonToggleGroup
    private lateinit var removeAdsMCV: MaterialCardView
    private lateinit var progressIndicator: CircularProgressIndicator

    private val viewModel: UrlViewModel by viewModels()
    private val mainViewModel: MainViewModel by activityViewModels()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        inputUrl = view.findViewById(R.id.input_url)
        inputUrlLayout = view.findViewById(R.id.urlInputLayout)
        providerDropDownLayout = view.findViewById(R.id.provider_dropdown_layout)
        actionButton = view.findViewById(R.id.shorten_button)
        providerDropDown = view.findViewById(R.id.provider_dropdown)
        toggleButtonGroup = view.findViewById(R.id.toggleButton)
        removeAdsMCV = view.findViewById(R.id.remove_ads_mcv)
        progressIndicator = view.findViewById(R.id.progress_indicator)

        removeAdsMCV.setOnClickListener {
            (activity as? MainActivity)?.purchase()
        }

        setupProviderSpinner()

        toggleButtonGroup.check(R.id.btn_shortener)
        toggleButtonGroup.addOnButtonCheckedListener { group, checkedId, isChecked ->
            when (checkedId) {
                R.id.btn_shortener -> {
                    if (isChecked) {
                        // Handle Button 1 selected
                        inputUrlLayout.hint = "Enter Long URL"
                        actionButton.text = "Shorten"
                        providerDropDownLayout.visibility = View.VISIBLE
                    }
                }
                R.id.btn_expender -> {
                    if (isChecked) {
                        // Handle Button 2 selected
                        inputUrlLayout.hint = "Enter short URL"
                        actionButton.text = "Expend"
                        providerDropDownLayout.visibility = View.GONE
                    }
                }
            }
        }

        actionButton.setOnClickListener {
            mainViewModel.incrementClickCount()
            val isProUser = mainViewModel.isProUser.value ?: false
            val clickCount = mainViewModel.clickCount.value ?: 0


            val url = inputUrl.text.toString()

            if (url.isEmpty()) {
                Toast.makeText(requireContext(), "Please enter a URL", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            if (!url.isValidUrl()) {
                Toast.makeText(requireContext(), "Please enter a valid URL", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            val resultLiveData = when (toggleButtonGroup.checkedButtonId) {
                R.id.btn_shortener -> {
                    val selectedProvider = providerDropDown.selectedItem.toString()
                    viewModel.shortenUrl(selectedProvider, url)
                }
                R.id.btn_expender -> {
                    viewModel.expendUrl(url)
                }
                else -> {
                    Toast.makeText(requireContext(), "Please select Shorten or Expand", Toast.LENGTH_SHORT).show()
                    return@setOnClickListener
                }
            }

            progressIndicator.visibility = View.VISIBLE

            val observeResult: (result: UrlData) -> Unit = { result ->
                if (result.success == true) {
                    val intent = Intent(requireContext(), ResultActivity::class.java)
                    intent.putExtra("url_data", result)
                    startActivity(intent)
                } else {
                    Toast.makeText(requireContext(), "Failed to process URL", Toast.LENGTH_SHORT).show()
                }
                progressIndicator.visibility = View.INVISIBLE
            }

            if (!isProUser && clickCount >= 3) {
                mainViewModel.resetClickCount()
                (activity as? MainActivity)?.showAds()
            }

            resultLiveData.observe(viewLifecycleOwner, observeResult)
        }

        mainViewModel.isProUser.observe(viewLifecycleOwner) { isPro ->
            view.post {
                try {
                    if (isPro) {
                        removeAdsMCV.visibility = View.GONE
                    } else {
                        removeAdsMCV.visibility = View.VISIBLE
                    }
                } catch (_:Exception) {}
            }
        }

        val sharedUrl = arguments?.getString("shared_url")
        sharedUrl?.let {
            inputUrl.setText(it)
            actionButton.performClick()

            requireArguments().clear()
        }

    }

    private fun setupProviderSpinner() {
        val adapter = ArrayAdapter(requireContext(), android.R.layout.simple_spinner_item, Providers.list)
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        providerDropDown.setAdapter(adapter)
        providerDropDown.post { providerDropDown.setSelection(0) }
    }

}
