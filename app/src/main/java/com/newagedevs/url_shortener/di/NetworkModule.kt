package com.newagedevs.url_shortener.di

import com.newagedevs.url_shortener.network.RequestInterceptor
import com.newagedevs.url_shortener.network.cuttly.CuttlyClient
import com.newagedevs.url_shortener.network.cuttly.CuttlyService
import com.newagedevs.url_shortener.network.RetrofitClient
import com.newagedevs.url_shortener.network.chilpit.ChilpItClient
import com.newagedevs.url_shortener.network.clck.ru.ClckRuClient
import com.newagedevs.url_shortener.network.clck.ru.ClckRuService
import com.newagedevs.url_shortener.network.dagd.DaGdClient
import com.newagedevs.url_shortener.network.dagd.DaGdService
import okhttp3.OkHttpClient
import org.koin.dsl.module
import retrofit2.converter.scalars.ScalarsConverterFactory

val networkModule = module {

  single {
    OkHttpClient.Builder()
      .addInterceptor(RequestInterceptor())
      .build()
  }

  single {
    RetrofitClient("https://cutt.ly/", get(), null)
      .get()
      .create(CuttlyService::class.java)
  }

  single {
    RetrofitClient("http://chilp.it/", get(), ScalarsConverterFactory.create())
      .get()
      .create(ClckRuService::class.java)
  }

  single {
    RetrofitClient("https://clck.ru/", get(), ScalarsConverterFactory.create())
      .get()
      .create(ClckRuService::class.java)
  }

  single {
    RetrofitClient("https://da.gd/", get(), ScalarsConverterFactory.create())
      .get()
      .create(DaGdService::class.java)
  }



  single { CuttlyClient(get()) }

  single { ChilpItClient(get()) }

  single { ClckRuClient(get()) }

  single { DaGdClient(get()) }


}
