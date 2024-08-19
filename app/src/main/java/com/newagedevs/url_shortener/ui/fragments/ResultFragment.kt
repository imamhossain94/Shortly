package com.newagedevs.url_shortener.ui.fragments

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.fragment.app.Fragment
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.data.model.UrlData
import dagger.hilt.android.AndroidEntryPoint
import qrcode.QRCode



@AndroidEntryPoint
class ResultFragment : Fragment(R.layout.fragment_result) {

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val titleText: TextView = view.findViewById(R.id.title)
        val shortUrlText: TextView = view.findViewById(R.id.short_url)
        val expendedUrlText: TextView = view.findViewById(R.id.expended_url)
        val qrCodeImageView = view.findViewById<ImageView>(R.id.qr_code_image)


        val receivedUrlData: UrlData = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            arguments?.getParcelable("url_data", UrlData::class.java)!!
        } else {
            @Suppress("DEPRECATION")
            arguments?.getParcelable("url_data")!!
        }

        titleText.text = if (receivedUrlData.originalUrl == receivedUrlData.expandedUrl) "Shortened" else "Expended"
        shortUrlText.text = receivedUrlData.shortenedUrl
        expendedUrlText.text = receivedUrlData.expandedUrl

        val qrCode = QRCode.ofRoundedSquares()
            .withBackgroundColor(Color.TRANSPARENT)
            .withSize(10)
            .build(receivedUrlData.shortenedUrl ?: "")

        val byteArray = qrCode.renderToBytes()

        val bmp = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)

        qrCodeImageView.setImageBitmap(bmp)
    }
}
