package com.newagedevs.url_shortener.ui.activities

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.google.android.material.appbar.MaterialToolbar
import com.google.android.material.button.MaterialButton
import com.google.android.material.checkbox.MaterialCheckBox
import com.google.android.material.textfield.TextInputLayout
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.utils.Constants
import com.newagedevs.url_shortener.utils.openMailApp

class FeedbackActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_feedback)

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.result_main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        val topAppBar = findViewById<MaterialToolbar>(R.id.topAppBar)
        topAppBar.setNavigationOnClickListener { finish() }

        val cancelButton = findViewById<MaterialButton>(R.id.cancel_button)
        val sendButton = findViewById<MaterialButton>(R.id.send_button)
        val otherIssue = findViewById<TextInputLayout>(R.id.other_issue)

        val checkBoxes = listOf(
            R.id.checkbox_app_crashes to "App crashes a lot",
            R.id.checkbox_too_many_ads to "Too many ads",
            R.id.checkbox_app_freezes to "App freezes or becomes unresponsive",
            R.id.checkbox_not_user_friendly to "App is not user-friendly"
        ).map { (id, label) ->
            findViewById<MaterialCheckBox>(id) to label
        }

        cancelButton.setOnClickListener { finish() }

        sendButton.setOnClickListener {
            val selected = checkBoxes
                .filter { (checkbox, _) -> checkbox.isChecked }
                .map { (_, label) -> label }

            val otherText = otherIssue.editText?.text.toString().trim()

            val message = buildString {
                if (selected.isNotEmpty()) {
                    append("Selected issues:\n")
                    append(selected.joinToString("\n") { "- $it" })
                }
                if (otherText.isNotEmpty()) {
                    if (isNotEmpty()) append("\n\n")
                    append("Other feedback:\n$otherText")
                }
                if (isEmpty()) {
                    append("No feedback provided.")
                }
            }

            openMailApp(this, getString(R.string.app_feedback), Constants.FEEDBACK_MAIL, message)
        }
    }
}