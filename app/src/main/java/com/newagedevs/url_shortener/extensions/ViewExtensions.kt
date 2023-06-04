package com.newagedevs.url_shortener.extensions

import android.annotation.SuppressLint
import android.content.ClipboardManager
import android.content.Context
import android.view.MotionEvent
import android.view.View
import android.view.inputmethod.InputMethodManager
import androidx.appcompat.widget.AppCompatEditText

fun View.visible() {
  visibility = View.VISIBLE
}


@SuppressLint("ClickableViewAccessibility")
fun AppCompatEditText.onDrawableClicked(context: Context) {
  this.setOnTouchListener { _, event ->
    if (event.action == MotionEvent.ACTION_UP) {
      if (event.rawX <= (this.right - this.compoundDrawables[0].bounds.width())) {

        val clipboard = (context.getSystemService(Context.CLIPBOARD_SERVICE)) as? ClipboardManager
        val textToPaste: CharSequence? = clipboard?.primaryClip?.getItemAt(0)?.text ?: null

        this.setText(textToPaste)

        if(textToPaste != null) {
          this.setSelection(textToPaste.length)

          this.requestFocus()
          this.postDelayed({

            val inputMethodManager =
              context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager?
            inputMethodManager!!.showSoftInput(this, InputMethodManager.SHOW_IMPLICIT)

          }, 200)
        }
        
        return@setOnTouchListener true
      }
      if (event.rawX >= (this.right - this.compoundDrawables[2].bounds.width())) {
        this.text = null
        return@setOnTouchListener true
      }
    }
    false
  }
}



@SuppressLint("ClickableViewAccessibility")
fun AppCompatEditText.onLeftDrawableClicked(onClicked: (view: AppCompatEditText) -> Unit) {
  this.setOnTouchListener { _, event ->
    if (event.action == MotionEvent.ACTION_UP) {
      if (event.rawX <= (this.right - this.compoundDrawables[0].bounds.width())) {
        onClicked(this)
        return@setOnTouchListener true
      }
    }
    false
  }
}

@SuppressLint("ClickableViewAccessibility")
fun AppCompatEditText.onRightDrawableClicked(onClicked: (view: AppCompatEditText) -> Unit) {
  this.setOnTouchListener { _, event ->
    if (event.action == MotionEvent.ACTION_UP) {
      if (event.rawX >= (this.right - this.compoundDrawables[2].bounds.width())) {
        onClicked(this)
        return@setOnTouchListener true
      }
    }
    false
  }
}
