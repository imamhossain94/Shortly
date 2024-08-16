package com.newagedevs.url_shortener.data.model.cuttly

import com.google.gson.annotations.SerializedName


data class CuttlyData (

  @SerializedName("status"    ) var status    : Int?    = null,
  @SerializedName("fullLink"  ) var fullLink  : String? = null,
  @SerializedName("date"      ) var date      : String? = null,
  @SerializedName("shortLink" ) var shortLink : String? = null,
  @SerializedName("title"     ) var title     : String? = null

)