package com.newagedevs.url_shortener.view.base

interface FragmentInfo {
    fun layoutResId(): Int
    fun iconResId(): Int
    fun title(): CharSequence?
    fun isAppBarEnabled(): Boolean
}