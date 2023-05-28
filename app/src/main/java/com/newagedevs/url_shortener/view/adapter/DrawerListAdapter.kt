package com.newagedevs.url_shortener.view.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.RecyclerView
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.view.base.FragmentInfo
import com.newagedevs.url_shortener.view.viewholder.DrawerListViewHolder


class DrawerListAdapter(
    private val mContext: Context, private val mFragments: List<Fragment?>,
    private val mListener: DrawerListener?
) : RecyclerView.Adapter<DrawerListViewHolder?>() {
    private var mSelectedPos = 0

    interface DrawerListener {
        fun onDrawerItemSelected(position: Int): Boolean
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): DrawerListViewHolder {
        val inflater: LayoutInflater = LayoutInflater.from(mContext)
        val isSeparator = viewType == 0
        val view: View = if (isSeparator) {
            inflater.inflate(
                R.layout.view_drawer_list_separator, parent, false
            )
        } else {
            inflater.inflate(
                R.layout.view_drawer_list_item, parent, false
            )
        }
        return DrawerListViewHolder(view, isSeparator)
    }

    override fun onBindViewHolder(holder: DrawerListViewHolder, position: Int) {
        if (!holder.isSeparator) {
            val fragment = mFragments[position]
            if (fragment is FragmentInfo) {
                (fragment as FragmentInfo?)?.let { holder.setIcon(it.iconResId()) }
                holder.setTitle((fragment as FragmentInfo?)?.title())
            }
            holder.setSelected(position == mSelectedPos)
            holder.itemView.setOnClickListener { _ ->
                val itemPos: Int = holder.bindingAdapterPosition
                var result = false
                if (mListener != null) {
                    result = mListener.onDrawerItemSelected(itemPos)
                }
                if (result) {
                    setSelectedItem(itemPos)
                }
            }
        }
    }

    override fun getItemCount(): Int {
        return mFragments.size
    }

    override fun getItemViewType(position: Int): Int {
        return if (mFragments[position] == null) 0 else 1
    }

    fun setSelectedItem(position: Int) {
        mSelectedPos = position
        notifyItemRangeChanged(0, itemCount)
    }
}