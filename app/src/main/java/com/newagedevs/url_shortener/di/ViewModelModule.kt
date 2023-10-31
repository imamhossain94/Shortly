package com.newagedevs.url_shortener.di

import com.newagedevs.url_shortener.view.ui.main.MainViewModel
import org.koin.android.viewmodel.dsl.viewModel
import org.koin.dsl.module

val viewModelModule = module {

    viewModel { MainViewModel(get(), get()) }

}
