package com.newagedevs.url_shortener.utils

import com.newagedevs.url_shortener.data.model.UrlShortenerProvider

fun generateQueryParams(provider: UrlShortenerProvider, longUrl: String): Map<String, String> {
    return when (provider) {
        is UrlShortenerProvider.TinyUrl,
        is UrlShortenerProvider.ChilpIt,
        is UrlShortenerProvider.ClckRu,
        is UrlShortenerProvider.DaGd -> mapOf("url" to longUrl)
        is UrlShortenerProvider.IsGd -> mapOf("url" to longUrl, "format" to "simple")
        is UrlShortenerProvider.CuttLy -> mapOf("key" to "YOUR_API_KEY", "short" to longUrl)
        else -> emptyMap()
    }
}
