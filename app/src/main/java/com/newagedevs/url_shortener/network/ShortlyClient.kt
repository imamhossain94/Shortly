package com.newagedevs.url_shortener.network.cuttly

import com.newagedevs.url_shortener.model.cuttly.Cuttly
import com.newagedevs.url_shortener.network.cuttly.CuttlyService
import com.skydoves.sandwich.ApiResponse
import com.skydoves.sandwich.DataRetainPolicy
import com.skydoves.sandwich.ResponseDataSource
import kotlinx.coroutines.CoroutineScope

class CuttlyClient(private val service: CuttlyService) {

    fun short(
        key: String,
        url: String,
        dataSource: ResponseDataSource<Cuttly>,
        coroutineScope: CoroutineScope,
        onResult: suspend (response: ApiResponse<Cuttly>) -> Unit
    ) {
        dataSource
            .dataRetainPolicy(DataRetainPolicy.NO_RETAIN)
            .retry(3, 5000L)
            .suspendCombine(service.short("", key, url), coroutineScope, onResult)
            .request()
    }

}