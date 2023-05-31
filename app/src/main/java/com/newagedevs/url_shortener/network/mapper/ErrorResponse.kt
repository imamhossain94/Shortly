package com.newagedevs.url_shortener.network.mapper

data class ErrorResponse(
  val code    : Int,
  val message : String?
)