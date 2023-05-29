package com.newagedevs.url_shortener.view.ui.fragments

import android.content.Context
import android.database.MatrixCursor
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.MarginLayoutParams
import android.widget.ArrayAdapter
import android.widget.ImageView
import android.widget.SectionIndexer
import android.widget.TextView
import androidx.appcompat.util.SeslRoundedCorner
import androidx.appcompat.util.SeslSubheaderRoundedCorner
import androidx.appcompat.widget.AppCompatSpinner
import androidx.indexscroll.widget.SeslCursorIndexer
import androidx.indexscroll.widget.SeslIndexScrollView
import androidx.indexscroll.widget.SeslIndexScrollView.OnIndexBarEventListener
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.databinding.FragmentShorteneBinding
import com.newagedevs.url_shortener.view.base.FragmentInfo
import com.newagedevs.url_shortener.view.ui.main.MainViewModel
import com.skydoves.bindables.BindingFragment
import dev.oneuiproject.oneui.utils.IndexScrollUtils
import dev.oneuiproject.oneui.widget.Separator
import org.koin.android.viewmodel.ext.android.sharedViewModel


open class ShortenerFragment : BindingFragment<FragmentShorteneBinding>(R.layout.fragment_shortene),
    FragmentInfo {


    private var mCurrentSectionIndex = 0
    private var mListView: RecyclerView? = null
    private var mIndexScrollView: SeslIndexScrollView? = null

    private val mIsTextModeEnabled = false
    private var mIsIndexBarPressed = false
    private val mHideIndexBar =
        Runnable { IndexScrollUtils.animateVisibility(mIndexScrollView!!, false) }

    private val vm: MainViewModel by sharedViewModel()


    var mContext: Context? = null

    override fun onAttach(context: Context) {
        super.onAttach(context)
        mContext = context
    }


    override fun onCreateView(
    inflater: LayoutInflater,
    container: ViewGroup?,
    savedInstanceState: Bundle?
    ): View {
        super.onCreateView(inflater, container, savedInstanceState)

        return binding {
          viewModel = vm
        }.root

    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        mIndexScrollView = view.findViewById(R.id.indexscroll_view)
        initListView(view)
        initIndexScroll()
    }


    override fun layoutResId(): Int {
        return R.layout.fragment_shortene
    }

    override fun iconResId(): Int {
        return R.drawable.ic_link_short_svgrepo_com
    }

    override fun title(): CharSequence {
        return "URL Shortener"
    }

    override fun isAppBarEnabled(): Boolean {
        return true
    }

    private fun initSpinner(view: View) {
        val spinner = view.findViewById<AppCompatSpinner>(R.id.apppicker_spinner)
        val categories: MutableList<String> = ArrayList()
        categories.add("cutt.ly")
        categories.add("chilp.it")
        categories.add("clck.ru")
        categories.add("da.gd")
        categories.add("git.io")
        categories.add("is.gd")
        categories.add("os.db")
        categories.add("qps.ru")
        categories.add("tinyURL")
        val adapter = ArrayAdapter(requireContext(), android.R.layout.simple_spinner_item, categories)
        adapter.setDropDownViewResource(androidx.appcompat.R.layout.support_simple_spinner_dropdown_item)
        spinner.adapter = adapter
        //spinner.setOnItemSelectedListener(this)
    }


    private fun initListView(view: View) {
        mListView = view.findViewById(R.id.indexscroll_list)
        mListView!!.layoutManager = LinearLayoutManager(requireContext())
        mListView!!.adapter = IndexAdapter()
        mListView!!.addItemDecoration(ItemDecoration(requireContext()))
        mListView!!.itemAnimator = null
        mListView!!.seslSetFillBottomEnabled(true)
        mListView!!.seslSetLastRoundedCorner(true)
        mListView!!.seslSetIndexTipEnabled(true)
        mListView!!.seslSetGoToTopEnabled(true)
        mListView!!.seslSetSmoothScrollEnabled(true)
    }

    private fun initIndexScroll() {
        val isRtl = resources.configuration.layoutDirection === View.LAYOUT_DIRECTION_RTL
        mIndexScrollView!!.setIndexBarGravity(if (isRtl) SeslIndexScrollView.GRAVITY_INDEX_BAR_LEFT else SeslIndexScrollView.GRAVITY_INDEX_BAR_RIGHT)
        val cursor = MatrixCursor(arrayOf("item"))
        for (item in listItems) {
            cursor.addRow(arrayOf(item))
        }
        cursor.moveToFirst()
        val indexer = SeslCursorIndexer(
            cursor, 0,
            "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,Б".split(",").toTypedArray(), 0
        )
        indexer.setGroupItemsCount(1)
        indexer.setMiscItemsCount(3)
        mIndexScrollView!!.setIndexer(indexer)
        mIndexScrollView!!.setOnIndexBarEventListener(
            object : OnIndexBarEventListener {
                override fun onIndexChanged(sectionIndex: Int) {
                    if (mCurrentSectionIndex != sectionIndex) {
                        mCurrentSectionIndex = sectionIndex
                        if (mListView!!.scrollState != RecyclerView.SCROLL_STATE_IDLE) {
                            mListView!!.stopScroll()
                        }
                        (mListView!!.layoutManager as LinearLayoutManager?)
                            ?.scrollToPositionWithOffset(sectionIndex, 0)
                    }
                }

                override fun onPressed(v: Float) {
                    mIsIndexBarPressed = true
                    mListView!!.removeCallbacks(mHideIndexBar)
                }

                override fun onReleased(v: Float) {
                    mIsIndexBarPressed = false
                    if (mListView!!.scrollState == RecyclerView.SCROLL_STATE_IDLE) {
                        mListView!!.postDelayed(mHideIndexBar, 1500)
                    }
                }
            })
        mIndexScrollView!!.attachToRecyclerView(mListView)
        mListView!!.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                super.onScrollStateChanged(recyclerView, newState)
                if (newState == RecyclerView.SCROLL_STATE_IDLE
                    && !mIsIndexBarPressed
                ) {
                    recyclerView.postDelayed(mHideIndexBar, 1500)
                } else {
                    mListView!!.removeCallbacks(mHideIndexBar)
                    IndexScrollUtils.animateVisibility(mIndexScrollView!!, true)
                }
            }
        })
    }

    inner class IndexAdapter internal constructor() : RecyclerView.Adapter<IndexAdapter.ViewHolder>(),
        SectionIndexer {
        var mSections: MutableList<String> = java.util.ArrayList()
        var mPositionForSection: MutableList<Int> = java.util.ArrayList()
        var mSectionForPosition: MutableList<Int> = java.util.ArrayList()

        init {
            mSections.add("")
            mPositionForSection.add(0)
            mSectionForPosition.add(0)
            for (i in 1 until listItems.size) {
                val letter: String = listItems.get(i)
                if (letter.length == 1) {
                    mSections.add(letter)
                    mPositionForSection.add(i)
                }
                mSectionForPosition.add(mSections.size - 1)
            }
        }

        override fun getItemCount(): Int {
            return listItems.size
        }

        override fun getItemViewType(position: Int): Int {
            return if (listItems.get(position).length == 1) 1 else 0
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
            return if (viewType == 0) {
                val inflater = LayoutInflater.from(mContext)
                val view: View = inflater.inflate(
                    R.layout.view_indexscroll_listview_item, parent, false
                )
                ViewHolder(view, false)
            } else {
                ViewHolder(Separator(mContext!!), true)
            }
        }

        override fun onBindViewHolder(holder: ViewHolder, position: Int) {
            if (holder.isSeparator) {
                holder.textView!!.layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT
                )
            } else {
                if (position == 0) {
                    holder.imageView!!.setImageResource(R.drawable.indexscroll_group_icon)
                } else {
                    holder.imageView!!.setImageResource(R.drawable.indexscroll_item_icon)
                }
            }
            holder.textView!!.setText(listItems.get(position))
        }

        override fun getSections(): Array<Any> {
            return mSections.toTypedArray()
        }

        override fun getPositionForSection(sectionIndex: Int): Int {
            return mPositionForSection[sectionIndex]
        }

        override fun getSectionForPosition(position: Int): Int {
            return mSectionForPosition[position]
        }

        inner class ViewHolder internal constructor(itemView: View, var isSeparator: Boolean) :
            RecyclerView.ViewHolder(itemView) {
            var imageView: ImageView? = null
            var textView: TextView? = null

            init {
                if (isSeparator) {
                    textView = itemView as TextView
                } else {
                    imageView = itemView.findViewById(R.id.indexscroll_list_item_icon)
                    textView = itemView.findViewById(R.id.indexscroll_list_item_text)
                }
            }
        }
    }

    private inner class ItemDecoration(context: Context) :
        RecyclerView.ItemDecoration() {
        private val mDivider: Drawable?
        private val mRoundedCorner: SeslSubheaderRoundedCorner

        init {
            val outValue = TypedValue()
            context.theme.resolveAttribute(androidx.appcompat.R.attr.isLightTheme, outValue, true)
            mDivider =
                context.getDrawable(if (outValue.data == 0) androidx.appcompat.R.drawable.sesl_list_divider_dark else androidx.appcompat.R.drawable.sesl_list_divider_light)
            mRoundedCorner = SeslSubheaderRoundedCorner(mContext)
            mRoundedCorner.roundedCorners = SeslRoundedCorner.ROUNDED_CORNER_ALL
        }

        override fun onDraw(
            c: Canvas, parent: RecyclerView,
            state: RecyclerView.State
        ) {
            super.onDraw(c, parent, state)
            for (i in 0 until parent.childCount) {
                val child = parent.getChildAt(i)
                val holder = mListView!!.getChildViewHolder(child) as IndexAdapter.ViewHolder
                if (!holder.isSeparator) {
                    val top = (child.bottom
                            + (child.layoutParams as MarginLayoutParams).bottomMargin)
                    val bottom = mDivider!!.intrinsicHeight + top
                    mDivider.setBounds(parent.left, top, parent.right, bottom)
                    mDivider.draw(c)
                }
            }
        }

        override fun seslOnDispatchDraw(
            c: Canvas,
            parent: RecyclerView,
            state: RecyclerView.State
        ) {
            for (i in 0 until parent.childCount) {
                val child = parent.getChildAt(i)
                val holder = mListView!!.getChildViewHolder(child) as IndexAdapter.ViewHolder
                if (holder.isSeparator) {
                    mRoundedCorner.drawRoundedCorner(child, c)
                }
            }
        }
    }

}

var listItems = arrayOf(
    "Groups",
    "A",
    "Alice",
    "Ashten",
    "Avery",
    "B",
    "Bailee",
    "Bailey",
    "Beck",
    "Benjamin",
    "Berlynn",
    "Bernice",
    "Bianca",
    "Blair",
    "Blaise",
    "Blake",
    "Blanche",
    "Blayne",
    "Bram",
    "Brandt",
    "D",
    "Damien",
    "Damon",
    "Daniel",
    "Dante",
    "Dash",
    "David",
    "Dawn",
    "Dean",
    "Debree",
    "Denise",
    "Denver",
    "Devon",
    "Dex",
    "Dezi",
    "Dominick",
    "Doran",
    "Drake",
    "Drew",
    "Dustin",
    "#",
    "040404",
    "121002"
)
