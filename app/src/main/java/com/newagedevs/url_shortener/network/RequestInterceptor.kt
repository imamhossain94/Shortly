package com.newagedevs.url_shortener.network

import okhttp3.Interceptor
import okhttp3.Response

class RequestInterceptor : Interceptor {
  override fun intercept(chain: Interceptor.Chain): Response {
    val originalRequest = chain.request()

    val request = originalRequest.newBuilder()
      //.addHeader("API-KEY", BuildConfig.API_KEY)
      .url(originalRequest.url).build()

    return chain.proceed(request)
  }
}
