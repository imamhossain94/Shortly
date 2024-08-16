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

    private val _shortenUrlLiveData = MutableLiveData<UrlData>()
    val shortenUrlLiveData: LiveData<UrlData> = _shortenUrlLiveData

    private val _expandUrlLiveData = MutableLiveData<UrlData>()
    val expandUrlLiveData: LiveData<UrlData> = _expandUrlLiveData

//    fun shortenUrl(url: String) {
//        viewModelScope.launch {
//            val result = repository.shortenUrl(url)
//            _shortenUrlLiveData.postValue(result)
//            repository.saveUrl(result)  // Save the result to the database
//        }
//    }
//
//    fun expandUrl(url: String) {
//        viewModelScope.launch {
//            val result = repository.expandUrl(url)
//            _expandUrlLiveData.postValue(result)
//            repository.saveUrl(result)  // Save the result to the database
//        }
//    }
}

