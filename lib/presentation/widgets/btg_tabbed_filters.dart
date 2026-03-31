import 'package:flutter/material.dart';

class BtgTabbedFilters extends StatefulWidget {
  final List<String> tabs;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final String searchHintText;
  final bool showSearch;
  final bool showFilters;
  final bool searchEnabled;
  final double searchFieldWidth;
  final double filterSpacing;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double borderRadius;
  final bool showShadow;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearch;
  final List<BtgFilterDropdownConfig<dynamic>> filters;

  const BtgTabbedFilters({
    super.key,
    required this.tabs,
    required this.selectedTab,
    required this.onTabChanged,
    this.searchHintText = 'Buscar',
    this.showSearch = true,
    this.showFilters = true,
    this.searchEnabled = true,
    this.searchFieldWidth = 300,
    this.filterSpacing = 12,
    this.padding,
    this.backgroundColor,
    this.borderRadius = 8,
    this.showShadow = true,
    this.searchController,
    this.onSearch,
    this.filters = const [],
  });

  @override
  State<BtgTabbedFilters> createState() => _BtgTabbedFiltersState();
}

class _BtgTabbedFiltersState extends State<BtgTabbedFilters> {
  late final TextEditingController _internalSearchController;
  final ScrollController _tabScrollController = ScrollController();
  int? _hoveredTabIndex;
  bool _tabsCanScrollLeft = false;
  bool _tabsCanScrollRight = false;

  @override
  void initState() {
    super.initState();
    _internalSearchController =
        widget.searchController ?? TextEditingController();
    _tabScrollController.addListener(_onTabScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onTabScroll());
  }

  @override
  void dispose() {
    _tabScrollController.removeListener(_onTabScroll);
    _tabScrollController.dispose();
    if (widget.searchController == null) {
      _internalSearchController.dispose();
    }
    super.dispose();
  }

  void _onTabScroll() {
    if (!mounted || !_tabScrollController.hasClients) return;
    final pos = _tabScrollController.position;
    final canScrollRight =
        pos.maxScrollExtent > 1 && pos.pixels < pos.maxScrollExtent - 1;
    final canScrollLeft = pos.pixels > 1;
    if (_tabsCanScrollLeft != canScrollLeft ||
        _tabsCanScrollRight != canScrollRight) {
      setState(() {
        _tabsCanScrollLeft = canScrollLeft;
        _tabsCanScrollRight = canScrollRight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSearchOrFilters = widget.showSearch ||
        (widget.showFilters && widget.filters.isNotEmpty);

    return Container(
      padding: widget.padding ?? const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.08),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildTabs(context)),
                if (hasSearchOrFilters) ...[
                  SizedBox(width: widget.filterSpacing),
                  _buildSearchAndFilters(context),
                ],
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTabs(context),
              if (hasSearchOrFilters) ...[
                SizedBox(height: widget.filterSpacing),
                _buildSearchAndFilters(context),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    const arrowWidth = 28.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_tabsCanScrollLeft)
          _buildScrollArrow(context, isLeft: true, arrowWidth: arrowWidth),
        Expanded(
          child: SingleChildScrollView(
            controller: _tabScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.tabs.length, (index) {
                final isSelected = widget.selectedTab == index;
                final isHovered = _hoveredTabIndex == index;
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == widget.tabs.length - 1 ? 0 : 8,
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _hoveredTabIndex = index),
                    onExit: (_) => setState(() => _hoveredTabIndex = null),
                    child: GestureDetector(
                      onTap: () => widget.onTabChanged(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : isHovered
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.08)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : isHovered
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.35)
                                    : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          widget.tabs[index],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color:
                                    isSelected ? Colors.white : Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        if (_tabsCanScrollRight)
          _buildScrollArrow(context, isLeft: false, arrowWidth: arrowWidth),
      ],
    );
  }

  Widget _buildScrollArrow(
    BuildContext context, {
    required bool isLeft,
    required double arrowWidth,
  }) {
    return GestureDetector(
      onTap: () {
        if (!_tabScrollController.hasClients) return;
        final pos = _tabScrollController.position;
        final delta = isLeft ? -pos.viewportDimension * 0.6 : pos.viewportDimension * 0.6;
        _tabScrollController.animateTo(
          (pos.pixels + delta).clamp(0.0, pos.maxScrollExtent),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: arrowWidth,
          alignment: Alignment.center,
          color: Colors.white,
          child: Icon(
            isLeft ? Icons.chevron_left : Icons.chevron_right,
            size: 20,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Row(
      children: [
        if (widget.showSearch)
          SizedBox(
            width: widget.searchFieldWidth,
            height: 40,
            child: TextField(
              controller: _internalSearchController,
              enabled: widget.searchEnabled,
              onChanged: widget.onSearch,
              decoration: InputDecoration(
                hintText: widget.searchHintText,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        if (widget.showFilters)
          ...widget.filters.asMap().entries.map((entry) {
            final index = entry.key;
            final filterConfig = entry.value;
            final isFirst = index == 0;
            final needsLeftPadding = widget.showSearch || !isFirst;
            return Padding(
              padding: EdgeInsets.only(
                left: needsLeftPadding ? widget.filterSpacing : 0,
              ),
              child: filterConfig.build(context),
            );
          }),
      ],
    );
  }
}

class BtgFilterDropdownConfig<T> {
  final String label;
  final String? defaultOptionLabel;
  final T? selectedValue;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;
  final double minWidth;
  final double maxWidth;
  final bool requiredDefaultOption;

  const BtgFilterDropdownConfig({
    required this.label,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    this.defaultOptionLabel,
    this.minWidth = 150,
    this.maxWidth = 210,
    this.requiredDefaultOption = true,
  });

  Widget build(BuildContext context) {
    return Container(
      height: 40,
      constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<T>(
        value: selectedValue,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
        hint: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
        ),
        items: [
          if (requiredDefaultOption)
            DropdownMenuItem<T>(
              value: null,
              child: Text(
                defaultOptionLabel ?? label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ...items.entries.map(
            (entry) => DropdownMenuItem<T>(
              value: entry.key,
              child: Text(
                entry.value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
