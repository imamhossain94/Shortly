package com.newagedevs.url_shortener.persistence

import androidx.room.*
import com.newagedevs.url_shortener.model.Model
import kotlinx.coroutines.flow.Flow

@Dao
interface ModelDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(shape: Model): Long

    @Query("SELECT * FROM Model LIMIT 1")
    fun get(): Model?

    @Query("SELECT * FROM Model LIMIT 1")
    fun flow(): Flow<Model>

    @Query("DELETE FROM Model")
    fun delete()

}
