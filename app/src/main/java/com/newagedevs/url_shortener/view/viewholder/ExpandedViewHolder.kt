package com.newagedevs.url_shortener.view.viewholder

import android.view.View
import com.newagedevs.url_shortener.databinding.ViewExpandedUrlItemBinding
import com.newagedevs.url_shortener.extensions.onFavoritesItemLongClick
import com.newagedevs.url_shortener.extensions.onItemLongClick
import com.newagedevs.url_shortener.model.Expander
import com.newagedevs.url_shortener.view.ui.main.MainViewModel
import com.skydoves.baserecyclerviewadapter.BaseViewHolder

class ExpandedViewHolder(view: View, val viewModel: MainViewModel, val isFavorites:Boolean = false) : BaseViewHolder(view) {

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

  override fun onLongClick(p0: View?) =
    if (isFavorites) onFavoritesItemLongClick(context, viewModel, data)
    else onItemLongClick(context, viewModel, data)

}
