package com.newagedevs.url_shortener.view.viewholder

import android.graphics.Typeface
import android.text.TextUtils
import android.view.View
import android.widget.TextView
import androidx.annotation.DrawableRes
import androidx.appcompat.widget.AppCompatImageView
import androidx.recyclerview.widget.RecyclerView
import com.newagedevs.url_shortener.R

class DrawerListViewHolder(itemView: View, val isSeparator: Boolean) :
    RecyclerView.ViewHolder(itemView) {
    private var mNormalTypeface: Typeface? = null
    private var mSelectedTypeface: Typeface? = null
    private var mIconView: AppCompatImageView? = null
    private var mTitleView: TextView? = null

    init {
        if (!isSeparator) {
            mIconView = itemView.findViewById<AppCompatImageView>(R.id.drawer_item_icon)
            mTitleView = itemView.findViewById<TextView>(R.id.drawer_item_title)
            mNormalTypeface = Typeface.create("sec-roboto-light", Typeface.NORMAL)
            mSelectedTypeface = Typeface.create("sec-roboto-light", Typeface.BOLD)
        }
    }

    fun setIcon(@DrawableRes resId: Int) {
        if (!isSeparator) {
            mIconView?.setImageResource(resId)
        }
    }

    fun setTitle(title: CharSequence?) {
        if (!isSeparator) {
            mTitleView?.text = title
        }
    }

    fun setSelected(selected: Boolean) {
        if (!isSeparator) {
            itemView.isSelected = selected
            mTitleView?.typeface = if (selected) mSelectedTypeface else mNormalTypeface
            mTitleView?.ellipsize = if (selected) TextUtils.TruncateAt.MARQUEE else TextUtils.TruncateAt.END
        }
    }
}