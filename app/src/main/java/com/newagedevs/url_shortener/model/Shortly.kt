package com.newagedevs.url_shortener.model

import android.os.Parcelable
import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.parcelize.IgnoredOnParcel
import kotlinx.parcelize.Parcelize

@Entity
@Parcelize
data class Shortly(
    var longUrl : String?,
    var provider : String?,
    var shortUrl : String?,
    var timestamp : String?,
    var isFavorite : Boolean?,
) : Parcelable {
    @IgnoredOnParcel
    @PrimaryKey(autoGenerate = true)
    var id: Long = 0
}
