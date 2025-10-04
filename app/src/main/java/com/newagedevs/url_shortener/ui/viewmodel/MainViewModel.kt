package com.newagedevs.url_shortener.ui.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.newagedevs.url_shortener.data.local.SharedPref
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class MainViewModel @Inject constructor(
    private val sharedPref: SharedPref
) : ViewModel() {

    private val _isProUser = MutableLiveData<Boolean>()
    private val _productPrice = MutableLiveData<String>()
    private val _clickCount = MutableLiveData<Int>()

    val isProUser: LiveData<Boolean> = _isProUser
    val productPrice: LiveData<String> = _productPrice
    val clickCount: LiveData<Int> = _clickCount

    init {
        checkProStatus()
        checkClickCount()
    }

    fun setPro(value: Boolean) {
//        sharedPref.setPro(value)
//        _isProUser.value = value
    }

    fun setProductPrice(value: String) {
        _productPrice.value = value
    }

    private fun checkProStatus() {
        _isProUser.value = sharedPref.isPro()
    }

    private fun checkClickCount() {
        _clickCount.value = sharedPref.clickCount()
    }

    fun resetClickCount() {
        sharedPref.resetClickCount()
        _clickCount.value = 0
    }

    fun incrementClickCount() {
        val currentCount = _clickCount.value ?: 0
        val newCount = currentCount + 1
        sharedPref.clickCount(newCount)
        _clickCount.value = newCount
    }

}

