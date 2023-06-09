package com.newagedevs.url_shortener.extensions

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.Toast
import androidx.core.app.ShareCompat
import androidx.core.content.ContextCompat.startActivity
import com.newagedevs.url_shortener.BuildConfig
import java.net.HttpURLConnection
import java.net.URL

fun getApplicationVersion(): String {
    return BuildConfig.VERSION_NAME
}

fun Context.toast(message:String){
    Toast.makeText(this, message , Toast.LENGTH_SHORT).show()
}

fun shareTheApp(context: Context) {
    ShareCompat.IntentBuilder.from((context as Activity)).setType("text/plain")
        .setChooserTitle("Chooser title")
        .setText("http://play.google.com/store/apps/details?id=" + context.packageName)
        .startChooser()
}

fun shareUrl(context: Context, url:String) {
    ShareCompat.IntentBuilder.from((context as Activity)).setType("text/plain")
        .setChooserTitle("Chooser title")
        .setText(url)
        .startChooser()
}

fun openMailApp(context: Context, subject: String, mail: Array<String>) {
    try {
        val intent = Intent(Intent.ACTION_SENDTO)
        intent.data = Uri.parse("mailto:")
        intent.putExtra(Intent.EXTRA_EMAIL, mail)
        intent.putExtra(Intent.EXTRA_SUBJECT, subject)
        startActivity(context, intent, null)
    } catch (ex: ActivityNotFoundException) {
        Toast.makeText(
            context,
            "There are no email app installed on your device",
            Toast.LENGTH_SHORT
        ).show()
    }
}

fun openAppStore(context: Context, link: String, error: (String?) -> Unit) {
    try {
        startActivity(context, Intent(Intent.ACTION_VIEW, Uri.parse(link)), null)
    } catch (e:Exception) {
        error(e.message)
    }
}

fun openWebPage(context: Context, url: String?, error: (String?) -> Unit) {
    try {
        val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
        startActivity(context, browserIntent, null)
    } catch (e:Exception) {
        error(e.message)
    }
}

fun isUriEmpty(uri: Uri?):Boolean{
    return uri == null || uri == Uri.EMPTY
}

object URLExpander {
    fun expand(url: String): String {
        var connection: HttpURLConnection
        var finalUrl = url
        try {
            do {
                connection = URL(finalUrl).openConnection() as HttpURLConnection
                connection.instanceFollowRedirects = false
                connection.useCaches = false
                connection.requestMethod = "GET"
                connection.connect()
                val responseCode = connection.responseCode
                if (responseCode in 300..399) {
                    val redirectedUrl = connection.getHeaderField("Location") ?: break
                    finalUrl = redirectedUrl
                } else break
            } while (connection.responseCode != HttpURLConnection.HTTP_OK)
            connection.disconnect()
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return finalUrl
    }
}
