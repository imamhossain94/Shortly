package com.newagedevs.url_shortener.view.ui.fragments

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.AdapterView
import android.widget.ArrayAdapter
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.databinding.FragmentShorteneBinding
import com.newagedevs.url_shortener.extensions.onDrawableClicked
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
          adapter = ShortlyAdapter(vm)
        }.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        mContext?.let { binding.fragmentUrlView.onDrawableClicked(it) }

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
        val spinner = binding.providerPickerSpinner

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
