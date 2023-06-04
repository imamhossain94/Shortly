package com.newagedevs.url_shortener.extensions

import android.annotation.SuppressLint
import android.view.MotionEvent
import android.view.View
import android.widget.EditText
import androidx.appcompat.widget.AppCompatEditText

fun View.visible() {
  visibility = View.VISIBLE
}

@SuppressLint("ClickableViewAccessibility")
fun AppCompatEditText.onLeftDrawableClicked(onClicked: (view: AppCompatEditText) -> Unit) {
  this.setOnTouchListener { v, event ->
    var hasConsumed = false
    if (v is AppCompatEditText) {
      if (event.x <= v.totalPaddingLeft) {
        if (event.action == MotionEvent.ACTION_UP) {
          onClicked(this)
        }
        hasConsumed = true
      }
    }
    hasConsumed
  }
}
