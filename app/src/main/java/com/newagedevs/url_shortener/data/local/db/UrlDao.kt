package com.newagedevs.url_shortener.data.local.db

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.newagedevs.url_shortener.data.model.UrlData

@Dao
interface UrlDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUrl(urlData: UrlData)

    @Query("SELECT * FROM url_data ORDER BY timestamp DESC")
    fun getAllUrls(): LiveData<List<UrlData>>

    @Query("DELETE FROM url_data WHERE id = :id")
    suspend fun deleteUrlByID(id: Int)

    @Delete
    suspend fun deleteUrl(urlData: UrlData)
}
