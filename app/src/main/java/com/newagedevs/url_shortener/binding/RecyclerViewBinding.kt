package com.newagedevs.url_shortener.binding


import android.widget.Toast
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.databinding.BindingAdapter
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.RecyclerView
import com.newagedevs.url_shortener.model.Expander
import com.newagedevs.url_shortener.model.Shortly
import com.newagedevs.url_shortener.view.adapter.ExpanderAdapter
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
    fun bindAdapterShortenUrls(view: RecyclerView, shortenUrls: List<Shortly>?) {
        view.adapter.whatIfNotNullAs<ShortlyAdapter> { adapter ->
            adapter.addShortenUrls(shortenUrls)
            view.addItemDecoration(
                DividerItemDecoration(
                    view.context,
                    DividerItemDecoration.VERTICAL
                )
            )
        }
    }

    @JvmStatic
    @BindingAdapter("adapterExpandedUrls")
    fun bindAdapterExpandedUrls(view: RecyclerView, expandedUrls: List<Expander>?) {
        view.adapter.whatIfNotNullAs<ExpanderAdapter> { adapter ->
            adapter.addExpandedUrls(expandedUrls)
            view.addItemDecoration(
                DividerItemDecoration(
                    view.context,
                    DividerItemDecoration.VERTICAL
                )
            )
        }
    }



}
