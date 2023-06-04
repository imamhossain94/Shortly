package com.newagedevs.url_shortener.view.ui.fragments

import android.content.ClipboardManager
import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.InputMethodManager
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.view.ui.main.MainViewModel
import com.skydoves.bindables.BindingFragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.ViewModelProvider
import com.newagedevs.url_shortener.databinding.FragmentExpanderBinding
import com.newagedevs.url_shortener.extensions.onLeftDrawableClicked
import com.newagedevs.url_shortener.view.adapter.ShortlyAdapter
import com.newagedevs.url_shortener.view.base.FragmentInfo
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
      adapter = ShortlyAdapter()
    }.root
  }

  override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    super.onViewCreated(view, savedInstanceState)
    binding.fragmentUrlView.onLeftDrawableClicked {
      val clipboard = (mContext?.getSystemService(Context.CLIPBOARD_SERVICE)) as? ClipboardManager
      val textToPaste: CharSequence? = clipboard?.primaryClip?.getItemAt(0)?.text ?: null
      binding.fragmentUrlView.setText(textToPaste)
      if(textToPaste != null) {
        binding.fragmentUrlView.setSelection(textToPaste.length)

        binding.fragmentUrlView.requestFocus()
        binding.fragmentUrlView.postDelayed({
          val inputMethodManager =
            mContext?.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager?
          inputMethodManager!!.showSoftInput(binding.fragmentUrlView, InputMethodManager.SHOW_IMPLICIT)
        }, 200)

      }
    }
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
