package com.newagedevs.url_shortener.di

import com.newagedevs.url_shortener.model.cuttly.Cuttly
import com.newagedevs.url_shortener.network.RequestInterceptor
import com.newagedevs.url_shortener.network.ShortlyClient
import com.newagedevs.url_shortener.network.ShortlyService
import com.skydoves.sandwich.ResponseDataSource
import okhttp3.OkHttpClient
import org.koin.dsl.module
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.converter.scalars.ScalarsConverterFactory

val networkModule = module {

  single {
    OkHttpClient.Builder()
      .addInterceptor(RequestInterceptor())
      .build()
  }

  single(override = true) {
    Retrofit.Builder()
      .baseUrl("http://tinyurl.com/")
      //.client(get<OkHttpClient>())
      .addConverterFactory(ScalarsConverterFactory.create())
      //.addConverterFactory(GsonConverterFactory.create())
      .build()
  }

  single { get<Retrofit>().create(ShortlyService::class.java) }

  single { ShortlyClient(get()) }

  single { ResponseDataSource<Cuttly>() }


}
