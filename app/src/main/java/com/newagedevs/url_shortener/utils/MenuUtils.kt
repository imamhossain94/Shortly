package com.newagedevs.url_shortener.utils

import android.content.Context
import android.graphics.drawable.Drawable
import androidx.annotation.DrawableRes
import androidx.core.content.ContextCompat
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.ui.adapters.MenuAdapter.MenuItem

object MenuUtils {
    fun get(context: Context): List<MenuItem> {
        val samples = ArrayList<MenuItem>()
        samples.add(MenuItem(drawable(context, R.drawable.ic_star), context.getString(R.string.rate_us)))
        samples.add(MenuItem(drawable(context, R.drawable.ic_share), context.getString(R.string.share)))
        samples.add(MenuItem(drawable(context, R.drawable.ic_chat_line), context.getString(R.string.feedback)))
        samples.add(MenuItem(drawable(context, R.drawable.ic_bag), context.getString(R.string.other_app)))
        samples.add(MenuItem(drawable(context, R.drawable.ic_alert), context.getString(R.string.about)))
        return samples
    }


    private fun drawable(context: Context, @DrawableRes id: Int): Drawable? {
        return ContextCompat.getDrawable(context, id)
    }
}