package com.newagedevs.url_shortener.ui.fragments

import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import com.google.android.material.textfield.TextInputEditText
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.ui.viewmodel.MainViewModel
import dagger.hilt.android.AndroidEntryPoint


@AndroidEntryPoint
class ExpanderFragment : Fragment(R.layout.fragment_expander) {

    private val viewModel: MainViewModel by viewModels()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val expandButton = view.findViewById<Button>(R.id.expand_button)
        val urlInput = view.findViewById<TextInputEditText>(R.id.input_url)


        expandButton.setOnClickListener {
            val url = urlInput.text.toString()
            if (url.isNotEmpty()) {
//                viewModel.expandUrl(url)
            }
        }

        viewModel.shortenUrlLiveData.observe(viewLifecycleOwner) { urlData ->
            findNavController().navigate(R.id.nav_result)
        }
    }
}
