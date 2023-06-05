package com.newagedevs.url_shortener.view.adapter

import android.view.View
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.model.Expander
import com.newagedevs.url_shortener.model.Shortly
import com.newagedevs.url_shortener.view.ui.main.MainViewModel
import com.newagedevs.url_shortener.view.viewholder.ExpandedViewHolder
import com.newagedevs.url_shortener.view.viewholder.ShortlyViewHolder
import com.skydoves.baserecyclerviewadapter.BaseAdapter
import com.skydoves.baserecyclerviewadapter.SectionRow

class ExpanderAdapter(val viewModel: MainViewModel, private val isFavorites:Boolean = false) : BaseAdapter() {

  init {
    addSection(arrayListOf<Expander>())
  }

  fun addExpandedUrls(expandedUrls: List<Expander>?) {
    sections().first().run {
      clear()
      expandedUrls?.let { addAll(it) }
      notifyDataSetChanged()
    }
  }

  override fun layout(sectionRow: SectionRow) = R.layout.view_expanded_url_item

  override fun viewHolder(layout: Int, view: View) = ExpandedViewHolder(view, viewModel, isFavorites)
}