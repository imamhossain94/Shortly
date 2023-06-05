package com.newagedevs.url_shortener.persistence

import androidx.room.*
import com.newagedevs.url_shortener.model.Expander
import com.newagedevs.url_shortener.model.Shortly
import kotlinx.coroutines.flow.Flow

@Dao
interface ExpanderDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(shape: Expander): Long

    @Query("SELECT * FROM Expander LIMIT 1")
    fun get(): Expander?

    @Query("SELECT * FROM Expander ORDER BY id DESC")
    suspend fun getExpandedUrlList(): List<Expander>

    @Query("SELECT * FROM Expander WHERE isFavorite = 1 ORDER BY id DESC")
    suspend fun getFavoriteExpandedUrls(): List<Expander>

    @Query("SELECT * FROM Expander LIMIT 1")
    fun flow(): Flow<Expander>

    @Query("DELETE FROM Expander")
    fun delete()

    @Delete
    suspend fun delete(expander: Expander)

    @Query("DELETE FROM Expander WHERE id = :id")
    fun deleteById(id: Long)

    @Update
    suspend fun update(expander: Expander)

    @Query("UPDATE Expander SET isFavorite = :isFavorite_ WHERE id = :id_")
    suspend fun updateFavoriteById(id_: Long, isFavorite_: Boolean)

}
