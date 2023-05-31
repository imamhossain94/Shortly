package com.newagedevs.url_shortener.network.clck.ru

import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Query

interface ClckRuService {

  @GET("--")
  fun short(@Query("url") url: String): Call<String>

}