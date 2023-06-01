package com.newagedevs.url_shortener.model.osdb

import com.google.gson.annotations.SerializedName

data class Osdb (
    @SerializedName("url") val url: String?,
)