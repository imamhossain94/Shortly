package com.newagedevs.url_shortener.persistence

import androidx.room.*
import com.newagedevs.url_shortener.model.Shortly
import kotlinx.coroutines.flow.Flow

@Dao
interface ShortlyDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(shape: Shortly): Long

    @Query("SELECT * FROM Shortly LIMIT 1")
    fun get(): Shortly?

    @Query("SELECT * FROM Shortly ORDER BY id DESC")
    fun getShortenUrlList(): List<Shortly>

    @Query("SELECT * FROM Shortly LIMIT 1")
    fun flow(): Flow<Shortly>

    @Query("DELETE FROM Shortly")
    fun delete()

}
