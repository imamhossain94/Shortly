package com.newagedevs.url_shortener.repository

import android.widget.Toast
import androidx.annotation.WorkerThread
import com.newagedevs.url_shortener.model.Shortly
import com.newagedevs.url_shortener.model.cuttly.Cuttly
import com.newagedevs.url_shortener.network.ShortlyClient
import com.newagedevs.url_shortener.network.mapper.ErrorResponseMapper
import com.newagedevs.url_shortener.persistence.ShortlyDao
import com.skydoves.sandwich.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.flow.onCompletion
import timber.log.Timber


class ShortlyRepository constructor(
    private val client: ShortlyClient,
    private val stringDataSource: ResponseDataSource<String>,
    private val cuttlyDataSource: ResponseDataSource<Cuttly>,
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
        Timber.d("________________________________");

        client.tinyurl(
            longUrl,
            stringDataSource,
            coroutineScope
        ) { apiResponse ->
            apiResponse
                .suspendOnSuccess {

                    dao.insert(Shortly(
                        longUrl = longUrl,
                        shortUrl = data,
                        provider = provider,
                        timestamp = System.currentTimeMillis().toString(),
                        isFavorite = false,
                    ))

                    Timber.d("________________________________");
                    Timber.d(data)
                    Timber.d("________________________________");


                    send(data)
                }
                .suspendOnError {

                    Timber.d("________________________________");
                    Timber.d("Error")
                    Timber.d("________________________________");


                    map(ErrorResponseMapper) { error("[Code: $code]: $message") }
                }
                .suspendOnException {

                    Timber.d("________________________________");
                    Timber.d(message())
                    Timber.d("________________________________");

                    error(message())
                }
            close()
        }

        send("")

        awaitClose()
    }.flowOn(Dispatchers.IO)



}