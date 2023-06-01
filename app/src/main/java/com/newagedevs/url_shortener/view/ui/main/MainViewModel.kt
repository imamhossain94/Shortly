package com.newagedevs.url_shortener.view.ui.main

import androidx.databinding.Bindable
import com.newagedevs.url_shortener.repository.ShortlyRepository
import com.skydoves.bindables.BindingViewModel
import com.skydoves.bindables.bindingProperty
import timber.log.Timber


class MainViewModel constructor(
    private val repository: ShortlyRepository
) : BindingViewModel() {

    @get:Bindable
    var toast: String? by bindingProperty(null)

//    @get:Bindable
//    var gravity: String? by bindingProperty("Right")
//
//    @get:Bindable
//    var gravityIcon: Int? by bindingProperty(R.drawable.ic_align_right)



    private fun initializeData() {

    }


    init {
        Timber.d("injection DashboardViewModel")
        initializeData()
    }

}


