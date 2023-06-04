package com.newagedevs.url_shortener.view.viewholder

import android.app.Activity
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.databinding.ViewExpandedUrlItemBinding
import com.newagedevs.url_shortener.databinding.ViewShortenUrlItemBinding
import com.newagedevs.url_shortener.model.Expander
import com.newagedevs.url_shortener.model.Shortly
import com.skydoves.baserecyclerviewadapter.BaseViewHolder
import dev.oneuiproject.oneui.dialog.GridMenuDialog
import dev.oneuiproject.oneui.dialog.GridMenuDialog.GridMenuItem
import timber.log.Timber

class ExpandedViewHolder(view: View) : BaseViewHolder(view) {

  private lateinit var data: Expander
  private val binding: ViewExpandedUrlItemBinding by bindings()

  override fun bindData(data: Any) {
    if (data is Expander) {
      this.data = data
      drawItemUI()
    }
  }

  private fun drawItemUI() {
    binding.apply {
      expander = data
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

//    bottomNavigationView.setOnItemSelectedListener {
//
//    }

    dialog.setCancelable(true)
    dialog.window?.clearFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND)
    dialog.setContentView(view)
    dialog.show()

    return false
  }
}
