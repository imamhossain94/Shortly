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
import com.newagedevs.url_shortener.utils.getUrl
import com.newagedevs.url_shortener.utils.shareUrl
import com.newagedevs.url_shortener.utils.showToast
import dagger.hilt.android.AndroidEntryPoint
import qrcode.QRCode


@AndroidEntryPoint
class ResultActivity : AppCompatActivity() {
    
    private val viewModel: UrlViewModel by viewModels()

    private lateinit var titleText: TextView
    private lateinit var shortUrlText: TextView
    private lateinit var expendedUrlText: TextView
    private lateinit var qrCodeImageView:ImageView
    private lateinit var shareButton:MaterialButton
    private lateinit var copyButton:MaterialButton
    private lateinit var deleteButton:MaterialButton
    private lateinit var topAppBar:MaterialToolbar
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_result)

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.result_main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        titleText = findViewById(R.id.title)
        shortUrlText = findViewById(R.id.short_url)
        expendedUrlText = findViewById(R.id.expended_url)
        qrCodeImageView = findViewById(R.id.qr_code_image)
        shareButton = findViewById(R.id.share_button)
        copyButton = findViewById(R.id.copy_button)
        deleteButton = findViewById(R.id.delete_button)
        topAppBar = findViewById(R.id.topAppBar)

        topAppBar.setNavigationOnClickListener { finish() }

        val urlData: UrlData = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra("url_data", UrlData::class.java)!!
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra("url_data")!!
        }

        titleText.text = if (urlData.originalUrl == urlData.expandedUrl) "Shortened" else "Expended"
        shortUrlText.text = urlData.shortenedUrl?.trim()
        expendedUrlText.text = urlData.expandedUrl?.trim()

        shareButton.setOnClickListener {
            val url = urlData.getUrl()

            if (url.second != null) {
                shareUrl(this, url.second!!)
            } else {
                this.showToast("Cannot share URL")
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
            MaterialAlertDialogBuilder(this)
                .setTitle("Delete URL")
                .setMessage("Are you sure you want to delete this URL? This action cannot be undone.")
                .setNegativeButton("Cancel") { dialog, _ ->
                    dialog.dismiss()
                }
                .setPositiveButton("Delete") { dialog, _ ->
                    viewModel.deleteUrl(urlData)
                    finish()
                    dialog.dismiss()
                }.show()
        }

        val qrcColor = ContextCompat.getColor(this, R.color.qr_core_color)
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
        val clipboard: ClipboardManager = this.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

        val (isShortUrl, url) = it
        if (url != null) {
            val clip = ClipData.newPlainText("Shortly", url)
            clipboard.setPrimaryClip(clip)
            this.showToast(if (isShortUrl) "Short URL copied!" else "Expanded URL copied!")
        } else {
            this.showToast("Cannot copy URL")
        }
    }


}