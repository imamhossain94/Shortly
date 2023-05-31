package com.newagedevs.url_shortener.network.chilpit

import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Query

interface ChilpItService {

  @GET("api.php")
  fun short(@Query("url") url: String): Call<String>

}