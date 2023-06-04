package com.newagedevs.url_shortener.view.ui.fragments

import android.content.ClipboardManager
import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.InputMethodManager
import android.widget.AdapterView
import android.widget.ArrayAdapter
import androidx.core.content.ContextCompat.getSystemService
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.databinding.FragmentShorteneBinding
import com.newagedevs.url_shortener.extensions.onLeftDrawableClicked
import com.newagedevs.url_shortener.utils.Providers
import com.newagedevs.url_shortener.view.adapter.ShortlyAdapter
import com.newagedevs.url_shortener.view.base.FragmentInfo
import com.newagedevs.url_shortener.view.ui.main.MainViewModel
import com.skydoves.bindables.BindingFragment
import org.koin.android.viewmodel.ext.android.sharedViewModel


open class ShortenerFragment : BindingFragment<FragmentShorteneBinding>(R.layout.fragment_shortene),
    FragmentInfo, AdapterView.OnItemSelectedListener {

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
        initSpinner(view)
    }

    override fun layoutResId(): Int {
        return R.layout.fragment_shortene
    }

    override fun iconResId(): Int {
        return R.drawable.ic_link_short_svgrepo_com
    }

    override fun title(): CharSequence {
        return "URL Shortener"
    }

    override fun isAppBarEnabled(): Boolean {
        return true
    }

    private fun initSpinner(view: View) {
        val spinner = binding.apppickerSpinner

        val adapter = ArrayAdapter(requireContext(), android.R.layout.simple_spinner_item, Providers.list)
        adapter.setDropDownViewResource(androidx.appcompat.R.layout.support_simple_spinner_dropdown_item)
        spinner.adapter = adapter
        spinner.onItemSelectedListener = this
    }

    override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
        vm.provider = Providers.list[position]
    }

    override fun onNothingSelected(p0: AdapterView<*>?) {
        TODO("Not yet implemented")
    }


}
