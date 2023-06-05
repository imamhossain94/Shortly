package com.newagedevs.url_shortener.persistence

import androidx.room.*
import com.newagedevs.url_shortener.model.Expander
import com.newagedevs.url_shortener.model.Shortly
import kotlinx.coroutines.flow.Flow

@Dao
interface ShortlyDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(shape: Shortly): Long

    @Query("SELECT * FROM Shortly LIMIT 1")
    fun get(): Shortly?

    @Query("SELECT * FROM Shortly ORDER BY id DESC")
    suspend fun getShortenUrlList(): List<Shortly>

    @Query("SELECT * FROM Shortly WHERE isFavorite = 1 ORDER BY id DESC")
    suspend fun getFavoritesShortenUrls(): List<Shortly>

    @Query("SELECT * FROM Shortly LIMIT 1")
    fun flow(): Flow<Shortly>

    @Query("DELETE FROM Shortly")
    fun delete()

    @Delete
    suspend fun delete(shortly: Shortly)

    @Query("DELETE FROM Shortly WHERE id = :id")
    fun deleteById(id: Long)

    @Update
    suspend fun update(shortly: Shortly)

    @Query("UPDATE Shortly SET isFavorite = :isFavorite_ WHERE id = :id_")
    suspend fun updateFavoriteById(id_: Long, isFavorite_: Boolean)

}
