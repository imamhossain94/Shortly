package com.newagedevs.url_shortener.view.ui.fragments

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.databinding.FragmentExpanderBinding
import com.newagedevs.url_shortener.extensions.onDrawableClicked
import com.newagedevs.url_shortener.view.adapter.ExpanderAdapter
import com.newagedevs.url_shortener.view.base.FragmentInfo
import com.newagedevs.url_shortener.view.ui.main.MainViewModel
import com.skydoves.bindables.BindingFragment
import org.koin.android.viewmodel.ext.android.sharedViewModel

class ExpanderFragment : BindingFragment<FragmentExpanderBinding>(R.layout.fragment_expander), FragmentInfo {

  private val vm: MainViewModel by sharedViewModel()
  var mContext: Context? = null

  override fun onAttach(context: Context) {
    super.onAttach(context)
    mContext = context
  }

  override fun onCreateView(
    inflater: LayoutInflater,
    container: ViewGroup?,
    savedInstanceState: Bundle?
  ): View {
    super.onCreateView(inflater, container, savedInstanceState)
    return binding {
      viewModel = vm
      adapter = ExpanderAdapter()
    }.root
  }

  override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    super.onViewCreated(view, savedInstanceState)

    mContext?.let { binding.fragmentUrlView.onDrawableClicked(it) }

  }

  override fun layoutResId(): Int {
    return R.layout.fragment_shortene
  }

  override fun iconResId(): Int {
    return R.drawable.ic_link_svgrepo_com
  }

  override fun title(): CharSequence {
    return "URL Expander"
  }

  override fun isAppBarEnabled(): Boolean {
    return true
  }



}
