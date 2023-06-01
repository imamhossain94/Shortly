package com.newagedevs.url_shortener.repository

import androidx.annotation.WorkerThread
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
import kotlinx.coroutines.flow.flowOn
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

    @WorkerThread
    @ExperimentalCoroutinesApi
    fun short(
        provider: String,
        longUrl: String,
        coroutineScope: CoroutineScope,
        error: (String?) -> Unit
    ) = callbackFlow {

        client.tinyurl(
            longUrl,
            stringDataSource,
            coroutineScope
        ) { apiResponse ->
            apiResponse
                .suspendOnSuccess {

//                    dao.insert(Shortly(
//                        longUrl = longUrl,
//                        shortUrl = data.url?.shortLink,
//                        provider = "Cutt.ly",
//                        timestamp = data.url?.date,
//                        isFavorite = false,
//                    ))

                    send(data)
                }
                .suspendOnError {
                    map(ErrorResponseMapper) { error("[Code: $code]: $message") }
                }
                .suspendOnException {
                    error(message())
                }
            close()
        }

        awaitClose()
    }.flowOn(Dispatchers.IO)



}