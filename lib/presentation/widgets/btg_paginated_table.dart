import 'package:flutter/material.dart';

class BtgTableColumn<T> {
  final String label;
  final double flex;
  final Widget Function(T item) cellBuilder;

  const BtgTableColumn({
    required this.label,
    required this.cellBuilder,
    this.flex = 1,
  });
}

class BtgPaginatedTable<T> extends StatefulWidget {
  final List<T> items;
  final List<BtgTableColumn<T>> columns;
  final int initialRowsPerPage;
  final List<int> availableRowsPerPage;
  final String? emptyMessage;
  final double mobileBreakpoint;
  final Widget Function(T item)? mobileItemBuilder;

  /// Color de fondo opcional por fila (p. ej. según tipo de dato).
  final Color? Function(T item)? rowBackgroundColor;

  const BtgPaginatedTable({
    super.key,
    required this.items,
    required this.columns,
    this.initialRowsPerPage = 5,
    this.availableRowsPerPage = const [3, 5, 10],
    this.emptyMessage,
    this.mobileBreakpoint = 760,
    this.mobileItemBuilder,
    this.rowBackgroundColor,
  });

  @override
  State<BtgPaginatedTable<T>> createState() => _BtgPaginatedTableState<T>();
}

class _BtgPaginatedTableState<T> extends State<BtgPaginatedTable<T>> {
  late int _rowsPerPage;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _rowsPerPage = widget.availableRowsPerPage.contains(widget.initialRowsPerPage)
        ? widget.initialRowsPerPage
        : widget.availableRowsPerPage.first;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Center(
        child: Text(widget.emptyMessage ?? 'Sin datos para mostrar'),
      );
    }

    final totalItems = widget.items.length;
    final totalPages = (totalItems / _rowsPerPage).ceil().clamp(1, 999999);
    if (_page >= totalPages) _page = totalPages - 1;
    final start = _page * _rowsPerPage;
    final end = (start + _rowsPerPage).clamp(0, totalItems);
    final pageItems = widget.items.sublist(start, end);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < widget.mobileBreakpoint;
        return Column(
          children: [
            if (isMobile)
              _buildMobileTable(pageItems)
            else
              _buildDesktopTable(pageItems),
            _buildPaginator(totalItems, totalPages),
          ],
        );
      },
    );
  }

  Widget _buildDesktopTable(List<T> pageItems) {
    final theme = Theme.of(context);
    final borderColor = Colors.grey.shade300;
    const cellMinHeight = 56.0;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            Container(
              color: theme.colorScheme.primary,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widget.columns.map((column) {
                    return Expanded(
                      flex: (column.flex * 100).toInt(),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: cellMinHeight),
                        padding: const EdgeInsets.all(12),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: borderColor),
                          ),
                        ),
                        child: Text(
                          column.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            ...pageItems.asMap().entries.map((entry) {
              final item = entry.value;
              final isLastRow = entry.key == pageItems.length - 1;
              final rowBg = widget.rowBackgroundColor?.call(item);
              Widget row = IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widget.columns.map((column) {
                    return Expanded(
                      flex: (column.flex * 100).toInt(),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: cellMinHeight),
                        padding: const EdgeInsets.all(12),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: rowBg,
                          border: Border(
                            right: BorderSide(color: borderColor),
                            bottom: isLastRow
                                ? BorderSide.none
                                : BorderSide(color: borderColor),
                          ),
                        ),
                        child: column.cellBuilder(item),
                      ),
                    );
                  }).toList(),
                ),
              );
              return row;
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTable(List<T> pageItems) {
    final theme = Theme.of(context);
    return Column(
      children: pageItems.map((item) {
        if (widget.mobileItemBuilder != null) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: widget.mobileItemBuilder!(item),
          );
        }
        final cardBg = widget.rowBackgroundColor?.call(item);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: cardBg,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.columns.map((column) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(
                          '${column.label}:',
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      Expanded(child: column.cellBuilder(item)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaginator(int totalItems, int totalPages) {
    final theme = Theme.of(context);
    final start = totalItems == 0 ? 0 : (_page * _rowsPerPage) + 1;
    final end = ((_page + 1) * _rowsPerPage).clamp(0, totalItems);
    final paginatorStyle = theme.textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
      child: Row(
        children: [
          Text(
            'Mostrando $start-$end de $totalItems',
            style: paginatorStyle,
          ),
          const Spacer(),
          Text('Filas:', style: paginatorStyle),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: _rowsPerPage,
            style: paginatorStyle,
            isDense: true,
            items: widget.availableRowsPerPage
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text('$value', style: paginatorStyle),
                    ))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _rowsPerPage = value;
                _page = 0;
              });
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: _page > 0 ? () => setState(() => _page--) : null,
            icon: const Icon(Icons.chevron_left, size: 20),
          ),
          Text('${_page + 1}/$totalPages', style: paginatorStyle),
          IconButton(
            onPressed: _page < totalPages - 1
                ? () => setState(() => _page++)
                : null,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_right, size: 20),
          ),
        ],
      ),
    );
  }
}
