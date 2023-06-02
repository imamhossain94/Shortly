package com.newagedevs.url_shortener.view.viewholder

import androidx.databinding.DataBindingUtil
import androidx.databinding.ViewDataBinding
import com.skydoves.baserecyclerviewadapter.BaseViewHolder

inline fun <reified T : ViewDataBinding> BaseViewHolder.bindings(): Lazy<T> =
  lazy(LazyThreadSafetyMode.NONE) {
    requireNotNull(DataBindingUtil.bind(itemView)) { "cannot find the matched view to layout." }
  }
