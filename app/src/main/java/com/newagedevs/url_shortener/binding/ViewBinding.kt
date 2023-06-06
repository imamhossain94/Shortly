package com.newagedevs.url_shortener.binding

import android.graphics.Color
import android.widget.*
import androidx.databinding.BindingAdapter
import com.newagedevs.url_shortener.R
import com.skydoves.whatif.whatIfNotNullOrEmpty
import dev.oneuiproject.oneui.qr.QREncoder


object ViewBinding {

    @JvmStatic
    @BindingAdapter("toast")
    fun bindToast(view: FrameLayout, text: String?) {
        text.whatIfNotNullOrEmpty {
            Toast.makeText(view.context, it, Toast.LENGTH_SHORT).show()
        }
    }

    @JvmStatic
    @BindingAdapter(value = ["app:srcQR"], requireAll = false)
    fun srcQR(view: ImageView, content: String?) {
        view.setImageBitmap(
            QREncoder(view.context, content)
                .setFGColor(Color.parseColor("#ff0072DE"), false, true)
                .setIcon(R.drawable.ic_link_svgrepo_com).generate()
        )
    }


}
