package com.newagedevs.url_shortener.network

import com.newagedevs.url_shortener.BuildConfig
import com.newagedevs.url_shortener.model.cuttly.Cuttly
import com.newagedevs.url_shortener.model.osdb.Osdb
import com.newagedevs.url_shortener.utils.Urls
import com.skydoves.sandwich.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

class ShortlyClient(private val service: ShortlyService) {


    fun tinyurl(
        longUrl: String,
        coroutineScope: CoroutineScope,
        onResult: suspend (response: ApiResponse<String>) -> Unit
    ) {
        service.tinyurl(longUrl).request {
            coroutineScope.launch {
                onResult(it)
            }
        }
    }




    fun chilpit(
        longUrl: String,
        dataSource: ResponseDataSource<String>,
        coroutineScope: CoroutineScope,
        onResult: suspend (response: ApiResponse<String>) -> Unit
    ) {
        dataSource
            .dataRetainPolicy(DataRetainPolicy.NO_RETAIN)
            .retry(3, 5000L)
            .suspendCombine(service.chilpit(Urls.chilpit, longUrl), coroutineScope, onResult)
            .request()
    }

    fun clckru(
        longUrl: String,
        dataSource: ResponseDataSource<String>,
        coroutineScope: CoroutineScope,
        onResult: suspend (response: ApiResponse<String>) -> Unit
    ) {
        dataSource
            .dataRetainPolicy(DataRetainPolicy.NO_RETAIN)
            .retry(3, 5000L)
            .suspendCombine(service.clckru(Urls.clckru, longUrl), coroutineScope, onResult)
            .request()
    }

    fun dagd(
        longUrl: String,
        dataSource: ResponseDataSource<String>,
        coroutineScope: CoroutineScope,
        onResult: suspend (response: ApiResponse<String>) -> Unit
    ) {
        dataSource
            .dataRetainPolicy(DataRetainPolicy.NO_RETAIN)
            .retry(3, 5000L)
            .suspendCombine(service.dagd(Urls.dagd, longUrl), coroutineScope, onResult)
            .request()
    }

    fun isgd(
        longUrl: String,
        dataSource: ResponseDataSource<String>,
        coroutineScope: CoroutineScope,
        onResult: suspend (response: ApiResponse<String>) -> Unit
    ) {
        dataSource
            .dataRetainPolicy(DataRetainPolicy.NO_RETAIN)
            .retry(3, 5000L)
            .suspendCombine(service.isgd(Urls.isgd, "simple", longUrl), coroutineScope, onResult)
            .request()
    }

    fun osdb(
        longUrl: String,
        dataSource: ResponseDataSource<String>,
        coroutineScope: CoroutineScope,
        onResult: suspend (response: ApiResponse<String>) -> Unit
    ) {
        dataSource
            .dataRetainPolicy(DataRetainPolicy.NO_RETAIN)
            .retry(3, 5000L)
            .suspendCombine(service.osdb(Urls.osdb, Osdb(longUrl)), coroutineScope, onResult)
            .request()
    }

    fun cuttly(
        longUrl: String,
        dataSource: ResponseDataSource<Cuttly>,
        coroutineScope: CoroutineScope,
        onResult: suspend (response: ApiResponse<Cuttly>) -> Unit
    ) {
        dataSource
            .dataRetainPolicy(DataRetainPolicy.NO_RETAIN)
            .retry(3, 5000L)
            .suspendCombine(service.cuttly(Urls.cuttly, BuildConfig.CUTTLY_API_KEY, longUrl), coroutineScope, onResult)
            .request()
    }

}