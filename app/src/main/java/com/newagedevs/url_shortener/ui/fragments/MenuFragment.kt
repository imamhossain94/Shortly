package com.newagedevs.url_shortener.ui.fragments

import android.os.Bundle
import android.view.View
import android.widget.Button
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import com.google.android.material.textfield.TextInputEditText
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.ui.viewmodel.MainViewModel
import dagger.hilt.android.AndroidEntryPoint


class MenuFragment : Fragment(R.layout.fragment_menu) {

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        // No specific action required for now
    }
}
