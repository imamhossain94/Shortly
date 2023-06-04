package com.newagedevs.url_shortener.di

import com.newagedevs.url_shortener.repository.ExpanderRepository
import com.newagedevs.url_shortener.repository.ShortlyRepository
import org.koin.dsl.module

val repositoryModule = module {

    single { ShortlyRepository(get(), get()) }

    single { ExpanderRepository(get(), get()) }

}
