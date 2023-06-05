package com.newagedevs.url_shortener.view.viewholder

import android.app.Activity
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.databinding.ViewShortenUrlItemBinding
import com.newagedevs.url_shortener.extensions.shareUrl
import com.newagedevs.url_shortener.extensions.toast
import com.newagedevs.url_shortener.model.Shortly
import com.newagedevs.url_shortener.view.ui.main.MainViewModel
import com.skydoves.baserecyclerviewadapter.BaseViewHolder


class ShortlyViewHolder(view: View, val viewModel:MainViewModel) : BaseViewHolder(view) {

  private lateinit var data: Shortly
  private val binding: ViewShortenUrlItemBinding by bindings()

  override fun bindData(data: Any) {
    if (data is Shortly) {
      this.data = data
      drawItemUI()
    }
  }

  private fun drawItemUI() {
    binding.apply {
      shortly = data
      executePendingBindings()
    }
  }

  override fun onClick(view: View) {

  }

  override fun onLongClick(p0: View?):Boolean {

    val dialog = BottomSheetDialog(context)
    val view = (context as Activity).layoutInflater.inflate(R.layout.bottom_sheet_menu_sheet, null)

    val bottomNavigationView = view.findViewById<BottomNavigationView>(R.id.tabs_bottom_nav)
    val shortenTextView = view.findViewById<TextView>(R.id.list_item_shorten)
    val expandedTextView = view.findViewById<TextView>(R.id.list_item_expanded)

    shortenTextView.text = data.shortUrl
    expandedTextView.text = data.longUrl

    val clipboard: ClipboardManager = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

    bottomNavigationView.setOnItemSelectedListener { it ->

      when (it.itemId) {
        R.id.bvn_open -> {
          context.startActivity(
            Intent(
              Intent.ACTION_VIEW,
              Uri.parse(data.shortUrl)
            )
          )
          dialog.cancel()
        }
        R.id.bvn_share -> {
          data.shortUrl?.let { it1 -> shareUrl(context, it1) }
        }
        R.id.bvn_delete -> {
          viewModel.deleteShortenUrl(data)
          dialog.cancel()
        }
        R.id.bvn_favorites -> {

        }
        R.id.bvn_copy_long_url -> {
          val clip = ClipData.newPlainText("Shortly", data.longUrl)
          clipboard.setPrimaryClip(clip)
          context.toast("Long urls copied!")
          dialog.cancel()
        }
        R.id.bvn_copy_short_url -> {
          val clip = ClipData.newPlainText("Shortly", data.shortUrl)
          clipboard.setPrimaryClip(clip)
          context.toast("Short urls copied!")
          dialog.cancel()
        }
        else -> {}
      }
      false
    }

    dialog.setCancelable(true)
    //dialog.window?.clearFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND)
    dialog.setContentView(view)
    dialog.show()

    return false
  }
}
