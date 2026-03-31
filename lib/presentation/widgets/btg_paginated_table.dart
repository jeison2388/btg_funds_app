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

  /// Franja izquierda en vista móvil (mejor escaneo visual por tipo).
  final Color? Function(T item)? rowAccentColor;

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
    this.rowAccentColor,
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
    final rowsPerPage = widget.availableRowsPerPage.contains(_rowsPerPage)
        ? _rowsPerPage
        : widget.availableRowsPerPage.first;
    final totalPages = (totalItems / rowsPerPage).ceil().clamp(1, 999999);
    final page = _page.clamp(0, totalPages - 1);
    if (page != _page || rowsPerPage != _rowsPerPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _page = page;
          if (rowsPerPage != _rowsPerPage) _rowsPerPage = rowsPerPage;
        });
      });
    }
    final start = page * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, totalItems);
    final pageItems = widget.items.sublist(start, end);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        // Sin ancho finito (p. ej. hijo mal restringido), usar tarjetas móviles y evitar
        // tabla desktop con Expanded → overflow / altura infinita.
        final isMobile =
            !w.isFinite || w < widget.mobileBreakpoint;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isMobile)
              _buildMobileTable(pageItems)
            else
              _buildDesktopTable(pageItems),
            _buildPaginator(totalItems, totalPages, rowsPerPage, page),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: theme.colorScheme.primary,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
            ...pageItems.asMap().entries.map((entry) {
              final item = entry.value;
              final isLastRow = entry.key == pageItems.length - 1;
              final rowBg = widget.rowBackgroundColor?.call(item);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTable(List<T> pageItems) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outlineVariant.withValues(alpha: 0.45);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: pageItems.map((item) {
        if (widget.mobileItemBuilder != null) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: widget.mobileItemBuilder!(item),
          );
        }
        final cardBg = widget.rowBackgroundColor?.call(item);
        final accent = widget.rowAccentColor?.call(item);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: cardBg ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (accent != null)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 5,
                  child: ColoredBox(color: accent),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  accent != null ? 16 : 14,
                  12,
                  14,
                  12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.columns.map((column) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
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
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaginator(
    int totalItems,
    int totalPages,
    int rowsPerPage,
    int page,
  ) {
    final theme = Theme.of(context);
    final start = totalItems == 0 ? 0 : (page * rowsPerPage) + 1;
    final end = ((page + 1) * rowsPerPage).clamp(0, totalItems);
    final paginatorStyle =
        theme.textTheme.bodySmall ?? const TextStyle(fontSize: 12);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mostrando $start-$end de $totalItems',
              style: paginatorStyle,
            ),
            const SizedBox(width: 16),
            Text('Filas:', style: paginatorStyle),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: rowsPerPage,
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
              onPressed: page > 0 ? () => setState(() => _page--) : null,
              icon: const Icon(Icons.chevron_left, size: 20),
            ),
            Text('${page + 1}/$totalPages', style: paginatorStyle),
            IconButton(
              onPressed:
                  page < totalPages - 1 ? () => setState(() => _page++) : null,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.chevron_right, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
