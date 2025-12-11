import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/providers.dart';
import '../../../core/constants/constants.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  List<dynamic> _rawRelapses = [];
  Map<String, int> _triggerCounts = {};
  Map<int, int> _weekdayCounts = {};
  Map<int, int> _hourCounts = {};

  String _dangerDay = "---";
  String _dangerTime = "---";
  String _safeDay = "---";
  int _longestStreakDays = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDeepAnalytics();
  }

  Future<void> _loadDeepAnalytics() async {
    final relapseRepo = ref.read(relapseRepositoryProvider);
    final history = await relapseRepo.getRelapseHistory();

    if (history.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    history.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));

    Map<String, int> tCounts = {};
    Map<int, int> wCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    Map<int, int> hCounts = {};
    for (int i = 0; i < 24; i++) hCounts[i] = 0;

    DateTime? previousDate;
    List<int> intervals = [];

    for (var r in history) {
      tCounts[r.triggerSource] = (tCounts[r.triggerSource] ?? 0) + 1;
      final date = r.occurredAt.toLocal();
      wCounts[date.weekday] = (wCounts[date.weekday] ?? 0) + 1;
      hCounts[date.hour] = (hCounts[date.hour] ?? 0) + 1;

      if (previousDate != null) {
        intervals.add(date.difference(previousDate).inDays);
      }
      previousDate = date;
    }

    int worstDay = wCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    int worstHour = hCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    int bestDay = wCounts.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
    int maxStreak = intervals.isEmpty
        ? 0
        : intervals.reduce((curr, next) => curr > next ? curr : next);

    if (mounted) {
      setState(() {
        _rawRelapses = history;
        _triggerCounts = tCounts;
        _weekdayCounts = wCounts;
        _hourCounts = hCounts;
        _dangerDay = DateFormat(
          'EEEE',
        ).format(DateTime(2023, 1, 1).add(Duration(days: worstDay)));
        _dangerTime =
            "${worstHour % 12 == 0 ? 12 : worstHour % 12} ${worstHour >= 12 ? 'PM' : 'AM'}";
        _safeDay = DateFormat(
          'EEEE',
        ).format(DateTime(2023, 1, 1).add(Duration(days: bestDay)));
        _longestStreakDays = maxStreak;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          AppStrings.forensics,
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentGreen),
            )
          : _rawRelapses.isEmpty
          ? Center(
              child: Text(
                AppStrings.noDataCleanRecord,
                style: const TextStyle(color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 160,
                    child: PageView(
                      children: [_buildDangerZoneCard(), _buildPowerZoneCard()],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.accentGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          "TOTAL RESETS",
                          "${_rawRelapses.length}",
                          Icons.history,
                          Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricCard(
                          "WORST DAY",
                          _dangerDay.length >= 3
                              ? _dangerDay.substring(0, 3).toUpperCase()
                              : _dangerDay,
                          Icons.warning_amber_rounded,
                          AppColors.dangerRed,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricCard(
                          "BEST STREAK",
                          "$_longestStreakDays DAYS",
                          Icons.emoji_events,
                          AppColors.accentGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.accentGreen,
                    labelColor: AppColors.accentGreen,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    tabs: const [
                      Tab(text: "WEEKDAY"),
                      Tab(text: "HOURLY"),
                      Tab(text: "TRIGGERS"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildWeekdayChart(),
                        _buildHourlyChart(),
                        _buildTriggerPieChart(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDangerZoneCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A0000), Color(0xFF111111)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "HIGH RISK DETECTED",
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                height: 1.3,
                color: Colors.white,
              ),
              children: [
                const TextSpan(text: "Most failures occur on "),
                TextSpan(
                  text: "$_dangerDay ",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.red,
                  ),
                ),
                const TextSpan(text: "around "),
                TextSpan(
                  text: _dangerTime,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.red,
                  ),
                ),
                const TextSpan(text: "."),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerZoneCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF002A10), Color(0xFF111111)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.accentGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "SAFE ZONE DETECTED",
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                height: 1.3,
                color: Colors.white,
              ),
              children: [
                const TextSpan(text: "You are strongest on "),
                TextSpan(
                  text: _safeDay,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.accentGreen,
                  ),
                ),
                const TextSpan(text: ". Keep this momentum going."),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color valueColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 16),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyChart() {
    int maxVal = _hourCounts.values.fold(0, (p, c) => c > p ? c : p);
    if (maxVal == 0) maxVal = 1;
    List<FlSpot> spots = [];
    for (int i = 0; i < 24; i++)
      spots.add(FlSpot(i.toDouble(), (_hourCounts[i] ?? 0).toDouble()));

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              const FlLine(color: Colors.white10, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 6,
              getTitlesWidget: (val, meta) {
                int hour = val.toInt();
                String text =
                    "${hour % 12 == 0 ? 12 : hour % 12}${hour >= 12 ? 'p' : 'a'}";
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 23,
        minY: 0,
        maxY: maxVal.toDouble() + 0.5,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.dangerRed,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.dangerRed.withOpacity(0.1),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildWeekdayChart() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    int maxVal = _weekdayCounts.values.fold(0, (p, c) => c > p ? c : p);
    if (maxVal == 0) maxVal = 1;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal.toDouble() + 1,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  days[val.toInt()],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        barGroups: List.generate(7, (index) {
          final count = _weekdayCounts[index + 1] ?? 0;
          final isHigh = count == maxVal;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                color: isHigh ? AppColors.dangerRed : const Color(0xFF333333),
                width: 16,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxVal.toDouble() + 1,
                  color: const Color(0xFF111111),
                ),
              ),
            ],
          );
        }),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildTriggerPieChart() {
    int total = _triggerCounts.values.fold(0, (sum, item) => sum + item);
    int i = 0;
    final colors = [
      AppColors.accentGreen,
      AppColors.accentTeal,
      AppColors.accentBlue,
      AppColors.accentPurple,
      AppColors.dangerRed,
    ];

    List<PieChartSectionData> sections = _triggerCounts.entries.map((entry) {
      final isLarge = i == 0;
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${((entry.value / total) * 100).toStringAsFixed(0)}%',
        radius: isLarge ? 100 : 80,
        titleStyle: GoogleFonts.spaceGrotesk(
          fontSize: isLarge ? 16 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 0,
              sectionsSpace: 2,
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _triggerCounts.keys
                .toList()
                .asMap()
                .entries
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors[e.key % colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ).animate().scale();
  }
}
