package com.newagedevs.url_shortener.repository

import androidx.annotation.WorkerThread
import com.newagedevs.url_shortener.model.Shortly
import com.newagedevs.url_shortener.network.ShortlyClient
import com.newagedevs.url_shortener.network.mapper.ErrorResponseMapper
import com.newagedevs.url_shortener.persistence.ShortlyDao
import com.newagedevs.url_shortener.utils.Providers
import com.skydoves.sandwich.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.flowOn
import timber.log.Timber


class ShortlyRepository constructor(
    private val client: ShortlyClient,
    private val dao: ShortlyDao
) : Repository {

    init {
        Timber.d("Injection RaceRepository")
    }

    fun loadShortenUrls(): List<Shortly> {
        val shortenUrls = dao.getShortenUrlList()

        return shortenUrls.ifEmpty {
            emptyList()
        }

    }

    @WorkerThread
    @ExperimentalCoroutinesApi
    fun short(
        provider: String,
        longUrl: String,
        coroutineScope: CoroutineScope,
        error: (String?) -> Unit
    ) = callbackFlow {

        when(provider) {
            Providers.tinyurl -> {
                client.tinyurl(longUrl, coroutineScope ) { it, p, l->
                    handleApiResponse(it, p, l, error).collect { value ->
                        send(value)
                    }
                }
            }
            Providers.chilpit -> {
                client.chilpit(longUrl, coroutineScope ) { it, p, l->
                    handleApiResponse(it, p, l, error).collect { value ->
                        send(value)
                    }
                }
            }
            Providers.clckru -> {
                client.clckru(longUrl, coroutineScope ) { it, p, l->
                    handleApiResponse(it, p, l, error).collect { value ->
                        send(value)
                    }
                }
            }
            Providers.dagd -> {
                client.dagd(longUrl, coroutineScope ) { it, p, l->
                    handleApiResponse(it, p, l, error).collect { value ->
                        send(value)
                    }
                }
            }
            Providers.isgd -> {
                client.isgd(longUrl, coroutineScope ) { it, p, l->
                    handleApiResponse(it, p, l, error).collect { value ->
                        send(value)
                    }
                }
            }
            Providers.osdb -> {
                client.osdb(longUrl, coroutineScope ) { it, p, l->
                    handleApiResponse(it, p, l, error).collect { value ->
                        send(value)
                    }
                }
            }
        }
        awaitClose()
    }.flowOn(Dispatchers.IO)


    private suspend fun handleApiResponse(
        apiResponse: ApiResponse<String>,
        provider: String,
        longUrl: String,
        error: (String?) -> Unit
    )= callbackFlow {
        apiResponse
            .suspendOnSuccess {
                dao.insert(Shortly(
                    longUrl = longUrl,
                    shortUrl = data,
                    provider = provider,
                    timestamp = System.currentTimeMillis().toString(),
                    isFavorite = false,
                ))
                send(data)
            }
            .suspendOnError {
                map(ErrorResponseMapper) { error("[Code: $code]: $message") }
            }
            .suspendOnException {
                send(message())
            }

        close()
    }


}