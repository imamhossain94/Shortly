package com.newagedevs.url_shortener.view.ui.main

import android.view.KeyEvent
import android.view.View
import android.view.inputmethod.EditorInfo
import android.widget.Toast
import androidx.annotation.WorkerThread
import androidx.databinding.Bindable
import androidx.lifecycle.viewModelScope
import com.newagedevs.url_shortener.model.Shortly
import com.newagedevs.url_shortener.repository.ShortlyRepository
import com.newagedevs.url_shortener.utils.Urls
import com.skydoves.bindables.BindingViewModel
import com.skydoves.bindables.asBindingProperty
import com.skydoves.bindables.bindingProperty
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.launch
import timber.log.Timber


class MainViewModel constructor(
    private val repository: ShortlyRepository
) : BindingViewModel() {

    @get:Bindable
    var toast: String? by bindingProperty(null)

    @get:Bindable
    var provider: String by bindingProperty(Urls.tinyurl)

    @get:Bindable
    var isLoading: Boolean by bindingProperty(true)
        private set

    @get:Bindable
    var shortenUrls: List<Shortly>? by bindingProperty(repository.loadShortenUrls())


    fun onShortUrl(view: View, actionId: Int, event: KeyEvent?): Boolean {
        if(actionId == EditorInfo.IME_ACTION_GO) {
            val editText = view as androidx.appcompat.widget.AppCompatEditText
            val horseDetailFlow = repository.short(provider, editText.text.toString(), viewModelScope) {}

            viewModelScope.launch {
                horseDetailFlow.collect { value ->


                    shortenUrls = repository.loadShortenUrls()
                }
            }

            return true
        }
        return false
    }





    @OptIn(ExperimentalCoroutinesApi::class)
    private fun initializeData() {

        val horseDetailFlow = repository.short(provider, "https://stackoverflow.com/questions/5677563/listener-for-done-button-on-edittext", viewModelScope) {
            Timber.d("________________________________");
            Timber.d(it)
            Timber.d("________________________________");
        }

        viewModelScope.launch {
            horseDetailFlow.collect { value ->
                shortenUrls = repository.loadShortenUrls()
            }
        }


    }

    init {
        Timber.d("injection DashboardViewModel")
        initializeData()
    }

}


