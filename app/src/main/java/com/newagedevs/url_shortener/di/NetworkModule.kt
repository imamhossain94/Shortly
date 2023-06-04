package com.newagedevs.url_shortener.di

import com.newagedevs.url_shortener.network.*
import okhttp3.OkHttpClient
import org.koin.core.qualifier.named
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

  single(named("expanderOkHttpClient")) {
    OkHttpClient.Builder()
      .followRedirects(false)
      .cache(null)
      .build()
  }

  single() {
    Retrofit.Builder()
      .baseUrl("http://tinyurl.com/")
      .client(get<OkHttpClient>())
      .addConverterFactory(ScalarsConverterFactory.create())
      .addConverterFactory(GsonConverterFactory.create())
      .build()
  }

  single(named("expanderRetrofit")) {
    Retrofit.Builder()
      .baseUrl("http://tinyurl.com/")
      .client(get(named("expanderOkHttpClient")))
      .addConverterFactory(ScalarsConverterFactory.create())
      .addConverterFactory(GsonConverterFactory.create())
      .build()
  }

  single { get<Retrofit>().create(ShortlyService::class.java) }

  single { get<Retrofit>(named("expanderRetrofit")).create(ExpanderService::class.java) }

  single { ShortlyClient(get()) }

  single { ExpanderClient(get()) }

}
