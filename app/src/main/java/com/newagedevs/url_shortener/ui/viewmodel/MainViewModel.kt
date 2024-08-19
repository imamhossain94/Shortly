package com.newagedevs.url_shortener.ui.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.newagedevs.url_shortener.data.model.UrlData
import com.newagedevs.url_shortener.data.repository.UrlRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class MainViewModel @Inject constructor(
    private val repository: UrlRepository
) : ViewModel() {

    val historyLiveData: LiveData<List<UrlData>> = repository.getHistory()

    fun deleteUrl(urlData: UrlData) {
        repository.deleteUrl(urlData)
    }

}

