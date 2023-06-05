package com.newagedevs.url_shortener.extensions

import android.annotation.SuppressLint
import android.app.Activity
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.MotionEvent
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.TextView
import androidx.appcompat.widget.AppCompatEditText
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.model.Expander
import com.newagedevs.url_shortener.model.Shortly
import com.newagedevs.url_shortener.view.ui.main.MainViewModel

fun View.visible() {
  visibility = View.VISIBLE
}

@SuppressLint("ClickableViewAccessibility")
fun AppCompatEditText.onDrawableClicked(context: Context) {
  this.setOnTouchListener { _, event ->
    if (event.action == MotionEvent.ACTION_UP) {
      if (event.rawX <= (this.right - this.compoundDrawables[0].bounds.width())) {

        val clipboard = (context.getSystemService(Context.CLIPBOARD_SERVICE)) as? ClipboardManager
        val textToPaste: CharSequence? = clipboard?.primaryClip?.getItemAt(0)?.text ?: null

        this.setText(textToPaste)

        if(textToPaste != null) {
          this.setSelection(textToPaste.length)

          this.requestFocus()
          this.postDelayed({

            val inputMethodManager =
              context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager?
            inputMethodManager!!.showSoftInput(this, InputMethodManager.SHOW_IMPLICIT)

          }, 200)
        }
        
        return@setOnTouchListener true
      }
      if (event.rawX >= (this.right - this.compoundDrawables[2].bounds.width())) {
        this.text = null
        return@setOnTouchListener true
      }
    }
    false
  }
}

fun onItemLongClick(context: Context, viewModel: MainViewModel, data: Any):Boolean {

  var shortUrl: String? = null
  var longUrl: String? = null

  if(data is Shortly) {
    shortUrl = data.shortUrl
    longUrl = data.longUrl
  }

  if(data is Expander) {
    shortUrl = data.shortUrl
    longUrl = data.longUrl
  }

  val dialog = BottomSheetDialog(context)
  val view = (context as Activity).layoutInflater.inflate(R.layout.bottom_sheet_menu_sheet, null)

  val bottomNavigationView = view.findViewById<BottomNavigationView>(R.id.tabs_bottom_nav)
  val shortenTextView = view.findViewById<TextView>(R.id.list_item_shorten)
  val expandedTextView = view.findViewById<TextView>(R.id.list_item_expanded)

  shortenTextView.text = shortUrl
  expandedTextView.text = longUrl

  val clipboard: ClipboardManager = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

  bottomNavigationView.setOnItemSelectedListener { it ->

    when (it.itemId) {
      R.id.bvn_open -> {
        context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(shortUrl)))
        dialog.cancel()
      }
      R.id.bvn_share -> {
        shortUrl?.let { it1 -> shareUrl(context, it1) }
      }
      R.id.bvn_delete -> {
        if(data is Shortly) { viewModel.deleteShortenUrl(data) }
        if(data is Expander) { viewModel.deleteExpandedUrl(data) }
        context.toast("Url deleted!")
        dialog.cancel()
      }
      R.id.bvn_favorites -> {
        if(data is Shortly) { viewModel.addFavoritesShortenUrl(data) }
        if(data is Expander) { viewModel.addFavoritesExpandedUrl(data) }
        context.toast("Url added to favorites!")
        dialog.cancel()
      }
      R.id.bvn_copy_long_url -> {
        val clip = ClipData.newPlainText("Shortly", longUrl)
        clipboard.setPrimaryClip(clip)
        context.toast("Long urls copied!")
        dialog.cancel()
      }
      R.id.bvn_copy_short_url -> {
        val clip = ClipData.newPlainText("Shortly", shortUrl)
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

fun onFavoritesItemLongClick(context: Context, viewModel: MainViewModel, data: Any):Boolean {

  var shortUrl: String? = null
  var longUrl: String? = null

  if(data is Shortly) {
    shortUrl = data.shortUrl
    longUrl = data.longUrl
  }

  if(data is Expander) {
    shortUrl = data.shortUrl
    longUrl = data.longUrl
  }

  val dialog = BottomSheetDialog(context)
  val view = (context as Activity).layoutInflater.inflate(R.layout.bottom_sheet_favorites_menu_sheet, null)

  val bottomNavigationView = view.findViewById<BottomNavigationView>(R.id.tabs_bottom_nav)
  val shortenTextView = view.findViewById<TextView>(R.id.list_item_shorten)
  val expandedTextView = view.findViewById<TextView>(R.id.list_item_expanded)

  shortenTextView.text = shortUrl
  expandedTextView.text = longUrl

  val clipboard: ClipboardManager = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

  bottomNavigationView.setOnItemSelectedListener { it ->

    when (it.itemId) {
      R.id.bvn_open -> {
        context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(shortUrl)))
        dialog.cancel()
      }
      R.id.bvn_share -> {
        shortUrl?.let { it1 -> shareUrl(context, it1) }
      }
      R.id.bvn_delete -> {
        if(data is Shortly) { viewModel.removeFavoritesShortenUrl(data) }
        if(data is Expander) { viewModel.removeFavoritesExpandedUrl(data) }
        context.toast("Url deleted!")
        dialog.cancel()
      }
      R.id.bvn_copy_long_url -> {
        val clip = ClipData.newPlainText("Shortly", longUrl)
        clipboard.setPrimaryClip(clip)
        context.toast("Long urls copied!")
        dialog.cancel()
      }
      R.id.bvn_copy_short_url -> {
        val clip = ClipData.newPlainText("Shortly", shortUrl)
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
