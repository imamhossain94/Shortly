package com.newagedevs.url_shortener.data.local.db

import androidx.room.Database
import androidx.room.RoomDatabase
import com.newagedevs.url_shortener.data.model.UrlData

@Database(entities = [UrlData::class], version = 1)
abstract class AppDatabase : RoomDatabase() {
    abstract fun urlDao(): UrlDao
}

