package com.newagedevs.url_shortener.binding


import android.widget.Toast
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.databinding.BindingAdapter
import androidx.recyclerview.widget.RecyclerView
import com.newagedevs.url_shortener.model.Shortly
import com.newagedevs.url_shortener.view.adapter.ShortlyAdapter
import com.skydoves.whatif.whatIfNotNullAs
import com.skydoves.whatif.whatIfNotNullOrEmpty

object RecyclerViewBinding {
    @JvmStatic
    @BindingAdapter("adapter")
    fun bindAdapter(view: RecyclerView, baseAdapter: RecyclerView.Adapter<*>) {
        view.adapter = baseAdapter
    }

    @JvmStatic
    @BindingAdapter("toast")
    fun bindToast(view: ConstraintLayout, text: String?) {
        text.whatIfNotNullOrEmpty {
            Toast.makeText(view.context, it, Toast.LENGTH_SHORT).show()
        }
    }

    @JvmStatic
    @BindingAdapter("adapterShortenUrls")
    fun bindAdapterShortenUrls(view: RecyclerView, posters: List<Shortly>?) {
        posters.whatIfNotNullOrEmpty { items ->
            view.adapter.whatIfNotNullAs<ShortlyAdapter> { adapter ->
                adapter.addPosterList(items)
            }
        }
    }



}
