package com.newagedevs.url_shortener.di

import com.newagedevs.url_shortener.repository.MainRepository
import org.koin.dsl.module

val repositoryModule = module {

    single { MainRepository(get()) }

}
