package com.newagedevs.url_shortener.view.ui.fragments

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.databinding.FragmentFavoritesBinding
import com.newagedevs.url_shortener.view.base.FragmentInfo
import com.newagedevs.url_shortener.view.ui.main.MainViewModel
import com.skydoves.bindables.BindingFragment
import org.koin.android.viewmodel.ext.android.sharedViewModel

class FavoriteFragment : BindingFragment<FragmentFavoritesBinding>(R.layout.fragment_favorites), FragmentInfo {

  private val vm: MainViewModel by sharedViewModel()

  override fun onCreateView(
    inflater: LayoutInflater,
    container: ViewGroup?,
    savedInstanceState: Bundle?
  ): View {
    super.onCreateView(inflater, container, savedInstanceState)
    return binding {
      viewModel = vm
    }.root
  }


  override fun layoutResId(): Int {
    return R.layout.fragment_shortene
  }

  override fun iconResId(): Int {
    return R.drawable.ic_heart_svgrepo_com
  }

  override fun title(): CharSequence {
    return "Favorites"
  }

  override fun isAppBarEnabled(): Boolean {
    return true
  }

}
