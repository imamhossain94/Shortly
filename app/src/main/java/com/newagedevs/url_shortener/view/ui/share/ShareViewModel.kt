package com.newagedevs.url_shortener.view.ui.share

import android.view.KeyEvent
import android.view.View
import android.view.inputmethod.EditorInfo
import androidx.databinding.Bindable
import androidx.lifecycle.viewModelScope
import com.newagedevs.url_shortener.model.Expander
import com.newagedevs.url_shortener.model.Shortly
import com.newagedevs.url_shortener.repository.ExpanderRepository
import com.newagedevs.url_shortener.repository.ShortlyRepository
import com.newagedevs.url_shortener.utils.Tabs
import com.newagedevs.url_shortener.utils.Urls
import com.skydoves.bindables.BindingViewModel
import com.skydoves.bindables.bindingProperty
import kotlinx.coroutines.launch
import timber.log.Timber

class ShareViewModel constructor(
    private val shortlyRepository: ShortlyRepository,
    private val expanderRepository: ExpanderRepository
) : BindingViewModel() {

    @get:Bindable
    var toast: String? by bindingProperty(null)

    @get:Bindable
    var provider: String by bindingProperty(Urls.tinyurl)

    @get:Bindable
    var isLoading: Boolean by bindingProperty(false)
        private set

    fun toast(title: String?) {
        toast = null
        toast = title
    }

    fun onShortUrl(view: View, actionId: Int, event: KeyEvent?): Boolean {
        if(actionId == EditorInfo.IME_ACTION_GO) {
            val editText = view as androidx.appcompat.widget.AppCompatEditText
            val flow = shortlyRepository.short(provider, editText.text.toString(), viewModelScope) {
                toast(it)
                isLoading = false
            }
            isLoading = true
            viewModelScope.launch {
                flow.collect { value ->
                    isLoading = false
                    // update ui with short url
                    toast(value)
                }
            }
            return true
        }
        return false
    }

    fun onExpandUrl(view: View, actionId: Int, event: KeyEvent?): Boolean {
        if(actionId == EditorInfo.IME_ACTION_GO) {
            val editText = view as androidx.appcompat.widget.AppCompatEditText
            val flow = expanderRepository.expand(editText.text.toString(), viewModelScope) {
                toast(it)
                isLoading = false
            }
            isLoading = true
            viewModelScope.launch {
                flow.collect { value ->
                    isLoading = false
                    // Update ui with long url
                    toast(value)
                }
            }
            return true
        }
        return false
    }

    init {
        Timber.d("injection DashboardViewModel")
    }

}


