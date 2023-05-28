package com.newagedevs.url_shortener.view.ui.main

import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentTransaction
import androidx.recyclerview.widget.LinearLayoutManager
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.databinding.ActivityMainBinding
import com.newagedevs.url_shortener.utils.DarkModeUtils
import com.newagedevs.url_shortener.view.adapter.DrawerListAdapter
import com.newagedevs.url_shortener.view.base.FragmentInfo
import com.newagedevs.url_shortener.view.ui.about.AboutActivity
import com.newagedevs.url_shortener.view.ui.fragments.ExpanderFragment
import com.newagedevs.url_shortener.view.ui.fragments.FavoriteFragment
import com.newagedevs.url_shortener.view.ui.fragments.ShortenerFragment
import com.skydoves.bindables.BindingActivity
import dev.oneuiproject.oneui.utils.ActivityUtils
import org.koin.android.viewmodel.ext.android.viewModel

class MainActivity : BindingActivity<ActivityMainBinding>(R.layout.activity_main),
    DrawerListAdapter.DrawerListener {

    private val viewModel: MainViewModel by viewModel()
    private var fragmentManager: FragmentManager? = null
    private val fragments: ArrayList<Fragment?> = ArrayList()
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding {
            viewModel = viewModel
        }

        initFragmentList()
        initDrawer()
        initFragments()
    }

    override fun attachBaseContext(context: Context?) {
        if (Build.VERSION.SDK_INT <= 28) {
            super.attachBaseContext(context?.let { DarkModeUtils.createDarkModeContextWrapper(it) })
        } else {
            super.attachBaseContext(context)
        }
    }

    private fun initFragmentList() {

        fragments.add(ShortenerFragment())
        fragments.add(ExpanderFragment())
        fragments.add(null)
        fragments.add(FavoriteFragment())

    }


    override fun onBackPressed() {
        if (Build.VERSION.SDK_INT == Build.VERSION_CODES.O && isTaskRoot
            && fragmentManager?.backStackEntryCount == 0
        ) {
            finishAfterTransition()
        } else {
            super.onBackPressed()
        }
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        if (Build.VERSION.SDK_INT <= 28) {
            val res = resources
            res.configuration.setTo(DarkModeUtils.createDarkModeConfig(this, newConfig))
        }
    }
    

    private fun initDrawer() {

        binding.drawerLayout.setDrawerButtonIcon(getDrawable(dev.oneuiproject.oneui.R.drawable.ic_oui_ab_app_info))
        binding.drawerLayout.setDrawerButtonTooltip("About page")
        binding.drawerLayout.setDrawerButtonOnClickListener { _ ->
            ActivityUtils.startPopOverActivity(
                this,
                Intent(this@MainActivity, AboutActivity::class.java),
                null,
                ActivityUtils.POP_OVER_POSITION_TOP or ActivityUtils.POP_OVER_POSITION_CENTER_HORIZONTAL
            )
        }

        binding.drawerListView.layoutManager = LinearLayoutManager(this)
        binding.drawerListView.adapter = DrawerListAdapter(this, fragments, this)
        binding.drawerListView.itemAnimator = null
        binding.drawerListView.setHasFixedSize(true)
        binding.drawerListView.seslSetLastRoundedCorner(false)
    }

    private fun initFragments() {
        fragmentManager = supportFragmentManager
        val transaction: FragmentTransaction = fragmentManager!!.beginTransaction()
        for (fragment in fragments) {
            if (fragment != null) transaction.add(R.id.main_content, fragment)
        }
        transaction.commit()
        fragmentManager?.executePendingTransactions()
        onDrawerItemSelected(0)
    }

    override fun onDrawerItemSelected(position: Int): Boolean {
        val newFragment: Fragment = fragments[position]!!
        val transaction: FragmentTransaction = fragmentManager!!.beginTransaction()
        for (fragment in fragmentManager!!.fragments) {
            transaction.hide(fragment!!)
        }
        transaction.show(newFragment).commit()
        if (newFragment is FragmentInfo) {
            if (!(newFragment as FragmentInfo).isAppBarEnabled()) {
                binding.drawerLayout.setExpanded(false, false)
                binding.drawerLayout.isExpandable = false
            } else {
                binding.drawerLayout.isExpandable = true
                binding.drawerLayout.setExpanded(false, false)
            }
            binding.drawerLayout.setTitle(
                getString(R.string.app_name),
                (newFragment as FragmentInfo).title()
            )
            binding.drawerLayout.setExpandedSubtitle((newFragment as FragmentInfo).title())
        }
        binding.drawerLayout.setDrawerOpen(false, true)
        return true
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.main_menu, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        if (item.itemId == R.id.menu_app_info) {
//            ActivityUtils.startPopOverActivity(
//                this,
//                null,//Intent(this, Example::class.java)
//                null,
//                ActivityUtils.POP_OVER_POSITION_RIGHT or ActivityUtils.POP_OVER_POSITION_TOP
//            )
            return true
        }
        return false
    }



}