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
import org.jsoup.Jsoup
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
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
        return makeStringApiCall(Providers.tinyurl) { apiService.tinyurl(longUrl) }
    }

    fun shortenWithChilpIt(longUrl: String): LiveData<UrlData> {
        baseUrlInterceptor.setBaseUrl("http://chilp.it/")
        return makeStringApiCall(Providers.chilpit) { apiService.chilpit(longUrl) }
    }

    fun shortenWithClckRu(longUrl: String): LiveData<UrlData> {
        baseUrlInterceptor.setBaseUrl("https://clck.ru/")
        return makeStringApiCall(Providers.clckru) { apiService.clckru(longUrl) }
    }

    fun shortenWithDaGd(longUrl: String): LiveData<UrlData> {
        baseUrlInterceptor.setBaseUrl("https://da.gd/")
        return makeStringApiCall(Providers.dagd) { apiService.dagd(longUrl) }
    }

    fun shortenWithIsGd(longUrl: String): LiveData<UrlData> {
        baseUrlInterceptor.setBaseUrl("https://is.gd/")
        return makeStringApiCall(Providers.isgd) { apiService.isgd("simple", longUrl) }
    }

    fun shortenWithOsdb(data: Osdb): LiveData<UrlData> {
        baseUrlInterceptor.setBaseUrl("https://osdb.link/")
        return makeStringApiCall(Providers.osdb) { apiService.osdb(data) }
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

    private fun makeStringApiCall(providers: String, apiCall: () -> Call<String>): LiveData<UrlData> {
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

                        val longUrl = call.request().url.queryParameter("url") ?: ""
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


