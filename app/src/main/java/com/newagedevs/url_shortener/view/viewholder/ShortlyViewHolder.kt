package com.newagedevs.url_shortener.view.viewholder

import android.view.View
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.databinding.ViewShortenUrlItemBinding
import com.newagedevs.url_shortener.model.Shortly
import com.skydoves.baserecyclerviewadapter.BaseViewHolder
import dev.oneuiproject.oneui.dialog.GridMenuDialog
import dev.oneuiproject.oneui.dialog.GridMenuDialog.GridMenuItem

class ShortlyViewHolder(view: View) : BaseViewHolder(view) {

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
    val gridMenuDialog = GridMenuDialog(context)
    gridMenuDialog.inflateMenu(R.menu.tabs_grid_menu)
    gridMenuDialog.setOnItemClickListener { item: GridMenuItem? -> true }
  }

  override fun onLongClick(p0: View?) = false
}
