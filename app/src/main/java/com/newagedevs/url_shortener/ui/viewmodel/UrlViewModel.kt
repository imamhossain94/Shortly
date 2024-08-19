package com.newagedevs.url_shortener.ui.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import com.newagedevs.url_shortener.data.model.Osdb
import com.newagedevs.url_shortener.data.model.UrlData
import com.newagedevs.url_shortener.data.repository.UrlRepository
import com.newagedevs.url_shortener.utils.Providers
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class UrlViewModel @Inject constructor(
    private val repository: UrlRepository
) : ViewModel() {

    fun shortenUrl(provider: String, longUrl: String): LiveData<UrlData> {
        return when (provider) {
            Providers.tinyurl -> repository.shortenWithTinyUrl(longUrl)
            Providers.chilpit -> repository.shortenWithChilpIt(longUrl)
            Providers.clckru -> repository.shortenWithClckRu(longUrl)
            Providers.dagd -> repository.shortenWithDaGd(longUrl)
            Providers.isgd -> repository.shortenWithIsGd(longUrl)
            Providers.osdb -> repository.shortenWithOsdb(Osdb(longUrl))
            Providers.cuttly -> repository.shortenWithCuttly("23cfc51f98e71afea0c6d454f084a255ffe16", longUrl)
            else -> throw IllegalArgumentException("Unknown provider")
        }
    }

    fun expendUrl(shortUrl: String): LiveData<UrlData> {
        return repository.expand(shortUrl)
    }

}

