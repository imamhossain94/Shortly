package com.newagedevs.url_shortener.view.ui.main

import android.app.Activity
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.widget.AppCompatButton
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentTransaction
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.databinding.ActivityMainBinding
import com.newagedevs.url_shortener.extensions.*
import com.newagedevs.url_shortener.model.Expander
import com.newagedevs.url_shortener.model.Shortly
import com.newagedevs.url_shortener.utils.Constants
import com.newagedevs.url_shortener.utils.DarkModeUtils
import com.newagedevs.url_shortener.view.adapter.DrawerListAdapter
import com.newagedevs.url_shortener.view.base.FragmentInfo
import com.newagedevs.url_shortener.view.ui.about.AboutActivity
import com.newagedevs.url_shortener.view.ui.fragments.ExpanderFragment
import com.newagedevs.url_shortener.view.ui.fragments.FavoriteFragment
import com.newagedevs.url_shortener.view.ui.fragments.ShortenerFragment
import com.skydoves.bindables.BindingActivity
import dev.oneuiproject.oneui.qr.QREncoder
import dev.oneuiproject.oneui.utils.ActivityUtils
import org.koin.android.viewmodel.ext.android.viewModel

class MainActivity : BindingActivity<ActivityMainBinding>(R.layout.activity_main),
    DrawerListAdapter.DrawerListener {

    private val vm: MainViewModel by viewModel()
    private var fragmentManager: FragmentManager? = null
    private val fragments: ArrayList<Fragment?> = ArrayList()
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding {
            viewModel = vm
        }

        initFragmentList()
        initDrawer()
        initFragments()
        getIntentData()
    }

    private fun getIntentData() {
        val intent = intent
        val action = intent.action
        val type = intent.type

        if ("android.intent.action.SEND" == action && type != null && "text/plain" == type) {
            val url = intent.getStringExtra("android.intent.extra.TEXT")!!

            if(isValidUrl(url)) {
                // Show dialog
                val dialog = BottomSheetDialog(this@MainActivity)
                val view = this@MainActivity.layoutInflater.inflate(R.layout.bottom_sheet_intent_data, null)
                val intentDataTextView = view.findViewById<TextView>(R.id.intent_data)
                val shortenButton = view.findViewById<AppCompatButton>(R.id.shorten_button)
                val expandButton = view.findViewById<AppCompatButton>(R.id.expand_button)

                intentDataTextView.text = url

                shortenButton.setOnClickListener {
                    vm.shortenUrl(url) { shortenedUrl ->
                        if (shortenedUrl != null) {
                            urlResultSheet(shortenedUrl, url, shortenedUrl)
                        } else {
                            vm.toast("Something went wrong!")
                        }
                    }
                    dialog.cancel()
                }

                expandButton.setOnClickListener {
                    switchFragment(1)
                    vm.expandUrl(url) { expendedUrl ->
                        if (expendedUrl != null) {
                            urlResultSheet(url, expendedUrl, expendedUrl)
                        } else {
                            vm.toast("Something went wrong!")
                        }
                    }
                    dialog.cancel()
                }

                dialog.setCancelable(true)
                //dialog.window?.clearFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND)
                dialog.setContentView(view)
                dialog.show()

            } else {
                vm.toast("Invalid URL!")
            }
        }
    }

    fun urlResultSheet(shortUrl: String, longUrl: String, qrCodeText: String) {
        val dialog = BottomSheetDialog(this@MainActivity)
        val view = this@MainActivity.layoutInflater.inflate(R.layout.bottom_sheet_url_result, null)
        val qrImageView = view.findViewById<ImageView>(R.id.qr_code)
        val shortTextView = view.findViewById<TextView>(R.id.shorten_url)
        val expandTextView = view.findViewById<TextView>(R.id.expanded_url)
        val shortenButton = view.findViewById<AppCompatButton>(R.id.copy_shorten_button)
        val expandButton = view.findViewById<AppCompatButton>(R.id.copy_expand_button)

        shortTextView.text = shortUrl
        expandTextView.text = longUrl
        qrImageView.setImageBitmap(
            QREncoder(view.context, qrCodeText)
                .setFGColor(Color.parseColor("#ff0072DE"), false, true)
                .setIcon(R.drawable.ic_link_svgrepo_com).generate()
        )

        val clipboard: ClipboardManager = this@MainActivity.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

        shortenButton.setOnClickListener {
            val clip = ClipData.newPlainText("Shortly", shortUrl)
            clipboard.setPrimaryClip(clip)
            vm.toast("Shorten urls copied!")
            dialog.cancel()
        }

        expandButton.setOnClickListener {
            val clip = ClipData.newPlainText("Shortly", longUrl)
            clipboard.setPrimaryClip(clip)
            vm.toast("Expended urls copied!")
            dialog.cancel()
        }

        dialog.setCancelable(true)
        //dialog.window?.clearFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND)
        dialog.setContentView(view)
        dialog.show()
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

    private fun switchFragment(position: Int) {
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
    }

    override fun onDrawerItemSelected(position: Int): Boolean {
        switchFragment(position)
        return true
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.main_menu, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {


        when(item.itemId) {
            R.id.menu_rate -> {
                openAppStore(this, Constants.appStoreId) { }
            }
            R.id.menu_share -> {
                shareTheApp(this)
            }
            R.id.menu_feedback -> {
                openMailApp(this, "Feedback", Constants.feedbackMail)
            }
            R.id.menu_contact -> {
                openMailApp(this, "Writing about app", Constants.contactMail)
            }
            R.id.menu_app_info -> {
                ActivityUtils.startPopOverActivity(
                    this,
                    Intent(this, AboutActivity::class.java),
                    null,
                    ActivityUtils.POP_OVER_POSITION_RIGHT or ActivityUtils.POP_OVER_POSITION_TOP
                )
                return true
            }
        }

        return false
    }



}