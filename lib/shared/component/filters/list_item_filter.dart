import 'package:flutter/material.dart';

class ListItemFilter<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T item) getItemName;
  final Widget Function(BuildContext context, T item, bool isSelected)? itemBuilder;
  final Function(List<T>? selectedItems)? onSelectionChanged;
  final String searchHint;
  final List<T>? selectedItems;

  const ListItemFilter({
    super.key,
    required this.items,
    required this.getItemName,
    this.itemBuilder,
    this.onSelectionChanged,
    this.searchHint = 'Tìm kiếm',
    this.selectedItems,
  });

  @override
  State<ListItemFilter<T>> createState() => _ListItemFilterState<T>();
}

class _ListItemFilterState<T> extends State<ListItemFilter<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];
  Set<T> _selectedItems = {};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;

    // Initialize selection state based on selectedItems parameter
    if (widget.selectedItems == null) {
      // If selectedItems is null, select all items
      _selectedItems = Set.from(widget.items);
      _selectAll = true;
    } else {
      // Otherwise, use the provided selection
      _selectedItems = Set.from(widget.selectedItems!);
      _updateSelectAllState();
    }
  }

  void _updateFilteredItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems =
            widget.items
                .where(
                  (item) => widget
                  .getItemName(item)
                  .toLowerCase()
                  .contains(query.toLowerCase()),
            )
                .toList();
      }
      _updateSelectAllState();
    });
  }

  void _toggleSelectAll(bool? value) {
    if (value == null) return;

    setState(() {
      _selectAll = value;
      if (_selectAll) {
        _selectedItems = Set.from(_filteredItems);
      } else {
        _selectedItems.clear();
      }

      if (widget.onSelectionChanged != null) {
        if (_selectAll) {
          widget.onSelectionChanged!(null);
        } else {
          widget.onSelectionChanged!(_selectedItems.toList());
        }
      }
    });
  }

  void _toggleItemSelection(T item, bool? isSelected) {
    if (isSelected == null) return;

    setState(() {
      if (isSelected) {
        _selectedItems.add(item);
      } else {
        _selectedItems.remove(item);
      }
      _updateSelectAllState();

      if (widget.onSelectionChanged != null) {
        if (_selectAll) {
          widget.onSelectionChanged!(null);
        }  else {
          widget.onSelectionChanged!(_selectedItems.toList());
        }
      }
    });
  }

  void _updateSelectAllState() {
    if (_filteredItems.isEmpty) {
      _selectAll = false;
    } else {
      _selectAll = _filteredItems.every(
            (item) => _selectedItems.contains(item),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: widget.searchHint,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: _updateFilteredItems,
          ),
        ),
        _filteredItems.length == widget.items.length
            ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(value: _selectAll, onChanged: _toggleSelectAll),
                const Text('Chọn tất cả'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '(${_selectedItems.length}/${_filteredItems.length}) Đã chọn',
              ),
            ),
          ],
        )
            : const SizedBox.shrink(),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              final isSelected = _selectedItems.contains(item);

              if (widget.itemBuilder != null) {
                return Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => _toggleItemSelection(item, value),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _toggleItemSelection(item, !isSelected),
                        child: widget.itemBuilder!(context, item, isSelected),
                      ),
                    ),
                  ],
                );
              } else {
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (value) => _toggleItemSelection(item, value),
                  title: Text(widget.getItemName(item)),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}