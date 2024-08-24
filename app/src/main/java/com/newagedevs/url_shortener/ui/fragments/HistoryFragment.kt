package com.newagedevs.url_shortener.ui.fragments

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.button.MaterialButtonToggleGroup
import com.newagedevs.url_shortener.R
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

    private lateinit var adapter: HistoryAdapter
    private lateinit var toggleButtonGroup: MaterialButtonToggleGroup
    private lateinit var recyclerView: RecyclerView

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        toggleButtonGroup = view.findViewById(R.id.toggleButton)
        recyclerView = view.findViewById(R.id.recycler_view_history)

        val clipboard: ClipboardManager = requireContext().getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

        adapter = HistoryAdapter(
            onCopy = {
                val (isShortUrl, url) = it
                if (url != null) {
                    val clip = ClipData.newPlainText("Shortly", url)
                    clipboard.setPrimaryClip(clip)
                    requireContext().showToast(if (isShortUrl) "Short URL copied!" else "Expanded URL copied!")
                } else {
                    requireContext().showToast("Cannot copy URL")
                }
            },
            onDelete = {
                viewModel.deleteUrl(it)
            }
        ) {
            mainViewModel.incrementClickCount()
            val isProUser = mainViewModel.isProUser.value ?: false
            val clickCount = mainViewModel.clickCount.value ?: 0
            if (!isProUser && clickCount >= 3) {
                mainViewModel.resetClickCount()
                (activity as? MainActivity)?.showAds()
            }

            val intent = Intent(requireContext(), ResultActivity::class.java)
            intent.putExtra("url_data", it)
            startActivity(intent)
        }

        recyclerView.layoutManager = LinearLayoutManager(requireContext())
        recyclerView.adapter = adapter

        viewModel.historyLiveData.observe(viewLifecycleOwner) { historyList ->
            val filteredList = when (toggleButtonGroup.checkedButtonId) {
                R.id.btn_shortener -> historyList.filter { it.originalUrl == it.expandedUrl }
                R.id.btn_expender -> historyList.filter { it.originalUrl == it.shortenedUrl }
                else -> historyList
            }
            adapter.submitList(filteredList)
        }

        toggleButtonGroup.check(R.id.btn_all)

        toggleButtonGroup.addOnButtonCheckedListener { _, checkedId, isChecked ->
            if (isChecked) {
                val currentList = viewModel.historyLiveData.value ?: emptyList()

                val filteredList = when (checkedId) {
                    R.id.btn_shortener -> currentList.filter { it.originalUrl == it.expandedUrl }
                    R.id.btn_expender -> currentList.filter { it.originalUrl == it.shortenedUrl }
                    R.id.btn_all -> currentList
                    else -> currentList
                }

                adapter.submitList(filteredList)
            }
        }


    }
}
