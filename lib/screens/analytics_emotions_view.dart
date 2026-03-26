import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../data/emotion_checkin_storage.dart';
import '../features/emotion_quiz/mood_logic.dart';
import '../providers/study_session_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/soft_background.dart';
import '../widgets/common_widgets.dart';
import 'mood_start_screen.dart';
import 'mood_log_screen.dart';

class AnalyticsEmotionsView extends StatefulWidget {
	const AnalyticsEmotionsView({super.key});

	@override
	State<AnalyticsEmotionsView> createState() => _AnalyticsEmotionsViewState();
}

class _AnalyticsEmotionsViewState extends State<AnalyticsEmotionsView> {
	int _moodCheckins7d = 0;
	EmotionCheckin? _latestMood;

	@override
	void initState() {
		super.initState();
		_loadMoodCheckins();
	}

	Future<void> _loadMoodCheckins() async {
		final checkins = await EmotionCheckinStorage.loadCheckins();
		final start = DateTime.now().subtract(const Duration(days: 6));
		final startDay = DateTime(start.year, start.month, start.day);

		final count = checkins.where((entry) {
			final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
			return !day.isBefore(startDay);
		}).length;

		if (!mounted) {
			return;
		}

		setState(() {
			_moodCheckins7d = count;
			_latestMood = checkins.isNotEmpty ? checkins.last : null;
		});
	}

