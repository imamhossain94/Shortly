package com.newagedevs.url_shortener.di

import com.newagedevs.url_shortener.network.RetrofitClient
import org.koin.dsl.module
import retrofit2.Retrofit

val networkModule = module {

  single { RetrofitClient(get()) }

  single { get<Retrofit>().create(HorseDetailService::class.java) }

  single { HorseDetailClient(get()) }

}
