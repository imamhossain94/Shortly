package com.newagedevs.url_shortener.view.ui.main

import android.content.Intent
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.databinding.ActivityMainBinding
import com.skydoves.bindables.BindingActivity
import dev.oneuiproject.oneui.utils.ActivityUtils
import org.koin.android.viewmodel.ext.android.viewModel

class MainActivity : BindingActivity<ActivityMainBinding>(R.layout.activity_main) {

    private val viewModel: MainViewModel by viewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding {
            viewModel = viewModel
        }


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