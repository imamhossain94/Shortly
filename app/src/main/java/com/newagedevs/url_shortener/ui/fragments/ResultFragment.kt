package com.newagedevs.url_shortener.ui.fragments

import android.os.Bundle
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.fragment.app.Fragment
import com.google.gson.GsonBuilder
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.data.model.UrlData
import dagger.hilt.android.AndroidEntryPoint


@AndroidEntryPoint
class ResultFragment : Fragment(R.layout.fragment_result) {

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val shortUrlTextView = view.findViewById<TextView>(R.id.short_url_text)
        val expandedUrlTextView = view.findViewById<TextView>(R.id.expanded_url_text)
        val qrCodeImageView = view.findViewById<ImageView>(R.id.qr_code_image)


        val uri = arguments?.getString("uri")
        Toast.makeText(requireContext(), "URI: $uri", Toast.LENGTH_LONG).show()


        expandedUrlTextView.text = uri

//        val gson = GsonBuilder().create()
//        val data: UrlData = gson.fromJson(uri, UrlData::class.java)
//
//        shortUrlTextView.text = data.shortenedUrl
//        expandedUrlTextView.text = data.expandedUrl



    }
}
