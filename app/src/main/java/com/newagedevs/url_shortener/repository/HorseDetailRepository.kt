package com.newagedevs.url_shortener.repository

import androidx.annotation.WorkerThread
import com.newagedevs.url_shortener.model.cuttly.Cuttly
import com.newagedevs.url_shortener.network.CuttlyClient
import com.skydoves.sandwich.*
import com.skydoves.sandwich.disposables.CompositeDisposable
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.flowOn
import timber.log.Timber


class CuttlyRepository constructor(
    private val client: CuttlyClient,
    private val dataSource: ResponseDataSource<Cuttly>,
    private val dao: HorseDetailDao
) : Repository {

    init {
        Timber.d("Injection RaceRepository")
    }

    @WorkerThread
    @ExperimentalCoroutinesApi
    fun details(
        key: String,
        url: String,
        disposable: CompositeDisposable,
        coroutineScope: CoroutineScope,
        error: (String?) -> Unit
    ) = callbackFlow {

        val details = horseDetailDao.getHorseDetail(horseID)

        if (details.isEmpty()) {
            client.short(
                key,
                url,
                dataSource,
                disposable,
                coroutineScope
            ) { apiResponse ->
                apiResponse
                    .suspendOnSuccess {

                        horseDetailDao.insertHorseDetail(data)
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
        } else {
            send(details[0])
            close()
        }

        awaitClose()
    }.flowOn(Dispatchers.IO)


}