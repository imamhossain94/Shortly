package com.newagedevs.url_shortener.ui.fragments

import android.os.Bundle
import android.view.View
import android.widget.ArrayAdapter
import android.widget.AutoCompleteTextView
import android.widget.Spinner
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import com.google.android.material.button.MaterialButton
import com.google.android.material.button.MaterialButtonToggleGroup
import com.google.android.material.textfield.TextInputEditText
import com.google.android.material.textfield.TextInputLayout
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.data.model.UrlData
import com.newagedevs.url_shortener.ui.viewmodel.UrlViewModel
import com.newagedevs.url_shortener.utils.Providers
import dagger.hilt.android.AndroidEntryPoint


@AndroidEntryPoint
class ShortenerFragment : Fragment(R.layout.fragment_shortener) {

    private lateinit var inputUrlLayout: TextInputLayout
    private lateinit var providerDropDownLayout: TextInputLayout
    private lateinit var inputUrl: TextInputEditText

    private lateinit var providerDropDown: AutoCompleteTextView

    private lateinit var actionButton: MaterialButton

    private lateinit var toggleButtonGroup: MaterialButtonToggleGroup


    private val viewModel: UrlViewModel by viewModels()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        inputUrl = view.findViewById(R.id.input_url)
        inputUrlLayout = view.findViewById(R.id.urlInputLayout)
        providerDropDownLayout = view.findViewById(R.id.provider_dropdown_layout)
        actionButton = view.findViewById(R.id.shorten_button)
        providerDropDown = view.findViewById(R.id.provider_dropdown)
        toggleButtonGroup = view.findViewById(R.id.toggleButton)

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

        setupProviderSpinner()

        actionButton.setOnClickListener {
            val longUrl = inputUrl.text.toString()
            val selectedProvider = providerDropDown.text.toString()

            if (longUrl.isNotEmpty()) {
                val shortenedUrlLiveData = viewModel.shortenUrl(selectedProvider, longUrl)
                shortenedUrlLiveData.observe(viewLifecycleOwner) {

                    if(it.success == true) {
                        val args = Bundle()
                        args.putString("uri", it.toString())
                        findNavController().navigate(R.id.action_shortenerFragment_to_resultFragment, args)
                    } else {
                        run {
                            Toast.makeText(requireContext(), "Failed to shorten URL", Toast.LENGTH_SHORT).show()
                        }
                    }

                }
            } else {
                Toast.makeText(requireContext(), "Please enter a URL", Toast.LENGTH_SHORT).show()
            }
        }

    }

    private fun setupProviderSpinner() {
        val adapter = ArrayAdapter(requireContext(), android.R.layout.simple_spinner_item, Providers.list)
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        providerDropDown.setAdapter(adapter)
    }

}
