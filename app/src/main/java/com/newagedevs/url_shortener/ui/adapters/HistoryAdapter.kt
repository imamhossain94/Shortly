package com.newagedevs.url_shortener.ui.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.data.model.UrlData

class HistoryAdapter : ListAdapter<UrlData, HistoryAdapter.HistoryViewHolder>(DiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): HistoryViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_history, parent, false)
        return HistoryViewHolder(view)
    }

    override fun onBindViewHolder(holder: HistoryViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class HistoryViewHolder(private val view: View) : RecyclerView.ViewHolder(view) {
        private val originalUrlText: TextView = view.findViewById(R.id.original_url)
        private val shortUrlText: TextView = view.findViewById(R.id.short_url)

        fun bind(urlData: UrlData) {
            originalUrlText.text = urlData.originalUrl
            shortUrlText.text = urlData.shortenedUrl ?: "N/A"
        }
    }

    class DiffCallback : DiffUtil.ItemCallback<UrlData>() {
        override fun areItemsTheSame(oldItem: UrlData, newItem: UrlData): Boolean {
            return oldItem.originalUrl == newItem.originalUrl
        }

        override fun areContentsTheSame(oldItem: UrlData, newItem: UrlData): Boolean {
            return oldItem == newItem
        }
    }
}
