package com.newagedevs.url_shortener.binding

import android.graphics.Color
import android.graphics.drawable.Drawable
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.MarginLayoutParams
import android.widget.*
import androidx.core.content.res.ResourcesCompat
import androidx.core.graphics.drawable.DrawableCompat
import androidx.databinding.BindingAdapter
import com.bumptech.glide.Glide
import com.newagedevs.url_shortener.extensions.px
import com.skydoves.whatif.whatIfNotNullOrEmpty


object ViewBinding {

    @JvmStatic
    @BindingAdapter("toast")
    fun bindToast(view: FrameLayout, text: String?) {
        text.whatIfNotNullOrEmpty {
            Toast.makeText(view.context, it, Toast.LENGTH_SHORT).show()
        }
    }


}
