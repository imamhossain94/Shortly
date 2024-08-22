package com.newagedevs.url_shortener.data.local

import android.content.Context

class SharedPref(private val context: Context) {
    private val prefName = "url_shortener"

    private val proKey = "url_shortener.pro"

    private val clickCountKey = "clickCount"

    fun isPro(): Boolean {
        val sharedPref = context.getSharedPreferences(prefName, Context.MODE_PRIVATE)
        return sharedPref.getBoolean(proKey, false)
    }

    fun setPro(value: Boolean) {
        val sharedPref = context.getSharedPreferences(prefName, Context.MODE_PRIVATE)
        val editor = sharedPref.edit()
        editor.putBoolean(proKey, value)
        editor.apply()
    }

    fun clickCount(): Int {
        val sharedPref = context.getSharedPreferences(prefName, Context.MODE_PRIVATE)
        return sharedPref.getInt(clickCountKey, 0)
    }

    fun clickCount(count: Int) {
        val sharedPref = context.getSharedPreferences(prefName, Context.MODE_PRIVATE)
        val editor = sharedPref.edit()
        editor.putInt(clickCountKey, count)
        editor.apply()
    }

    fun incClickCount() {
        val sharedPref = context.getSharedPreferences(prefName, Context.MODE_PRIVATE)
        val currentCount = sharedPref.getInt(clickCountKey, 0)
        val editor = sharedPref.edit()
        editor.putInt(clickCountKey, currentCount + 1)
        editor.apply()
    }

    fun resetClickCount() {
        val sharedPref = context.getSharedPreferences(prefName, Context.MODE_PRIVATE)
        val editor = sharedPref.edit()
        editor.putInt(clickCountKey, 0)
        editor.apply()
    }

}