package com.newagedevs.url_shortener.ui.activities

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.google.android.material.appbar.MaterialToolbar
import com.google.android.material.button.MaterialButton
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.data.model.UrlData
import com.newagedevs.url_shortener.ui.viewmodel.UrlViewModel
import com.newagedevs.url_shortener.utils.shareUrl
import dagger.hilt.android.AndroidEntryPoint
import qrcode.QRCode

@AndroidEntryPoint
class ResultActivity : AppCompatActivity() {

    private val viewModel: UrlViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_result)

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.result_main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        val titleText = findViewById<TextView>(R.id.title)
        val shortUrlText = findViewById<TextView>(R.id.short_url)
        val expendedUrlText = findViewById<TextView>(R.id.expended_url)
        val qrCodeImageView = findViewById<ImageView>(R.id.qr_code_image)
        val shareButton = findViewById<MaterialButton>(R.id.share_button)
        val copyButton = findViewById<MaterialButton>(R.id.copy_button)
        val deleteButton = findViewById<MaterialButton>(R.id.delete_button)
        val topAppBar = findViewById<MaterialToolbar>(R.id.topAppBar)

        topAppBar.setNavigationOnClickListener { finish() }

        // Get URL data
        val urlData: UrlData = intent.getParcelableExtra("url_data") ?: run {
            Toast.makeText(this, "Invalid data", Toast.LENGTH_SHORT).show()
            finish()
            return
        }

        // Set title
        titleText.setText(if (urlData.originalUrl == urlData.expandedUrl) R.string.shortened else R.string.expanded)

        // Set URLs
        shortUrlText.text = urlData.shortenedUrl?.trim()
        expendedUrlText.text = urlData.expandedUrl?.trim()

        // Long-press to copy
        shortUrlText.setOnLongClickListener {
            copyUrl(urlData.shortenedUrl, isShort = true)
            true
        }
        expendedUrlText.setOnLongClickListener {
            copyUrl(urlData.expandedUrl, isShort = false)
            true
        }

        // Button actions
        shareButton.setOnClickListener {
            val urlToShare = urlData.shortenedUrl ?: urlData.expandedUrl
            if (!urlToShare.isNullOrBlank()) {
                shareUrl(this, urlToShare)
            } else {
                showToast("Cannot share URL")
            }
        }

        copyButton.setOnClickListener {
            val urlToCopy = urlData.shortenedUrl ?: urlData.expandedUrl
            copyUrl(urlToCopy, isShort = urlData.shortenedUrl != null)
        }

        deleteButton.setOnClickListener {
            MaterialAlertDialogBuilder(this)
                .setTitle(R.string.delete_url)
                .setMessage(R.string.confirm_delete)
                .setNegativeButton(R.string.cancel, null)
                .setPositiveButton(R.string.delete) { _, _ ->
                    viewModel.deleteUrl(urlData)
                    finish()
                }
                .show()
        }

        // Generate QR code
        try {
            val qrColor = ContextCompat.getColor(this, R.color.qr_core_color)
            val qrCode = QRCode.ofRoundedSquares()
                .withColor(qrColor)
                .withBackgroundColor(Color.TRANSPARENT)
                .withSize(10)
                .build(urlData.shortenedUrl ?: urlData.originalUrl ?: "")

            val byteArray = qrCode.renderToBytes()
            val bmp = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)
            qrCodeImageView.setImageBitmap(bmp)
        } catch (e: Exception) {
            e.printStackTrace()
//            qrCodeImageView.setImageResource(R.drawable.ic_broken_image)
        }
    }

    private fun copyUrl(url: String?, isShort: Boolean) {
        if (url.isNullOrBlank()) {
            showToast("URL is empty")
            return
        }

        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        clipboard.setPrimaryClip(ClipData.newPlainText("Shortly", url))
        val message = if (isShort) "Short URL copied!" else "Expanded URL copied!"
        showToast(message)
    }

    private fun showToast(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }
}