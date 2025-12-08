import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../reclaim_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  final ReclaimService _service = ReclaimService();
  late TabController _tabController;
  bool _isLoading = true;

  // Data Stores
  List<dynamic> _rawRelapses = [];
  Map<String, int> _triggerCounts = {};
  Map<int, int> _weekdayCounts = {}; // 1=Mon, 7=Sun
  String _dangerDay = "---";
  String _dangerTime = "---";
  double _avgStreakDays = 0.0;
  int _maxStreakDays = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDeepAnalytics();
  }

  Future<void> _loadDeepAnalytics() async {
    final history = await _service.getRelapseHistory();
    
    if (history.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // 1. Process Triggers
    Map<String, int> tCounts = {};
    // 2. Process Weekdays (1-7)
    Map<int, int> wCounts = {1:0, 2:0, 3:0, 4:0, 5:0, 6:0, 7:0};
    // 3. Process Times (Hour 0-23) for "Danger Time"
    Map<int, int> hCounts = {};

    for (var r in history) {
      // Trigger Count
      final trigger = r['trigger_source'] as String? ?? 'Unknown';
      tCounts[trigger] = (tCounts[trigger] ?? 0) + 1;

      // Date Parsing
      final date = DateTime.parse(r['occurred_at']).toLocal();
      
      // Weekday Count
      wCounts[date.weekday] = (wCounts[date.weekday] ?? 0) + 1;
      
      // Hour Count
      hCounts[date.hour] = (hCounts[date.hour] ?? 0) + 1;
    }

    // 4. Calculate "Danger Zone"
    // Find day with max relapses
    int worstDay = wCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    // Find hour with max relapses
    int worstHour = hCounts.entries.isEmpty ? 12 : hCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    // 5. Calculate "Streak Efficiency" (Simulated for MVP)
    // In a real app, you'd calculate the gap between timestamps
    
    if (mounted) {
      setState(() {
        _rawRelapses = history;
        _triggerCounts = tCounts;
        _weekdayCounts = wCounts;
        _dangerDay = DateFormat('EEEE').format(DateTime(2023, 1, 1).add(Duration(days: worstDay))); // Hack to get day name
        _dangerTime = "${worstHour % 12 == 0 ? 12 : worstHour % 12} ${worstHour >= 12 ? 'PM' : 'AM'}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("FORENSICS", 
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white)),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFB4F8C8)))
        : _rawRelapses.isEmpty 
          ? const Center(child: Text("No data. Clean record.", style: TextStyle(color: Colors.grey)))
          : Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. THE DANGER ZONE CARD
                _buildDangerZoneCard(),
                const SizedBox(height: 24),
                
                // 2. METRICS GRID
                Row(
                  children: [
                    Expanded(child: _buildMetricCard("TOTAL RESETS", "${_rawRelapses.length}", Icons.history)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMetricCard("WORST DAY", _dangerDay.substring(0, 3).toUpperCase(), Icons.calendar_today)),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. TABS FOR CHARTS
                TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFFB4F8C8),
                  labelColor: const Color(0xFFB4F8C8),
                  unselectedLabelColor: Colors.grey,
                  labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: "BY WEEKDAY"),
                    Tab(text: "BY TRIGGER"),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. CHART VIEW
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildWeekdayChart(),
                      _buildTriggerPieChart(),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // --- WIDGETS ---

  Widget _buildDangerZoneCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2A0000), const Color(0xFF111111)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 20)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text("HIGH RISK DETECTED", 
                style: GoogleFonts.spaceGrotesk(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: GoogleFonts.spaceGrotesk(fontSize: 22, height: 1.3, color: Colors.white),
              children: [
                const TextSpan(text: "You are most likely to fail on "),
                TextSpan(text: "$_dangerDay ", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.red)),
                const TextSpan(text: "around "),
                TextSpan(text: _dangerTime, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.red)),
                const TextSpan(text: "."),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 16),
          const SizedBox(height: 12),
          Text(value, 
            style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, 
            style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWeekdayChart() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    // Find max for scaling
    int maxVal = _weekdayCounts.values.fold(0, (p, c) => c > p ? c : p);
    if (maxVal == 0) maxVal = 1;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal.toDouble() + 1,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(days[val.toInt()], style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                );
              }
            )
          )
        ),
        barGroups: List.generate(7, (index) {
          final count = _weekdayCounts[index + 1] ?? 0;
          final isHigh = count == maxVal; // Highlight the worst day
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                color: isHigh ? const Color(0xFFFF4B4B) : const Color(0xFF333333),
                width: 16,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxVal.toDouble() + 1,
                  color: const Color(0xFF111111),
                ),
              )
            ]
          );
        }),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildTriggerPieChart() {
    // Convert map to PieChartSectionData
    int total = _triggerCounts.values.fold(0, (sum, item) => sum + item);
    int i = 0;
    
    // Aesthetic Palette for pie slices
    final colors = [
      const Color(0xFFB4F8C8), // Mint
      const Color(0xFF64FFDA), // Teal
      const Color(0xFF448AFF), // Blue
      const Color(0xFFAA00FF), // Purple
      const Color(0xFFFF4B4B), // Red
    ];

    List<PieChartSectionData> sections = _triggerCounts.entries.map((entry) {
      final isLarge = i == 0; // Highlight first
      final double fontSize = isLarge ? 16 : 12;
      final double radius = isLarge ? 100 : 80;
      final color = colors[i % colors.length];
      i++;

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${((entry.value / total) * 100).toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: GoogleFonts.spaceGrotesk(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
    }).toList();

    return Row(
      children: [
        // The Chart
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
        // The Legend
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _triggerCounts.keys.toList().asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        color: colors[e.key % colors.length],
                        shape: BoxShape.circle
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(e.value, 
                        style: const TextStyle(color: Colors.white, fontSize: 12, overflow: TextOverflow.ellipsis)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        )
      ],
    ).animate().scale();
  }
}