package com.newagedevs.url_shortener.network

import com.newagedevs.url_shortener.model.cuttly.Cuttly
import com.newagedevs.url_shortener.model.osdb.Osdb
import retrofit2.Call
import retrofit2.http.*

interface ShortlyService {

  @GET("/api-create.php")
  fun tinyurl(@Url baseUrl:String, @Query("url") longUrl: String): Call<String>

  @GET("/api.php")
  fun chilpit(@Url baseUrl:String,  @Query("url") longUrl: String): Call<String>

  @GET("/--")
  fun clckru(@Url baseUrl:String, @Query("url") longUrl: String): Call<String>

  @GET("/shorten")
  fun dagd(@Url baseUrl:String, @Query("url") longUrl: String): Call<String>

  @GET("/create.php")
  fun isgd(@Url baseUrl:String, @Query("format") format: String, @Query("url") longUrl: String): Call<String>

  @POST("/")
  fun osdb(@Url baseUrl:String, @Body data: Osdb): Call<String>

  @GET("/api/api.php")
  fun cuttly(@Url baseUrl: String, @Query("key") apiKey: String, @Query("short") longUrl: String): Call<Cuttly>

}