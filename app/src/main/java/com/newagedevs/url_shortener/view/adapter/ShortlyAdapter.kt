package com.newagedevs.url_shortener.view.adapter

import android.view.View
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.model.Shortly
import com.newagedevs.url_shortener.view.ui.main.MainViewModel
import com.newagedevs.url_shortener.view.viewholder.ShortlyViewHolder
import com.skydoves.baserecyclerviewadapter.BaseAdapter
import com.skydoves.baserecyclerviewadapter.SectionRow

class ShortlyAdapter(val viewModel: MainViewModel) : BaseAdapter() {

  init {
    addSection(arrayListOf<Shortly>())
  }

  fun addShortenUrls(shortenUrls: List<Shortly>) {
    sections().first().run {
      clear()
      addAll(shortenUrls)
      notifyDataSetChanged()
    }
  }

  override fun layout(sectionRow: SectionRow) = R.layout.view_shorten_url_item

  override fun viewHolder(layout: Int, view: View) = ShortlyViewHolder(view, viewModel)
}