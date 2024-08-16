package com.newagedevs.url_shortener.ui.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import com.newagedevs.url_shortener.data.model.Osdb
import com.newagedevs.url_shortener.data.model.UrlData
import com.newagedevs.url_shortener.data.repository.UrlRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class UrlViewModel @Inject constructor(
    private val repository: UrlRepository
) : ViewModel() {

    fun shortenUrl(provider: String, longUrl: String): LiveData<UrlData> {
        return when (provider) {
            "TinyURL" -> repository.shortenWithTinyUrl(longUrl)
            "Chilp.it" -> repository.shortenWithChilpIt(longUrl)
            "Clck.ru" -> repository.shortenWithClckRu(longUrl)
            "Da.gd" -> repository.shortenWithDaGd(longUrl)
            "Is.gd" -> repository.shortenWithIsGd(longUrl)
            "Osdb" -> repository.shortenWithOsdb(Osdb(longUrl))
            "Cutt.ly" -> repository.shortenWithCuttly("", longUrl)
            else -> throw IllegalArgumentException("Unknown provider")
        }
    }

}

