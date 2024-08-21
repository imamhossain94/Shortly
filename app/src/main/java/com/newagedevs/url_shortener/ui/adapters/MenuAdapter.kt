package com.newagedevs.url_shortener.ui.adapters

import android.graphics.drawable.Drawable
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.newagedevs.url_shortener.R

class MenuAdapter(val onClick: (MenuItem) -> Unit) : ListAdapter<MenuAdapter.MenuItem, MenuAdapter.MenuViewHolder>(MenuDiffCallback()) {

    data class MenuItem(
        val icon: Drawable?,
        val title: String,
    )

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MenuViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_menu, parent, false)
        return MenuViewHolder(view)
    }

    override fun onBindViewHolder(holder: MenuViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class MenuViewHolder(private val view: View) : RecyclerView.ViewHolder(view) {
        private val titleText: TextView = view.findViewById(R.id.menu_title)
        private val iconImageView: ImageView = view.findViewById(R.id.menu_icon)

        fun bind(menuItem: MenuItem) {
            titleText.text = menuItem.title
            iconImageView.setImageDrawable(menuItem.icon)
            view.setOnClickListener { onClick(menuItem) }
        }
    }

    class MenuDiffCallback : DiffUtil.ItemCallback<MenuItem>() {
        override fun areItemsTheSame(oldItem: MenuItem, newItem: MenuItem): Boolean {
            // Assuming titles are unique identifiers for each menu item
            return oldItem.title == newItem.title
        }

        override fun areContentsTheSame(oldItem: MenuItem, newItem: MenuItem): Boolean {
            return oldItem == newItem
        }
    }
}
