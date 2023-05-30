@file:Suppress("unused")

package com.newagedevs.url_shortener

import android.app.Application
import com.newagedevs.url_shortener.di.networkModule
import com.newagedevs.url_shortener.di.persistenceModule
import com.newagedevs.url_shortener.di.repositoryModule
import com.newagedevs.url_shortener.di.viewModelModule
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin
import timber.log.Timber

class Application : Application() {

  override fun onCreate() {
    super.onCreate()

    startKoin {
      androidContext(this@Application)

      //Adding Module
      modules(viewModelModule)
      modules(networkModule)
      modules(repositoryModule)
      modules(persistenceModule)
    }

    if (BuildConfig.DEBUG) {
      Timber.plant(Timber.DebugTree())
    }
  }

}


