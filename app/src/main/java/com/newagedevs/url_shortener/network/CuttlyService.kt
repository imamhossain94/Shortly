package com.newagedevs.url_shortener.network

import com.newagedevs.url_shortener.model.cuttly.Cuttly
import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query

interface CuttlyService {

  @GET("api/api.php")
  fun short(@Query("key") key: String, @Query("short") short: String): Call<Cuttly>

}