package com.newagedevs.url_shortener.repository

import com.newagedevs.url_shortener.model.Model
import com.newagedevs.url_shortener.persistence.ModelDao
import timber.log.Timber


class MainRepository constructor(
    private val modelDao: ModelDao
) : Repository {


    fun get(): Model? {
        return modelDao.get()
    }

//    fun flow(): Flow<AppHandler> {
//        return modelDao.flow()
//    }

    fun set(handler: Model) {
        modelDao.insert(handler)
    }

    init {
        Timber.d("Injection MainRepository")
    }

}