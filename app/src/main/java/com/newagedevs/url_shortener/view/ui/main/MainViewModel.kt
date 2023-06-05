package com.newagedevs.url_shortener.view.ui.main

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


class MainViewModel constructor(
    private val shortlyRepository: ShortlyRepository,
    private val expanderRepository: ExpanderRepository
) : BindingViewModel() {

    @get:Bindable
    var toast: String? by bindingProperty(null)

    @get:Bindable
    var provider: String by bindingProperty(Urls.tinyurl)

    @get:Bindable
    var favoriteTab: String by bindingProperty(Tabs.short)

    @get:Bindable
    var isLoading: Boolean by bindingProperty(false)
        private set

    @get:Bindable
    var shortenUrls: List<Shortly>? by bindingProperty(listOf())

    @get:Bindable
    var expandedUrls: List<Expander>? by bindingProperty(listOf())

    @get:Bindable
    var favoriteShortenUrls: List<Shortly>? by bindingProperty(listOf())

    @get:Bindable
    var favoriteExpandedUrls: List<Expander>? by bindingProperty(listOf())


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
                    shortenUrls = shortlyRepository.loadShortenUrls()
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
                    expandedUrls = expanderRepository.loadExpandedUrls()
                    toast(value)
                }
            }

            return true
        }
        return false
    }

    fun deleteShortenUrl(shortly: Shortly) {
        shortlyRepository.delete(shortly)
        shortenUrls = shortlyRepository.loadShortenUrls()
    }


    fun changeFavoriteTabs(value: String) {
        favoriteTab = value
        if(Tabs.short == value) {
            favoriteExpandedUrls = emptyList()
            favoriteShortenUrls = shortlyRepository.loadFavoritesShortenUrls()
        }else{
            favoriteShortenUrls = emptyList()
            favoriteExpandedUrls = expanderRepository.loadFavoritesExpandedUrls()
        }
    }

    private fun initializeData() {
        shortenUrls = shortlyRepository.loadShortenUrls()
        expandedUrls = expanderRepository.loadExpandedUrls()

        favoriteShortenUrls = shortlyRepository.loadFavoritesShortenUrls()
        //favoriteExpandedUrls = expanderRepository.loadFavoritesExpandedUrls()
    }

    init {
        Timber.d("injection DashboardViewModel")
        initializeData()
    }

}


