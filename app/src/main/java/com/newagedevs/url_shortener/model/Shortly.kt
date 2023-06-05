package com.newagedevs.url_shortener.model

import android.os.Parcelable
import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.parcelize.IgnoredOnParcel
import kotlinx.parcelize.Parcelize

@Entity
@Parcelize
data class Shortly(
    val longUrl : String?,
    val provider : String?,
    val shortUrl : String?,
    val timestamp : String?,
    var isFavorite : Boolean?,
) : Parcelable {
    @IgnoredOnParcel
    @PrimaryKey(autoGenerate = true)
    var id: Long = 0
}
