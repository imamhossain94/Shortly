package com.newagedevs.url_shortener.di

import android.app.Activity
import com.newagedevs.url_shortener.helper.ApplovinAdsManager
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ActivityComponent
import dagger.hilt.android.scopes.ActivityScoped

@Module
@InstallIn(ActivityComponent::class)
object AdsModule {

    @Provides
    @ActivityScoped
    fun provideApplovinAdsManager(activity: Activity): ApplovinAdsManager {
        return ApplovinAdsManager(activity)
    }
}
