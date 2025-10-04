package com.newagedevs.url_shortener.data.repository

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.newagedevs.url_shortener.data.local.db.UrlDao
import com.newagedevs.url_shortener.data.model.Osdb
import com.newagedevs.url_shortener.data.model.UrlData
import com.newagedevs.url_shortener.data.model.cuttly.Cuttly
import com.newagedevs.url_shortener.data.network.ApiService
import com.newagedevs.url_shortener.data.network.BaseUrlInterceptor
import com.newagedevs.url_shortener.utils.Providers
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import org.jsoup.Jsoup
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.net.HttpURLConnection
import java.net.URL
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class UrlRepository @Inject constructor(
    private val apiService: ApiService,
    private val baseUrlInterceptor: BaseUrlInterceptor,
    private val urlDao: UrlDao
) {

    fun shortenWithTinyUrl(longUrl: String): LiveData<UrlData> {
        baseUrlInterceptor.setBaseUrl("http://tinyurl.com/")
        return makeStringApiCall(longUrl, Providers.tinyurl) { apiService.tinyurl(longUrl) }
    }

    fun shortenWithChilpIt(longUrl: String): LiveData<UrlData> {
        baseUrlInterceptor.setBaseUrl("http://chilp.it/")
        return makeStringApiCall(longUrl, Providers.chilpit) { apiService.chilpit(longUrl) }
    }

    fun shortenWithClckRu(longUrl: String): LiveData<UrlData> {
        baseUrlInterceptor.setBaseUrl("https://clck.ru/")
        return makeStringApiCall(longUrl, Providers.clckru) { apiService.clckru(longUrl) }
    }

    fun shortenWithDaGd(longUrl: String): LiveData<UrlData> {
        baseUrlInterceptor.setBaseUrl("https://da.gd/")
        return makeStringApiCall(longUrl, Providers.dagd) { apiService.dagd(longUrl) }
    }

    fun shortenWithIsGd(longUrl: String): LiveData<UrlData> {
        baseUrlInterceptor.setBaseUrl("https://is.gd/")
        return makeStringApiCall(longUrl, Providers.isgd) { apiService.isgd("simple", longUrl) }
    }

    fun shortenWithOsdb(data: Osdb): LiveData<UrlData> {
        baseUrlInterceptor.setBaseUrl("https://osdb.link/")
        return makeStringApiCall(data.url!!, Providers.osdb) { apiService.osdb(data) }
    }

    fun shortenWithCuttly(apiKey: String, longUrl: String): LiveData<UrlData> {
        baseUrlInterceptor.setBaseUrl("https://cutt.ly/")

        val result = MutableLiveData<UrlData>()

        apiService.cuttly(apiKey, longUrl).enqueue(object : Callback<Cuttly> {
            override fun onResponse(call: Call<Cuttly>, response: Response<Cuttly>) {
                if (response.isSuccessful) {
                    val shortenedUrl = response.body()?.url?.shortLink
                    if (shortenedUrl != null) {
                        val urlData = UrlData(
                            provider = Providers.cuttly,
                            originalUrl = longUrl,
                            shortenedUrl = shortenedUrl,
                            expandedUrl = longUrl,
                            success = true
                        )
                        result.value = urlData
                        saveUrlToDatabase(urlData)
                    } else {
                        result.value = UrlData(success = false)
                    }
                } else {
                    result.value = UrlData(success = false)
                }
            }

            override fun onFailure(call: Call<Cuttly>, t: Throwable) {
                result.value = UrlData(success = false)
            }
        })

        return result
    }

    private fun makeStringApiCall(longUrl: String, providers: String, apiCall: () -> Call<String>): LiveData<UrlData> {
        val result = MutableLiveData<UrlData>()
        apiCall().enqueue(object : Callback<String> {
            override fun onResponse(call: Call<String>, response: Response<String>) {
                if (response.isSuccessful) {
                    val data = response.body()
                    if (data != null) {
                        var shortenedUrl = data

                        if(providers == Providers.osdb) {
                            val doc = Jsoup.parse(data)
                            shortenedUrl = doc.selectFirst("label#surl")
                                ?.text().toString()
                                .replace("Your shortened URL is:", "").trim()
                        }

                        val urlData = UrlData(
                            provider = providers,
                            originalUrl = longUrl,
                            shortenedUrl = shortenedUrl,
                            expandedUrl = longUrl,
                            success = true
                        )
                        result.value = urlData
                        saveUrlToDatabase(urlData)

                    } else {
                        result.value = UrlData(success = false)
                    }
                } else {
                    result.value = UrlData(success = false)
                }
            }
            override fun onFailure(call: Call<String>, t: Throwable) {
                result.value = UrlData(success = false)
            }
        })
        return result
    }

    // Code to Expand URL - Follow all redirects
    fun expand(shortUrl: String): LiveData<UrlData> {
        val result = MutableLiveData<UrlData>()

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val finalUrl = followRedirects(shortUrl)

                val urlData = UrlData(
                    provider = null,
                    originalUrl = shortUrl,
                    shortenedUrl = shortUrl,
                    expandedUrl = finalUrl,
                    success = true
                )

                withContext(Dispatchers.Main) {
                    result.value = urlData
                }

                saveUrlToDatabase(urlData)

            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.value = UrlData(success = false)
                }
            }
        }

        return result
    }

    private suspend fun followRedirects(url: String, maxRedirects: Int = 10): String {
        return withContext(Dispatchers.IO) {
            var currentUrl = url
            var redirectCount = 0

            while (redirectCount < maxRedirects) {
                try {
                    val connection = URL(currentUrl).openConnection() as HttpURLConnection
                    connection.instanceFollowRedirects = false
                    connection.connectTimeout = 10000
                    connection.readTimeout = 10000
                    connection.requestMethod = "GET"
                    connection.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")

                    val responseCode = connection.responseCode

                    when (responseCode) {
                        HttpURLConnection.HTTP_MOVED_PERM,
                        HttpURLConnection.HTTP_MOVED_TEMP,
                        HttpURLConnection.HTTP_SEE_OTHER,
                        307, // Temporary Redirect
                        308  // Permanent Redirect
                            -> {
                            val location = connection.getHeaderField("Location")
                            connection.disconnect()

                            if (location.isNullOrEmpty()) {
                                break
                            }

                            // Handle relative URLs
                            currentUrl = if (location.startsWith("http://") || location.startsWith("https://")) {
                                location
                            } else {
                                val baseUrl = URL(currentUrl)
                                URL(baseUrl, location).toString()
                            }

                            redirectCount++
                        }
                        HttpURLConnection.HTTP_OK -> {
                            // Check for meta refresh or JavaScript redirects
                            val html = connection.inputStream.bufferedReader().use { it.readText() }
                            connection.disconnect()

                            val metaRefreshUrl = extractMetaRefreshUrl(html, currentUrl)
                            if (metaRefreshUrl != null && metaRefreshUrl != currentUrl) {
                                currentUrl = metaRefreshUrl
                                redirectCount++
                            } else {
                                break
                            }
                        }
                        else -> {
                            connection.disconnect()
                            break
                        }
                    }
                } catch (e: Exception) {
                    // If we encounter an error but have a valid URL, return it
                    break
                }
            }

            currentUrl
        }
    }

    private fun extractMetaRefreshUrl(html: String, baseUrl: String): String? {
        return try {
            val doc = Jsoup.parse(html)

            // Check for meta refresh tag
            val metaRefresh = doc.select("meta[http-equiv=refresh]").firstOrNull()
            if (metaRefresh != null) {
                val content = metaRefresh.attr("content")
                val urlMatch = Regex("url=(.+)", RegexOption.IGNORE_CASE).find(content)
                if (urlMatch != null) {
                    val url = urlMatch.groupValues[1].trim().trim('\'', '"')
                    return if (url.startsWith("http://") || url.startsWith("https://")) {
                        url
                    } else {
                        URL(URL(baseUrl), url).toString()
                    }
                }
            }

            // Check for common JavaScript redirect patterns
            val scriptTags = doc.select("script")
            for (script in scriptTags) {
                val scriptContent = script.html()

                // window.location patterns
                val locationMatch = Regex("""window\.location(?:\.href)?\s*=\s*['"]([^'"]+)['"]""").find(scriptContent)
                if (locationMatch != null) {
                    val url = locationMatch.groupValues[1]
                    return if (url.startsWith("http://") || url.startsWith("https://")) {
                        url
                    } else {
                        URL(URL(baseUrl), url).toString()
                    }
                }
            }

            null
        } catch (e: Exception) {
            null
        }
    }

    private fun saveUrlToDatabase(urlData: UrlData) {
        CoroutineScope(Dispatchers.IO).launch {
            urlDao.insertUrl(urlData)
        }
    }

    fun getHistory(): LiveData<List<UrlData>> {
        return urlDao.getAllUrls()
    }

    fun deleteUrl(urlData: UrlData) {
        CoroutineScope(Dispatchers.IO).launch {
            urlDao.deleteUrl(urlData)
        }
    }
}