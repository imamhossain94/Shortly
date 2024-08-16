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
import com.google.android.material.textfield.TextInputEditText
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.data.model.UrlData
import com.newagedevs.url_shortener.ui.viewmodel.UrlViewModel
import dagger.hilt.android.AndroidEntryPoint


@AndroidEntryPoint
class ShortenerFragment : Fragment(R.layout.fragment_shortener) {

    private lateinit var inputUrl: TextInputEditText
    private lateinit var providerDropDown: AutoCompleteTextView
    private lateinit var shortenButton: MaterialButton

    private val viewModel: UrlViewModel by viewModels()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        inputUrl = view.findViewById(R.id.input_url)
        shortenButton = view.findViewById(R.id.shorten_button)
        providerDropDown = view.findViewById(R.id.provider_dropdown)

        setupProviderSpinner()

        shortenButton.setOnClickListener {
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
        val providers = listOf("TinyURL", "Chilp.it", "Clck.ru", "Da.gd", "Is.gd", "Osdb", "Cutt.ly")
        val adapter = ArrayAdapter(requireContext(), android.R.layout.simple_spinner_item, providers)
        //  adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        providerDropDown.setAdapter(adapter)
    }

}
