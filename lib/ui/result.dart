import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pcte_event_management/widgets/drawer_builder.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Api_Calls/result_api_calls.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<Map<String, dynamic>> tableData = [];
  bool isLoading = true;
  final ResultApiCalls apiCalls = ResultApiCalls();
  String selectedCategory = "Junior";
  int selectedYear = DateTime.now().year;
  final ScrollController _chartScrollController = ScrollController();

  // Color scheme for the app
  final Color primaryColor = const Color(0xFF9E2A2F);
  final Color accentColor = const Color(0xFF1D5B79);
  final List<Color> barGradientColors = const [
    Color(0xFF6FB1FC),
    Color(0xFF2D5FBE),
  ];

  // Top 3 winners special colors
  final List<List<Color>> topWinnerColors = [
    [Color(0xFFFFD700), Color(0xFFDAA520)], // Gold (1st)
    [Color(0xFFC0C0C0), Color(0xFF808080)], // Silver (2nd)
    [Color(0xFFCD7F32), Color(0xFF8B4513)], // Bronze (3rd)
  ];

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  @override
  void dispose() {
    _chartScrollController.dispose();
    super.dispose();
  }

  Future<void> fetchLeaderboard() async {
    setState(() => isLoading = true);
    try {
      tableData = await apiCalls.getFinalResults(
          year: selectedYear, type: selectedCategory);

      // Sort data by total points in descending order (if not already sorted)
      tableData.sort((a, b) =>
          (b['totalPoints'] as num).compareTo(a['totalPoints'] as num));
    } catch (e) {
      log('Error fetching leaderboard: $e');
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Leaderboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            color: Colors.white,
          ),
        ),
      ),
      drawer: CustomDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterHeader(),
              const SizedBox(height: 20),
              _buildChartSection(),
              const SizedBox(height: 5),
              _buildListSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$selectedCategory $selectedYear",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          Row(
            children: [
              _buildDropdown(
                value: selectedYear,
                items: List.generate(5, (index) => DateTime.now().year - index),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedYear = newValue;
                      fetchLeaderboard();
                    });
                  }
                },
                icon: Icons.calendar_today_rounded,
              ),
              const SizedBox(width: 12),
              _buildDropdown(
                value: selectedCategory,
                items: const ["Junior", "Senior"],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedCategory = newValue;
                      fetchLeaderboard();
                    });
                  }
                },
                icon: Icons.category_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required Function(T?) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accentColor),
          const SizedBox(width: 5),
          DropdownButton<T>(
            value: value,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
            isDense: true,
            items: items.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(item.toString()),
              );
            }).toList(),
            onChanged: onChanged,
            style: TextStyle(
              color: accentColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Expanded(
      flex: 3,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Points Visualization",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : tableData.isEmpty
                      ? const Center(
                          child: Text(
                            "No data available",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : _buildResponsiveChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveChart() {
    // Calculate width based on available data
    // Show up to 4 bars initially and allow scrolling for more
    final int initialVisibleBars = tableData.length > 4 ? 4 : tableData.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth =
            constraints.maxWidth - 20; // Accounting for padding

        // Calculate if scrolling is needed
        bool needsScrolling = tableData.length > initialVisibleBars;
        double minBarWidth =
            85; // Increased width per bar to accommodate labels
        double chartWidth =
            needsScrolling ? tableData.length * minBarWidth : availableWidth;

        return Stack(
          children: [
            Scrollbar(
              controller: _chartScrollController,
              thumbVisibility: true,
              thickness: 6,
              radius: const Radius.circular(10),
              child: SingleChildScrollView(
                controller: _chartScrollController,
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  width: chartWidth,
                  height: constraints.maxHeight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10, right: 10),
                    child: _buildBarChart(constraints),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBarChart(BoxConstraints constraints) {
    double barWidth = 30;
    double groupSpace = 55;

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            direction: TooltipDirection.top,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipPadding: const EdgeInsets.all(10),
            tooltipRoundedRadius: 8,
            tooltipMargin: 12,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String name = tableData[groupIndex]['name'].toString();
              String points = rod.toY.round().toString() + " pts";
              String category = tableData[groupIndex]['type'].toString();

              return BarTooltipItem(
                "$name\n$category",
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: [
                  const TextSpan(text: "\n"),
                  TextSpan(
                    text: points,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
                textAlign: TextAlign.center,
              );
            },
            // tooltipBgColor: accentColor.withOpacity(0.9),
          ),
        ),
        alignment: BarChartAlignment.center,
        groupsSpace: groupSpace,
        barGroups: tableData.asMap().entries.map((entry) {
          int index = entry.key;
          var value = entry.value;
          double points = value['totalPoints'] is num
              ? (value['totalPoints'] as num).toDouble()
              : 0.0;

          List<Color> colors =
              index < 3 ? topWinnerColors[index] : barGradientColors;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: points <= 0 ? 0.1 : points,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(5),
                ),
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                width: barWidth,
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: _calculateMaxY(),
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < tableData.length) {
                  bool isTopThree = value.toInt() < 3;

                  String shortName =
                      tableData[value.toInt()]['name'].toString();
                  // If name is too long, truncate it and add ellipsis
                  if (shortName.length > 15) {
                    shortName = shortName.substring(0, 15) + "...";
                  }

                  return SizedBox(
                    height:
                        42, // Explicitly set a sufficient height to avoid overflow
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // This isn't enough alone
                      mainAxisAlignment: MainAxisAlignment
                          .start, // Align to top to avoid overflow
                      children: [
                        // Rank indicator with badge
                        Container(
                          width: 20, // Reduced from 24
                          height: 20, // Reduced from 24
                          decoration: BoxDecoration(
                            color: isTopThree
                                ? topWinnerColors[value.toInt()][0]
                                : Colors.grey[300],
                            shape: BoxShape.circle,
                            boxShadow: isTopThree
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${value.toInt() + 1}',
                              style: TextStyle(
                                fontSize: 10, // Reduced from 11
                                fontWeight: FontWeight.bold,
                                color: isTopThree ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2), // Reduced spacing from 4
                        // Very short name indicator
                        Text(
                          shortName,
                          style: TextStyle(
                            fontSize: 9, // Reduced from 10
                            fontWeight: isTopThree
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isTopThree ? primaryColor : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _calculateInterval(),
              reservedSize: 35, // Increased space for y-axis labels
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value % _calculateInterval() == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            left: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: _calculateInterval(),
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
          drawVerticalLine: false,
        ),
        maxY: _calculateMaxY(),
      ),
    );
  }

  Widget _buildListSection() {
    return Expanded(
      flex: 4,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 12, bottom: 8),
              child: Text(
                "Ranking Details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : tableData.isEmpty
                      ? const Center(
                          child: Text(
                            "No data available",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          itemCount: tableData.length,
                          itemBuilder: (context, index) {
                            return _buildRankCard(index);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankCard(int index) {
    bool isTopThree = index < 3;
    Color cardColor = isTopThree
        ? topWinnerColors[index][0].withOpacity(0.15)
        : Colors.grey.shade50;
    Color borderColor =
        isTopThree ? topWinnerColors[index][0] : Colors.grey.shade200;

    String trophyEmoji = '';
    if (index == 0) {
      trophyEmoji = '🥇';
    } else if (index == 1) {
      trophyEmoji = '🥈';
    } else if (index == 2) {
      trophyEmoji = '🥉';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: isTopThree ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: isTopThree ? 1 : 0.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isTopThree
              ? LinearGradient(
                  colors: [
                    cardColor,
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isTopThree ? topWinnerColors[index][0] : Colors.grey.shade300,
              boxShadow: isTopThree
                  ? [
                      BoxShadow(
                        color: topWinnerColors[index][0].withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                isTopThree ? trophyEmoji : '${index + 1}',
                style: TextStyle(
                  fontSize: isTopThree ? 20 : 16,
                  fontWeight: FontWeight.bold,
                  color: isTopThree ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          title: Text(
            tableData[index]['name'],
            style: TextStyle(
              fontWeight: isTopThree ? FontWeight.bold : FontWeight.w500,
              fontSize: isTopThree ? 16 : 15,
              color: isTopThree ? primaryColor : Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              tableData[index]['type'].toString(),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isTopThree
                  ? topWinnerColors[index][0].withOpacity(0.8)
                  : accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${tableData[index]['totalPoints']} pts',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isTopThree ? Colors.white : accentColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _calculateMaxY() {
    if (tableData.isEmpty) return 10.0;

    double maxPoints = 0;
    for (var item in tableData) {
      double points = (item['totalPoints'] as num).toDouble();
      if (points > maxPoints) maxPoints = points;
    }

    // Round up to next appropriate value
    if (maxPoints <= 5) return 5;
    if (maxPoints <= 10) return 10;
    if (maxPoints <= 20) return 20;
    if (maxPoints <= 50) return 50;
    if (maxPoints <= 100) return 100;

    // For larger values, round up to nearest 50
    return ((maxPoints / 50).ceil() * 50).toDouble();
  }

  double _calculateInterval() {
    double maxY = _calculateMaxY();

    if (maxY <= 5) return 1;
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 4;
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;

    return (maxY / 5).ceilToDouble();
  }
}
