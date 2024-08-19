package com.newagedevs.url_shortener.di

import android.content.Context
import androidx.room.Room
import com.newagedevs.url_shortener.data.local.db.AppDatabase
import com.newagedevs.url_shortener.data.local.db.UrlDao
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): AppDatabase {
        return Room.databaseBuilder(
            context,
            AppDatabase::class.java,
            "shortly_db"
        ).fallbackToDestructiveMigration().build()
    }

    @Provides
    @Singleton
    fun provideUrlDao(database: AppDatabase): UrlDao {
        return database.urlDao()
    }
}

