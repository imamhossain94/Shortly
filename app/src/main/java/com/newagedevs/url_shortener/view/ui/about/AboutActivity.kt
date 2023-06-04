package com.newagedevs.url_shortener.view.ui.about

import android.content.Intent
import android.content.IntentSender.SendIntentException
import android.net.ConnectivityManager
import android.net.Uri
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.AppCompatButton
import com.google.android.play.core.appupdate.AppUpdateInfo
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.UpdateAvailability
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.utils.Constants
import dev.oneuiproject.oneui.layout.AppInfoLayout


@Suppress("DEPRECATED_IDENTITY_EQUALS")
class AboutActivity : AppCompatActivity(), AppInfoLayout.OnClickListener {

    private var appInfoLayout: AppInfoLayout? = null
    private var appUpdateManager: AppUpdateManager? = null
    private var appUpdateInfo: AppUpdateInfo? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_about)
        appUpdateManager = AppUpdateManagerFactory.create(this)
        appInfoLayout = findViewById(R.id.appInfoLayout)

        checkForUpdate()

        appInfoLayout?.setMainButtonClickListener(this)

        (findViewById<View>(R.id.about_other_apps) as AppCompatButton).setOnClickListener { _: View? ->
            startActivity(
                Intent(
                    Intent.ACTION_VIEW,
                    Uri.parse(Constants.publisherName)
                )
            )
        }
        (findViewById<View>(R.id.about_source_code) as AppCompatButton).setOnClickListener { _: View? ->
            startActivity(
                Intent(
                    Intent.ACTION_VIEW,
                    Uri.parse(Constants.sourceCodeUrl)
                )
            )
        }
        (findViewById<View>(R.id.about_privacy_policy) as AppCompatButton).setOnClickListener { _: View? ->
            startActivity(
                Intent(
                    Intent.ACTION_VIEW,
                    Uri.parse(Constants.privacyPolicyUrl)
                )
            )
        }
    }

    private fun checkForUpdate() {
        appInfoLayout!!.status = AppInfoLayout.LOADING
        val networkInfo =
            (getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager).activeNetworkInfo
        if (!(networkInfo != null && networkInfo.isAvailable && networkInfo.isConnected)) {
            appInfoLayout!!.status = AppInfoLayout.NO_CONNECTION
            return
        }
        appUpdateManager?.appUpdateInfo?.addOnSuccessListener { appUpdateInfo ->
            if (appUpdateInfo.updateAvailability() === UpdateAvailability.UPDATE_AVAILABLE && appUpdateInfo.isUpdateTypeAllowed(
                    AppUpdateType.IMMEDIATE
                )
            ) {
                appInfoLayout!!.status = AppInfoLayout.UPDATE_AVAILABLE
                this.appUpdateInfo = appUpdateInfo
            } else {
                appInfoLayout!!.status = AppInfoLayout.NO_UPDATE
            }
        }?.addOnFailureListener { e ->
            e.printStackTrace()
            appInfoLayout!!.status = AppInfoLayout.NOT_UPDATEABLE
        }
    }

    override fun onUpdateClicked(v: View) {
        if (appUpdateInfo == null){
            return
        }
        else{
            try {
                appUpdateManager?.startUpdateFlowForResult(
                    appUpdateInfo!!,
                    AppUpdateType.IMMEDIATE,
                    this,
                    6000
                )
            } catch (e: SendIntentException) {
                e.printStackTrace()
            }
        }
    }

    override fun onRetryClicked(v: View) {
        checkForUpdate()
    }

}