package com.newagedevs.url_shortener.data.model

import com.google.gson.annotations.SerializedName

data class Osdb (
    @SerializedName("url") val url: String?,
)