package com.newagedevs.url_shortener.data.network

import okhttp3.HttpUrl.Companion.toHttpUrlOrNull
import okhttp3.Interceptor
import okhttp3.Response


class BaseUrlInterceptor : Interceptor {
    @Volatile
    private var baseUrl: String? = null

    fun setBaseUrl(baseUrl: String) {
        this.baseUrl = baseUrl
    }

    override fun intercept(chain: Interceptor.Chain): Response {
        val originalRequest = chain.request()
        val newUrl = baseUrl?.toHttpUrlOrNull()
        val newRequest = if (newUrl != null) {
            originalRequest.newBuilder()
                .url(originalRequest.url.newBuilder().scheme(newUrl.scheme).host(newUrl.host).build())
                .build()
        } else {
            originalRequest
        }
        return chain.proceed(newRequest)
    }
}
