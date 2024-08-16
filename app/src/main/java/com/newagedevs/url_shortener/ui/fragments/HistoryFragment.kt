package com.newagedevs.url_shortener.ui.fragments

import android.os.Bundle
import android.view.View
import android.widget.Button
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.textfield.TextInputEditText
import com.newagedevs.url_shortener.R
import com.newagedevs.url_shortener.ui.adapters.HistoryAdapter
import com.newagedevs.url_shortener.ui.viewmodel.MainViewModel
import dagger.hilt.android.AndroidEntryPoint


@AndroidEntryPoint
class HistoryFragment : Fragment(R.layout.fragment_history) {

    private val viewModel: MainViewModel by viewModels()
    private lateinit var adapter: HistoryAdapter

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        adapter = HistoryAdapter()
        val recyclerView = view.findViewById<RecyclerView>(R.id.recycler_view_history)
        recyclerView.layoutManager = LinearLayoutManager(requireContext())
        recyclerView.adapter = adapter

        // Observe the history live data from the database
        viewModel.historyLiveData.observe(viewLifecycleOwner) { historyList ->
            adapter.submitList(historyList)
        }
    }
}
