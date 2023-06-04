package com.newagedevs.url_shortener.persistence

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.newagedevs.url_shortener.model.Expander
import com.newagedevs.url_shortener.model.Shortly

@Database(entities = [Shortly::class, Expander::class], version = 2, exportSchema = true)
//@TypeConverters(value = [])
abstract class AppDatabase : RoomDatabase() {

    abstract fun shortlyDao(): ShortlyDao

    abstract fun expanderDao(): ExpanderDao

}
