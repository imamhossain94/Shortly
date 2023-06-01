package com.newagedevs.url_shortener.network.cuttly

import com.newagedevs.url_shortener.model.cuttly.Cuttly
import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Query
import retrofit2.http.Url

interface CuttlyService {

  @GET
  fun short(@Url baseUrl: String, @Query("key") key: String, @Query("short") short: String): Call<Cuttly>


}