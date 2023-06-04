package com.newagedevs.url_shortener.network

import com.newagedevs.url_shortener.model.cuttly.Cuttly
import com.newagedevs.url_shortener.model.osdb.Osdb
import retrofit2.Call
import retrofit2.http.*

interface ShortlyService {

  @GET
  fun tinyurl(@Url url: String, @Query("url") longUrl: String): Call<String>

  @GET
  fun chilpit(@Url baseUrl:String,  @Query("url") longUrl: String): Call<String>

  @GET
  fun clckru(@Url baseUrl:String, @Query("url") longUrl: String): Call<String>

  @GET
  fun dagd(@Url baseUrl:String, @Query("url") longUrl: String): Call<String>

  @GET
  fun isgd(@Url baseUrl:String, @Query("format") format: String, @Query("url") longUrl: String): Call<String>

  @POST
  fun osdb(@Url baseUrl:String, @Body data: Osdb): Call<String>

  @GET
  fun cuttly(@Url baseUrl: String, @Query("key") apiKey: String, @Query("short") longUrl: String): Call<Cuttly>

}