	@override
	Widget build(BuildContext context) {
		final isDark = Theme.of(context).brightness == Brightness.dark;
		final isThai = Localizations.localeOf(context)
				.languageCode
				.toLowerCase()
				.startsWith('th');
		final sessionProvider = context.watch<StudySessionProvider>();
		final sessions7d = sessionProvider.sessions.where((s) {
			final start = DateTime.now().subtract(const Duration(days: 6));
			final day = DateTime(s.date.year, s.date.month, s.date.day);
			final startDay = DateTime(start.year, start.month, start.day);
			return !day.isBefore(startDay);
		}).toList();

		return Scaffold(
			backgroundColor: isDark ? null : const Color(0xFFF6F4FA),
			body: Container(
				decoration: isDark ? AppTheme.darkGradient : null,
				child: SoftBackground(
					child: SafeArea(
						child: ListView(
							padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
							children: [
								Row(
									children: [
										IconButton(
											onPressed: () => Navigator.pop(context),
											icon: const Icon(Icons.arrow_back_rounded),
										),
										const SizedBox(width: 6),
										Text(
											isThai ? 'Analytics Emotion' : 'Emotion Analytics',
											style: AppTheme.h2.copyWith(
												color: isDark ? Colors.white : AppTheme.textDark,
											),
										),
									],
								),
								const SizedBox(height: 14),
								GlassCard(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												isThai
														? 'หน้าวิเคราะห์อารมณ์ (แยกจาก Insights เดิม)'
														: 'Emotion analytics page (separate from Insights)',
												style: TextStyle(
													color: isDark ? Colors.white : AppTheme.textDark,
													fontWeight: FontWeight.w700,
												),
											),
											const SizedBox(height: 8),
											Text(
												isThai
														? 'หน้านี้จะแสดงข้อมูลอารมณ์ที่ผูกกับการโฟกัส โดยไม่รวมกับหน้า Analytics เดิม'
														: 'This page is dedicated to mood-based focus insights and is kept separate from the existing analytics page.',
												style: TextStyle(
													color: isDark ? Colors.white70 : AppTheme.textMuted,
													fontWeight: FontWeight.w600,
												),
											),
											const SizedBox(height: 12),
											ElevatedButton.icon(
												onPressed: () async {
													await Navigator.push(
														context,
														MaterialPageRoute(
																builder: (_) => const MoodStartScreen(),
														),
													);
													await _loadMoodCheckins();
												},
												icon: const Icon(Icons.quiz_outlined),
												label: Text(isThai ? 'เริ่ม Emotion Quiz' : 'Start Emotion Quiz'),
												style: ElevatedButton.styleFrom(
													backgroundColor: AppTheme.primary,
													foregroundColor: Colors.white,
												),
											),
											const SizedBox(height: 10),
											OutlinedButton.icon(
												onPressed: () async {
													await Navigator.push(
														context,
														MaterialPageRoute(builder: (_) => const MoodLogScreen()),
													);
													await _loadMoodCheckins();
												},
												icon: const Icon(Icons.history_rounded),
												label: Text(isThai ? 'ดูประวัติอารมณ์' : 'Open Mood Log'),
											),
											const SizedBox(height: 16),
											Container(
												height: 1,
												color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
											),
											const SizedBox(height: 14),
											Builder(
												builder: (context) {
													if (_latestMood == null) {
														return Text(
															isThai
																? 'ยังไม่มีอารมณ์ล่าสุด ลองทำ Emotion Quiz ครั้งแรกของคุณ'
																: 'No current mood yet. Try your first Emotion Quiz.',
															style: TextStyle(
																color: isDark ? Colors.white70 : AppTheme.textMuted,
																fontWeight: FontWeight.w600,
															),
														);
													}

													final details = getMoodDetailsByMood(_latestMood!.mood);
													final name = getMoodNameForLocale(_latestMood!.mood, isThai: isThai);
													final message = getMoodMessageForLocale(_latestMood!.mood, isThai: isThai);
													final moodAsset = getMoodSvgAsset(_latestMood!.mood);

													return Column(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															Text(
																isThai ? 'อารมณ์ล่าสุด' : 'Current Mood',
																style: TextStyle(
																	color: isDark ? Colors.white : AppTheme.textDark,
																	fontWeight: FontWeight.w800,
																),
															),
															const SizedBox(height: 8),
															Row(
																children: [
																	Container(
																		width: 42,
																		height: 42,
																		decoration: BoxDecoration(
																			color: details.color.withValues(alpha: 0.16),
																			borderRadius: BorderRadius.circular(12),
																		),
																		alignment: Alignment.center,
																		child: moodAsset != null
																			? SvgPicture.asset(
																				moodAsset,
																				width: 28,
																				height: 28,
																				fit: BoxFit.contain,
																			)
																			: Text(
																				details.emoji,
																				style: const TextStyle(fontSize: 22),
																			),
																	),
																	const SizedBox(width: 10),
																	Expanded(
																		child: Text(
																			name,
																			style: TextStyle(
																				color: details.color,
																				fontSize: 34,
																				fontWeight: FontWeight.w900,
																			),
																		),
																	),
																],
															),
															const SizedBox(height: 6),
															Text(
																message,
																style: TextStyle(
																	color: isDark ? Colors.white70 : AppTheme.textMuted,
																	fontWeight: FontWeight.w600,
																),
															),
														],
													);
												},
											),
										],
									),
								),
								const SizedBox(height: 16),
								Row(
									children: [
										Expanded(
											child: GlassCard(
												child: _metricBlock(
													context: context,
													icon: Icons.psychology_alt_rounded,
													color: const Color(0xFF8B5CF6),
													label: isThai ? 'เช็กอินอารมณ์ 7 วัน' : 'Mood check-ins (7D)',
													value: '$_moodCheckins7d',
												),
											),
										),
										const SizedBox(width: 12),
										Expanded(
											child: GlassCard(
												child: _metricBlock(
													context: context,
													icon: Icons.timer_outlined,
													color: const Color(0xFF60A5FA),
													label: isThai ? 'เซสชัน 7 วัน' : 'Sessions (7D)',
													value: '${sessions7d.length}',
												),
											),
										),
									],
								),
							],
						),
					),
				),
			),
		);
	}

	Widget _metricBlock({
		required BuildContext context,
		required IconData icon,
		required Color color,
		required String label,
		required String value,
	}) {
		final isDark = Theme.of(context).brightness == Brightness.dark;
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Icon(icon, color: color, size: 24),
				const SizedBox(height: 12),
				Text(
					label,
					style: TextStyle(
						color: isDark ? Colors.white70 : AppTheme.textMuted,
						fontSize: 12,
						fontWeight: FontWeight.w700,
					),
				),
				const SizedBox(height: 4),
				Text(
					value,
					style: TextStyle(
						color: isDark ? Colors.white : AppTheme.textDark,
						fontSize: 26,
						fontWeight: FontWeight.w900,
					),
				),
			],
		);
	}
}
