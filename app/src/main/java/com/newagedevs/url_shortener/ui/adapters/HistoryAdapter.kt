package com.newagedevs.url_shortener.ui.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.data.model.UrlData
import com.newagedevs.url_shortener.utils.getUrl

class HistoryAdapter(private val onCopy: (Pair<Boolean, String?>) -> Unit, private val onDelete: (UrlData) -> Unit, private val onClick: (UrlData) -> Unit) : ListAdapter<UrlData, HistoryAdapter.HistoryViewHolder>(DiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): HistoryViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_history, parent, false)
        return HistoryViewHolder(view)
    }

    override fun onBindViewHolder(holder: HistoryViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class HistoryViewHolder(private val view: View) : RecyclerView.ViewHolder(view) {
        private val titleText: TextView = view.findViewById(R.id.title)
        private val shortUrlText: TextView = view.findViewById(R.id.short_url)
        private val expendedUrlText: TextView = view.findViewById(R.id.expended_url)
        private val copyButton: Button = view.findViewById(R.id.btn_copy)
        private val deleteButton: Button = view.findViewById(R.id.btn_delete)

        fun bind(urlData: UrlData) {
            titleText.text = if (urlData.originalUrl == urlData.expandedUrl) "Shortened" else "Expended"
            shortUrlText.text = urlData.shortenedUrl?.trim()
            expendedUrlText.text = urlData.expandedUrl?.trim()

            view.setOnClickListener { onClick(urlData) }
            deleteButton.setOnClickListener { onDelete(urlData) }
            copyButton.setOnClickListener { onCopy(urlData.getUrl()) }

            shortUrlText.setOnClickListener { onClick(urlData) }
            shortUrlText.setOnLongClickListener {
                onCopy(Pair(true, urlData.shortenedUrl))
                return@setOnLongClickListener true
            }

            expendedUrlText.setOnClickListener { onClick(urlData) }
            expendedUrlText.setOnLongClickListener {
                onCopy(Pair(false, urlData.expandedUrl))
                return@setOnLongClickListener true
            }
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


