package com.newagedevs.url_shortener.ui.fragments

import android.os.Bundle
import android.view.View
import android.widget.Button
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.button.MaterialButtonToggleGroup
import com.google.android.material.textfield.TextInputEditText
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.ui.adapters.HistoryAdapter
import com.newagedevs.url_shortener.ui.viewmodel.MainViewModel
import dagger.hilt.android.AndroidEntryPoint


@AndroidEntryPoint
class HistoryFragment : Fragment(R.layout.fragment_history) {

    private val viewModel: MainViewModel by viewModels()
    private lateinit var adapter: HistoryAdapter

    private lateinit var toggleButtonGroup: MaterialButtonToggleGroup
    private lateinit var recyclerView: RecyclerView

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        toggleButtonGroup = view.findViewById(R.id.toggleButton)
        recyclerView = view.findViewById(R.id.recycler_view_history)

        adapter = HistoryAdapter(
            onCopy = {

            }
        ) { urlData ->
            viewModel.deleteUrl(urlData)
        }
        recyclerView.layoutManager = LinearLayoutManager(requireContext())
        recyclerView.adapter = adapter

        // Assuming you have a ViewModel instance named viewModel
        viewModel.historyLiveData.observe(viewLifecycleOwner) { historyList ->
            // Initially filter based on the default selected toggle button
            val filteredList = when (toggleButtonGroup.checkedButtonId) {
                R.id.btn_shortener -> historyList.filter { it.originalUrl == it.expandedUrl }
                R.id.btn_expender -> historyList.filter { it.originalUrl == it.shortenedUrl }
                else -> historyList // R.id.btn_all or any other case
            }
            adapter.submitList(filteredList)
        }

        toggleButtonGroup.check(R.id.btn_all)

        toggleButtonGroup.addOnButtonCheckedListener { group, checkedId, isChecked ->
            if (isChecked) {
                // Get the current list from LiveData
                val currentList = viewModel.historyLiveData.value ?: emptyList()

                // Filter the list based on the selected toggle button
                val filteredList = when (checkedId) {
                    R.id.btn_shortener -> currentList.filter { it.originalUrl == it.expandedUrl }
                    R.id.btn_expender -> currentList.filter { it.originalUrl == it.shortenedUrl }
                    R.id.btn_all -> currentList
                    else -> currentList
                }

                // Submit the filtered list to the adapter
                adapter.submitList(filteredList)
            }
        }


    }
}
