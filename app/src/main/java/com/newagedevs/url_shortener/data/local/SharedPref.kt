package com.newagedevs.url_shortener.data.local

import android.content.Context
import androidx.core.content.edit

class SharedPref(private val context: Context) {
    private val prefName = "url_shortener"

    private val proKey = "url_shortener.pro"

    private val clickCountKey = "clickCount"

    fun isPro(): Boolean {
        val sharedPref = context.getSharedPreferences(prefName, Context.MODE_PRIVATE)
        return false //sharedPref.getBoolean(proKey, false)
    }

    fun setPro(value: Boolean) {
        val sharedPref = context.getSharedPreferences(prefName, Context.MODE_PRIVATE)
        sharedPref.edit {
            putBoolean(proKey, value)
        }
    }

    fun clickCount(): Int {
        val sharedPref = context.getSharedPreferences(prefName, Context.MODE_PRIVATE)
        return sharedPref.getInt(clickCountKey, 0)
    }

    fun clickCount(count: Int) {
        val sharedPref = context.getSharedPreferences(prefName, Context.MODE_PRIVATE)
        sharedPref.edit {
            putInt(clickCountKey, count)
        }
    }

    fun incClickCount() {
        val sharedPref = context.getSharedPreferences(prefName, Context.MODE_PRIVATE)
        val currentCount = sharedPref.getInt(clickCountKey, 0)
        sharedPref.edit {
            putInt(clickCountKey, currentCount + 1)
        }
    }

    fun resetClickCount() {
        val sharedPref = context.getSharedPreferences(prefName, Context.MODE_PRIVATE)
        sharedPref.edit {
            putInt(clickCountKey, 0)
        }
    }

}