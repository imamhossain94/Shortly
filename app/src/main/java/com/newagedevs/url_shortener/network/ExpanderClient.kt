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

class ExpanderClient(private val service: ExpanderService) {

    fun expand(
        shortUrl: String,
        coroutineScope: CoroutineScope,
        onResult: suspend (response: ApiResponse<String>, shortUrl: String) -> Unit
    ) {
        service.expand(shortUrl).request {
            coroutineScope.launch {
                onResult(it, shortUrl)
            }
        }
    }

}