package com.newagedevs.url_shortener.data.model

sealed class UrlShortenerProvider(val baseUrl: String) {
    object TinyUrl : UrlShortenerProvider("http://tinyurl.com/api-create.php")
    object ChilpIt : UrlShortenerProvider("http://chilp.it/api.php")
    object ClckRu : UrlShortenerProvider("https://clck.ru/--")
    object DaGd : UrlShortenerProvider("https://da.gd/shorten")
    object IsGd : UrlShortenerProvider("https://is.gd/create.php")
    object Osdb : UrlShortenerProvider("https://osdb.link/")
    object CuttLy : UrlShortenerProvider("https://cutt.ly/api/api.php")
}
