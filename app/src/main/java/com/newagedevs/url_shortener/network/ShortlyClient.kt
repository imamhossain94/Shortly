package com.newagedevs.url_shortener.network

import com.newagedevs.url_shortener.BuildConfig
import com.newagedevs.url_shortener.model.cuttly.Cuttly
import com.newagedevs.url_shortener.model.osdb.Osdb
import com.newagedevs.url_shortener.utils.Providers
import com.newagedevs.url_shortener.utils.Urls
import com.skydoves.sandwich.ApiResponse
import com.skydoves.sandwich.request
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

class ShortlyClient(private val service: ShortlyService) {

    fun tinyurl(
        longUrl: String,
        coroutineScope: CoroutineScope,
        onResult: suspend (response: ApiResponse<String>, provider: String, longUrl: String) -> Unit
    ) {
        service.tinyurl(Urls.tinyurl, longUrl).request {
            coroutineScope.launch {
                onResult(it, Providers.tinyurl, longUrl)
            }
        }
    }

    fun chilpit(
        longUrl: String,
        coroutineScope: CoroutineScope,
        onResult: suspend (response: ApiResponse<String>, provider: String, longUrl: String) -> Unit
    ) {
        service.chilpit(Urls.chilpit, longUrl).request {
            coroutineScope.launch {
               onResult(it, Providers.chilpit, longUrl)
            }
        }
    }

    fun clckru(
        longUrl: String,
        coroutineScope: CoroutineScope,
        onResult: suspend (response: ApiResponse<String>, provider: String, longUrl: String) -> Unit
    ) {
        service.clckru(Urls.clckru, longUrl).request {
            coroutineScope.launch {
               onResult(it, Providers.clckru, longUrl)
            }
        }
    }

    fun dagd(
        longUrl: String,
        coroutineScope: CoroutineScope,
        onResult: suspend (response: ApiResponse<String>, provider: String, longUrl: String) -> Unit
    ) {
        service.dagd(Urls.dagd, longUrl).request {
            coroutineScope.launch {
               onResult(it, Providers.dagd, longUrl)
            }
        }
    }

    fun isgd(
        longUrl: String,
        coroutineScope: CoroutineScope,
        onResult: suspend (response: ApiResponse<String>, provider: String, longUrl: String) -> Unit
    ) {
        service.isgd(Urls.isgd, "simple", longUrl).request {
            coroutineScope.launch {
               onResult(it, Providers.isgd, longUrl)
            }
        }
    }

    fun osdb(
        longUrl: String,
        coroutineScope: CoroutineScope,
        onResult: suspend (response: ApiResponse<String>, provider: String, longUrl: String) -> Unit
    ) {
        service.osdb(Urls.osdb, Osdb(longUrl)).request {
            coroutineScope.launch {
               onResult(it, Providers.osdb, longUrl)
            }
        }
    }

    fun cuttly(
        longUrl: String,
        coroutineScope: CoroutineScope,
        onResult: suspend (response: ApiResponse<Cuttly>, provider: String, longUrl: String) -> Unit
    ) {
        service.cuttly(Urls.cuttly, BuildConfig.CUTTLY_API_KEY, longUrl).request {
            coroutineScope.launch {
               onResult(it, Providers.cuttly, longUrl)
            }
        }
    }

}