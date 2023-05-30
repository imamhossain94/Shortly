package com.newagedevs.url_shortener.network

import com.google.gson.GsonBuilder
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

class RetrofitClient(private val baseUrl: String) {

    fun getRetrofit(): Retrofit {

        val client = OkHttpClient.Builder()
            .addInterceptor(RequestInterceptor())
            .build()

        return Retrofit.Builder()
            .baseUrl(baseUrl)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()

    }
}
