package com.newagedevs.url_shortener.ui.fragments

import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.LinearLayout
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.button.MaterialButtonToggleGroup
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.data.model.UrlData
import com.newagedevs.url_shortener.ui.activities.MainActivity
import com.newagedevs.url_shortener.ui.activities.ResultActivity
import com.newagedevs.url_shortener.ui.adapters.HistoryAdapter
import com.newagedevs.url_shortener.ui.viewmodel.MainViewModel
import com.newagedevs.url_shortener.ui.viewmodel.UrlViewModel
import com.newagedevs.url_shortener.utils.showToast
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class HistoryFragment : Fragment(R.layout.fragment_history) {

    private val viewModel: UrlViewModel by activityViewModels()
    private val mainViewModel: MainViewModel by activityViewModels()

    private lateinit var recyclerView: RecyclerView
    private lateinit var emptyStateLayout: LinearLayout

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val toggleButtonGroup = view.findViewById<MaterialButtonToggleGroup>(R.id.toggleButton)
        recyclerView = view.findViewById(R.id.recycler_view_history)
        emptyStateLayout = view.findViewById(R.id.empty_state_layout)

        val clipboard = requireContext().getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

        val adapter = HistoryAdapter(
            onCopy = { (isShortUrl, url) ->
                if (!url.isNullOrBlank()) {
                    clipboard.setPrimaryClip(android.content.ClipData.newPlainText("Shortly", url))
                    requireContext().showToast(
                        if (isShortUrl) "Short URL copied!" else "Expanded URL copied!"
                    )
                } else {
                    requireContext().showToast("Cannot copy URL")
                }
            },
            onDelete = { viewModel.deleteUrl(it) }
        ) { urlData ->
            mainViewModel.incrementClickCount()
            val isProUser = mainViewModel.isProUser.value ?: false
            val clickCount = mainViewModel.clickCount.value ?: 0

            if (!isProUser && clickCount >= 3) {
                mainViewModel.resetClickCount()
                (activity as? MainActivity)?.showAds()
            }

            val intent = Intent(requireContext(), ResultActivity::class.java).apply {
                putExtra("url_data", urlData)
            }
            startActivity(intent)
        }

        recyclerView.layoutManager = LinearLayoutManager(requireContext())
        recyclerView.adapter = adapter

        // Observe full history
        viewModel.historyLiveData.observe(viewLifecycleOwner) { historyList ->
            updateList(historyList, toggleButtonGroup.checkedButtonId, adapter)
        }

        toggleButtonGroup.check(R.id.btn_all)

        toggleButtonGroup.addOnButtonCheckedListener { _, checkedId, isChecked ->
            if (isChecked) {
                updateList(
                    historyList = viewModel.historyLiveData.value ?: emptyList(),
                    checkedId = checkedId,
                    adapter = adapter
                )
            }
        }
    }

    private fun updateList(historyList: List<UrlData>, checkedId: Int, adapter: HistoryAdapter) {
        val filtered = when (checkedId) {
            R.id.btn_shortener -> historyList.filter { it.originalUrl == it.expandedUrl }
            R.id.btn_expender -> historyList.filter { it.originalUrl == it.shortenedUrl }
            else -> historyList
        }

        adapter.submitList(filtered)

        // Show/hide empty state based on filtered list
        if (filtered.isEmpty()) {
            recyclerView.visibility = View.GONE
            emptyStateLayout.visibility = View.VISIBLE
        } else {
            recyclerView.visibility = View.VISIBLE
            emptyStateLayout.visibility = View.GONE
        }
    }
}