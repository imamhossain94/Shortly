package com.newagedevs.url_shortener.ui.fragments

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.activity.addCallback
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import com.google.android.material.button.MaterialButton
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.data.model.UrlData
import com.newagedevs.url_shortener.ui.viewmodel.MainViewModel
import com.newagedevs.url_shortener.utils.getUrl
import com.newagedevs.url_shortener.utils.shareUrl
import com.newagedevs.url_shortener.utils.showToast
import dagger.hilt.android.AndroidEntryPoint
import qrcode.QRCode
import qrcode.color.Colors


@AndroidEntryPoint
class ResultFragment : Fragment(R.layout.fragment_result) {

    private val viewModel: MainViewModel by activityViewModels()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val titleText: TextView = view.findViewById(R.id.title)
        val shortUrlText: TextView = view.findViewById(R.id.short_url)
        val expendedUrlText: TextView = view.findViewById(R.id.expended_url)
        val qrCodeImageView = view.findViewById<ImageView>(R.id.qr_code_image)
        val shareButton = view.findViewById<MaterialButton>(R.id.share_button)
        val copyButton = view.findViewById<MaterialButton>(R.id.copy_button)
        val deleteButton = view.findViewById<MaterialButton>(R.id.delete_button)


        val urlData: UrlData = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            arguments?.getParcelable("url_data", UrlData::class.java)!!
        } else {
            @Suppress("DEPRECATION")
            arguments?.getParcelable("url_data")!!
        }

        titleText.text = if (urlData.originalUrl == urlData.expandedUrl) "Shortened" else "Expended"
        shortUrlText.text = urlData.shortenedUrl?.trim()
        expendedUrlText.text = urlData.expandedUrl?.trim()

        shareButton.setOnClickListener {
            val url = urlData.getUrl()

            if (url.second != null) {
                shareUrl(requireContext(), url.second!!)
            } else {
                requireContext().showToast("Cannot share URL")
            }
        }

        shortUrlText.setOnLongClickListener {
            copyURL(Pair(true, urlData.shortenedUrl))
            return@setOnLongClickListener true
        }

        expendedUrlText.setOnLongClickListener {
            copyURL(Pair(false, urlData.expandedUrl))
            return@setOnLongClickListener true
        }

        copyButton.setOnClickListener {
            copyURL(urlData.getUrl())
        }

        deleteButton.setOnClickListener {

            MaterialAlertDialogBuilder(requireContext())
                .setTitle("Delete URL")
                .setMessage("Are you sure you want to delete this URL? This action cannot be undone.")
                .setNegativeButton("Cancel") { dialog, _ ->
                    dialog.dismiss()
                }
                .setPositiveButton("Delete") { dialog, _ ->
                    viewModel.deleteUrl(urlData)
                    findNavController().navigateUp()
                    dialog.dismiss()
                }.show()
        }

        requireActivity().onBackPressedDispatcher.addCallback(viewLifecycleOwner) {
            findNavController().navigateUp()
        }

        val qrcColor = ContextCompat.getColor(requireContext(), R.color.qr_core_color)
        val qrCode = QRCode.ofRoundedSquares()
            .withColor(qrcColor)
            .withBackgroundColor(Color.TRANSPARENT)
            .withSize(10)
            .build(urlData.shortenedUrl ?: "")

        val byteArray = qrCode.renderToBytes()

        val bmp = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)

        qrCodeImageView.setImageBitmap(bmp)
    }

    private fun copyURL(it: Pair<Boolean, String?>) {
        val clipboard: ClipboardManager = requireContext().getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

        val (isShortUrl, url) = it
        if (url != null) {
            val clip = ClipData.newPlainText("Shortly", url)
            clipboard.setPrimaryClip(clip)
            requireContext().showToast(if (isShortUrl) "Short URL copied!" else "Expanded URL copied!")
        } else {
            requireContext().showToast("Cannot copy URL")
        }
    }

}
