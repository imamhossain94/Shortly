package com.newagedevs.url_shortener.repository

import com.newagedevs.url_shortener.model.Shortly
import com.newagedevs.url_shortener.persistence.ShortlyDao
import timber.log.Timber


class MainRepository constructor(
    private val dao: ShortlyDao
) : Repository {


    fun get(): Shortly? {
        return dao.get()
    }

//    fun flow(): Flow<AppHandler> {
//        return modelDao.flow()
//    }

    fun set(handler: Shortly) {
        dao.insert(handler)
    }


    init {
        Timber.d("Injection MainRepository")
    }

}