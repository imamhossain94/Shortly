package com.newagedevs.url_shortener.persistence

import androidx.room.*
import com.newagedevs.url_shortener.model.Expander
import kotlinx.coroutines.flow.Flow

@Dao
interface ExpanderDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(shape: Expander): Long

    @Query("SELECT * FROM Expander LIMIT 1")
    fun get(): Expander?

    @Query("SELECT * FROM Expander ORDER BY id DESC")
    fun getExpandedUrlList(): List<Expander>

    @Query("SELECT * FROM Expander LIMIT 1")
    fun flow(): Flow<Expander>

    @Query("DELETE FROM Expander")
    fun delete()

}
