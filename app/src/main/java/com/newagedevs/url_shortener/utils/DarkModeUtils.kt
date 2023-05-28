package com.newagedevs.url_shortener.utils

import android.app.UiModeManager
import android.content.Context
import android.content.ContextWrapper
import android.content.res.Configuration
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.AppCompatDelegate

object DarkModeUtils {
    const val DARK_MODE_AUTO = 2
    const val DARK_MODE_DISABLED = 0
    const val DARK_MODE_ENABLED = 1
    private const val NAME = "DarkModeUtils"
    private const val KEY_DARK_MODE = "dark_mode"
    fun createDarkModeConfig(context: Context, config: Configuration?): Configuration {
        val sharedPrefs = context.getSharedPreferences(
            NAME, Context.MODE_PRIVATE
        )
        val darkMode = sharedPrefs.getInt(KEY_DARK_MODE, DARK_MODE_AUTO)
        val uiModeNight: Int
        uiModeNight = when (darkMode) {
            DARK_MODE_DISABLED -> Configuration.UI_MODE_NIGHT_NO
            DARK_MODE_ENABLED -> Configuration.UI_MODE_NIGHT_YES
            else -> {
                val uiModeManager = context
                    .getSystemService(Context.UI_MODE_SERVICE) as UiModeManager
                uiModeManager.currentModeType and Configuration.UI_MODE_NIGHT_MASK
            }
        }
        val newConfig = Configuration(config)
        val newUiMode = (newConfig.uiMode and -Configuration.UI_MODE_NIGHT_MASK
                or Configuration.UI_MODE_TYPE_NORMAL)
        newConfig.uiMode = newUiMode or uiModeNight
        return newConfig
    }

    fun createDarkModeContextWrapper(context: Context): ContextWrapper {
        val newConfig = createDarkModeConfig(
            context, context.resources.configuration
        )
        return if (newConfig != null) {
            ContextWrapper(context.createConfigurationContext(newConfig))
        } else {
            ContextWrapper(context)
        }
    }

    fun getDarkMode(context: Context): Int {
        val sharedPreferences = context
            .getSharedPreferences(NAME, Context.MODE_PRIVATE)
        return sharedPreferences.getInt(KEY_DARK_MODE, DARK_MODE_AUTO)
    }

    fun setDarkMode(activity: AppCompatActivity, mode: Int) {
        if (getDarkMode(activity) != mode) {
            val sharedPreferences = activity.getSharedPreferences(
                NAME, Context.MODE_PRIVATE
            )
            val editor = sharedPreferences.edit()
            editor.putInt(KEY_DARK_MODE, mode).apply()
        }
        if (mode != DARK_MODE_AUTO) {
            AppCompatDelegate.setDefaultNightMode(if (mode == DARK_MODE_ENABLED) AppCompatDelegate.MODE_NIGHT_YES else AppCompatDelegate.MODE_NIGHT_NO)
        } else {
            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM)
        }
        activity.delegate.applyDayNight()
    }
}