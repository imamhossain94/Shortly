package com.newagedevs.url_shortener.data.model

import android.os.Parcelable
import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.parcelize.Parcelize

@Parcelize
@Entity(tableName = "url_data")
data class UrlData(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    var provider: String? = null,
    val originalUrl: String? = null,
    val shortenedUrl: String? = null,
    val expandedUrl: String? = null,
    val success: Boolean? = null,
    val timestamp: Long = System.currentTimeMillis()
) : Parcelable
