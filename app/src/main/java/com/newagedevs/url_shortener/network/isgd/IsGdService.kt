package com.newagedevs.url_shortener.network.dagd

import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Query

interface DaGdService {

  @GET("shorten")
  fun short(@Query("url") url: String): Call<String>

}