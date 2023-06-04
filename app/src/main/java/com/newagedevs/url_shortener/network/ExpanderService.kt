package com.newagedevs.url_shortener.network

import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Url

interface ExpanderService {

  @GET
  fun expand(@Url url: String): Call<String>

}