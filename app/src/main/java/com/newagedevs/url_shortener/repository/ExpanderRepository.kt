package com.newagedevs.url_shortener.repository

import androidx.annotation.WorkerThread
import com.newagedevs.url_shortener.model.Expander
import com.newagedevs.url_shortener.model.Shortly
import com.newagedevs.url_shortener.network.ExpanderClient
import com.newagedevs.url_shortener.network.ShortlyClient
import com.newagedevs.url_shortener.network.mapper.ErrorResponseMapper
import com.newagedevs.url_shortener.persistence.ExpanderDao
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


class ExpanderRepository constructor(
    private val client: ExpanderClient,
    private val dao: ExpanderDao
) : Repository {

    init {
        Timber.d("Injection RaceRepository")
    }

    fun loadExpandedUrls(): List<Expander> {
        val urls = dao.getExpandedUrlList()

        return urls.ifEmpty {
            emptyList()
        }
    }

    fun loadFavoritesExpandedUrls(): List<Expander> {
        val shortenUrls = dao.getFavoriteExpandedUrls()

        return shortenUrls.ifEmpty {
            emptyList()
        }
    }

    @WorkerThread
    @ExperimentalCoroutinesApi
    fun expand(
        shortUrl: String,
        coroutineScope: CoroutineScope,
        error: (String?) -> Unit
    ) = callbackFlow {

        client.expand(shortUrl, coroutineScope) {
            it.suspendOnSuccess {
                dao.insert(Expander(
                    longUrl = this.raw.request.url.toString(),
                    shortUrl = shortUrl,
                    timestamp = System.currentTimeMillis().toString(),
                    isFavorite = false,
                ))
                send(this.raw.request.url.toString())
            }
            .suspendOnError {
                map(ErrorResponseMapper) {
                    error("[Code: $code]: $message")
                }
            }
            .suspendOnException {
                send(message())
            }
            close()
        }
        awaitClose()
    }.flowOn(Dispatchers.IO)


}