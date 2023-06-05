package com.newagedevs.url_shortener.view.viewholder

import android.view.View
import com.newagedevs.url_shortener.databinding.ViewShortenUrlItemBinding
import com.newagedevs.url_shortener.extensions.onFavoritesItemLongClick
import com.newagedevs.url_shortener.extensions.onItemLongClick
import com.newagedevs.url_shortener.model.Shortly
import com.newagedevs.url_shortener.view.ui.main.MainViewModel
import com.skydoves.baserecyclerviewadapter.BaseViewHolder


class ShortlyViewHolder(view: View, val viewModel:MainViewModel, private val isFavorites:Boolean) : BaseViewHolder(view) {

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

  override fun onLongClick(p0: View?) =
    if (isFavorites) onFavoritesItemLongClick(context, viewModel, data)
    else onItemLongClick(context, viewModel, data)

}
