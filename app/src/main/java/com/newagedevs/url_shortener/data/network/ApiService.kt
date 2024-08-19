package com.newagedevs.url_shortener.data.network

import com.newagedevs.url_shortener.data.model.Osdb
import com.newagedevs.url_shortener.data.model.cuttly.Cuttly
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Query
import retrofit2.http.Url

interface ApiService {
    @GET("api-create.php")
    fun tinyurl(@Query("url") longUrl: String): Call<String>

    @GET("api.php")
    fun chilpit(@Query("url") longUrl: String): Call<String>

    @GET("--")
    fun clckru(@Query("url") longUrl: String): Call<String>

    @GET("shorten")
    fun dagd(@Query("url") longUrl: String): Call<String>

    @GET("create.php")
    fun isgd(@Query("format") format: String, @Query("url") longUrl: String): Call<String>

    @POST("/")
    fun osdb(@Body data: Osdb): Call<String>

    @GET("api.php")
    fun cuttly(@Query("key") apiKey: String, @Query("short") longUrl: String): Call<Cuttly>

    @GET
    fun expand(@Url url: String): Call<String>
}

