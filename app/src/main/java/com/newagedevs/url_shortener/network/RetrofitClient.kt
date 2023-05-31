package com.newagedevs.url_shortener.network

import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

class RetrofitClient(
    private val baseUrl: String,
    private val client: OkHttpClient,
    private var factory: retrofit2.Converter.Factory?) {

    fun get(): Retrofit {

        return Retrofit.Builder()
            .baseUrl(baseUrl)
            .client(client)
            .addConverterFactory(factory?:GsonConverterFactory.create())
            .build()

    }
}
