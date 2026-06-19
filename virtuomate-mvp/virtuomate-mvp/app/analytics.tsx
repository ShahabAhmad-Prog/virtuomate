import { Ionicons } from '@expo/vector-icons';
import React from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';

import { GradientScreen } from '@/components/ui/gradient-screen';
import { TopBar } from '@/components/ui/top-bar';
import { VCard } from '@/components/ui/v-card';
import { VirtuoColors, VirtuoRadii, VirtuoSpacing } from '@/constants/virtuomate-theme';

function StatCard({ title, value, delta, icon }: { title: string; value: string; delta: string; icon: keyof typeof Ionicons.glyphMap }) {
  return (
    <VCard style={styles.statCard}>
      <Ionicons name={icon} size={16} color={VirtuoColors.cyan} />
      <Text style={styles.statValue}>{value}</Text>
      <Text style={styles.statTitle}>{title}</Text>
      <Text style={styles.statDelta}>{delta}</Text>
    </VCard>
  );
}

export default function AnalyticsScreen() {
  return (
    <GradientScreen>
      <TopBar title="Neural Analytics" />
      <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
        <Text style={styles.sub}>Track your AI-powered growth metrics</Text>

        <View style={{ height: 14 }} />
        <View style={styles.row3}>
          <StatCard title="Avg Score" value="85%" delta="+12%" icon="radio-outline" />
          <StatCard title="Sessions" value="24" delta="+8" icon="calendar-outline" />
          <StatCard title="Achievements" value="7" delta="+3" icon="ribbon-outline" />
        </View>

        <View style={{ height: 14 }} />
        <Text style={styles.section}>Real-time AI Analysis</Text>
        <View style={styles.row3}>
          <VCard style={styles.smallTile}>
            <Text style={styles.tileValue}>75%</Text>
            <Text style={styles.tileLabel}>Sentiment</Text>
          </VCard>
          <VCard style={styles.smallTile}>
            <Text style={styles.tileValue}>88%</Text>
            <Text style={styles.tileLabel}>Confidence</Text>
          </VCard>
          <VCard style={styles.smallTile}>
            <Text style={styles.tileValue}>92%</Text>
            <Text style={styles.tileLabel}>Engagement</Text>
          </VCard>
        </View>

        <View style={{ height: 14 }} />
        <Text style={styles.section}>Progress Over Time</Text>
        <VCard style={{ padding: 16 }}>
          <View style={styles.chart}>
            <View style={styles.gridLine} />
            <View style={[styles.point, { left: '15%', top: '55%' }]} />
            <View style={[styles.point, { left: '40%', top: '45%' }]} />
            <View style={[styles.point, { left: '65%', top: '38%' }]} />
            <View style={[styles.point, { left: '85%', top: '28%' }]} />
          </View>
          <View style={styles.weekRow}>
            {['Week 1', 'Week 2', 'Week 3', 'Week 4'].map((w) => (
              <Text key={w} style={styles.week}>
                {w}
              </Text>
            ))}
          </View>
        </VCard>

        <View style={{ height: 14 }} />
        <Text style={styles.section}>Weekly Activity</Text>
        <VCard style={{ padding: 16 }}>
          <View style={styles.barRow}>
            {[2, 3, 1, 4, 2].map((h, i) => (
              <View key={i} style={styles.barWrap}>
                <View style={[styles.bar, { height: 20 + h * 18 }]} />
                <Text style={styles.barLabel}>{['Mon', 'Tue', 'Wed', 'Thu', 'Fri'][i]}</Text>
              </View>
            ))}
          </View>
        </VCard>

        <View style={{ height: 14 }} />
        <Text style={styles.section}>Skills Assessment</Text>
        <VCard style={{ padding: 16 }}>
          <View style={styles.radar}>
            <View style={styles.radarRing} />
            <View style={[styles.radarRing, { transform: [{ scale: 0.75 }] }]} />
            <View style={[styles.radarRing, { transform: [{ scale: 0.5 }] }]} />
            <View style={styles.radarFill} />
          </View>
          <View style={styles.radarLabels}>
            {['Communication', 'Leadership', 'Problem Solving', 'Presentation', 'Interview Skills'].map((t) => (
              <Text key={t} style={styles.radarLabel}>
                {t}
              </Text>
            ))}
          </View>
        </VCard>

        <View style={{ height: 18 }} />
      </ScrollView>
    </GradientScreen>
  );
}

const styles = StyleSheet.create({
  container: { paddingHorizontal: VirtuoSpacing.lg, paddingBottom: 24 },
  sub: { color: VirtuoColors.textMuted, fontSize: 12, marginTop: 2 },
  row3: { flexDirection: 'row', gap: 10 },
  statCard: { flex: 1, height: 106, alignItems: 'center', justifyContent: 'center', gap: 6, padding: 12 },
  statValue: { color: VirtuoColors.text, fontWeight: '900', fontSize: 18 },
  statTitle: { color: VirtuoColors.textMuted, fontWeight: '800', fontSize: 11 },
  statDelta: { color: VirtuoColors.green, fontWeight: '900', fontSize: 11 },
  section: { color: VirtuoColors.text, fontWeight: '900', fontSize: 13, marginBottom: 10 },
  smallTile: { flex: 1, height: 86, alignItems: 'center', justifyContent: 'center', gap: 8, padding: 12 },
  tileValue: { color: VirtuoColors.text, fontWeight: '900', fontSize: 18 },
  tileLabel: { color: VirtuoColors.textMuted, fontWeight: '800', fontSize: 11 },
  chart: {
    height: 160,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(255,255,255,0.03)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    overflow: 'hidden',
  },
  gridLine: {
    position: 'absolute',
    left: 0,
    right: 0,
    top: '50%',
    height: 1,
    backgroundColor: 'rgba(255,255,255,0.10)',
  },
  point: {
    position: 'absolute',
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: VirtuoColors.cyan,
  },
  weekRow: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 10 },
  week: { color: VirtuoColors.textFaint, fontSize: 11, fontWeight: '800' },
  barRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-end' },
  barWrap: { alignItems: 'center', gap: 8, flex: 1 },
  bar: {
    width: 22,
    borderRadius: 10,
    backgroundColor: 'rgba(139,92,255,0.9)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.18)',
  },
  barLabel: { color: VirtuoColors.textFaint, fontSize: 11, fontWeight: '800' },
  radar: {
    height: 200,
    borderRadius: VirtuoRadii.lg,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255,255,255,0.03)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    overflow: 'hidden',
  },
  radarRing: {
    position: 'absolute',
    width: 160,
    height: 160,
    borderRadius: 80,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.12)',
  },
  radarFill: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: 'rgba(59,231,255,0.18)',
    borderWidth: 1,
    borderColor: 'rgba(59,231,255,0.22)',
  },
  radarLabels: { marginTop: 10, gap: 4 },
  radarLabel: { color: VirtuoColors.textMuted, fontSize: 11, fontWeight: '800' },
});

