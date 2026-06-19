import { Ionicons } from '@expo/vector-icons';
import React from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';

import { GradientScreen } from '@/components/ui/gradient-screen';
import { TopBar } from '@/components/ui/top-bar';
import { VCard } from '@/components/ui/v-card';
import { VirtuoColors, VirtuoRadii, VirtuoSpacing } from '@/constants/virtuomate-theme';

function Metric({ label, value, color }: { label: string; value: string; color: string }) {
  return (
    <VCard style={styles.metric}>
      <Text style={styles.metricValue}>{value}</Text>
      <Text style={styles.metricLabel}>{label}</Text>
      <View style={[styles.metricLine, { backgroundColor: color }]} />
    </VCard>
  );
}

export default function FeedbackScreen() {
  return (
    <GradientScreen>
      <TopBar title="Analytics & Feedback" />
      <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
        <Text style={styles.sub}>Personalized insights and next-step recommendations</Text>

        <View style={{ height: 14 }} />
        <View style={styles.row3}>
          <Metric label="Sentiment" value="75%" color={VirtuoColors.cyan} />
          <Metric label="Confidence" value="88%" color={VirtuoColors.purple} />
          <Metric label="Engagement" value="92%" color={VirtuoColors.green} />
        </View>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16 }}>
          <View style={styles.headRow}>
            <Ionicons name="sparkles-outline" size={18} color={VirtuoColors.cyan} />
            <Text style={styles.section}>AI Recommendations</Text>
          </View>
          <View style={{ height: 10 }} />
          {[
            'Focus on leadership skills to reach your next milestone',
            'Practice presentation skills 2-3 times this week',
            'You’re on track to achieve “Master Communicator” badge',
          ].map((t) => (
            <View key={t} style={styles.bulletRow}>
              <View style={styles.dot} />
              <Text style={styles.bullet}>{t}</Text>
            </View>
          ))}
        </VCard>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16 }}>
          <Text style={styles.section}>Detailed Feedback</Text>
          <View style={{ height: 10 }} />
          {[
            { k: 'Clarity', v: 'Strong', c: VirtuoColors.green },
            { k: 'Structure', v: 'Good', c: VirtuoColors.cyan },
            { k: 'Relevance', v: 'Needs focus', c: VirtuoColors.yellow },
          ].map((x) => (
            <View key={x.k} style={styles.detailRow}>
              <Text style={styles.detailKey}>{x.k}</Text>
              <Text style={[styles.detailVal, { color: x.c }]}>{x.v}</Text>
            </View>
          ))}
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
  metric: { flex: 1, height: 96, alignItems: 'center', justifyContent: 'center', gap: 6, padding: 12 },
  metricValue: { color: VirtuoColors.text, fontWeight: '900', fontSize: 18 },
  metricLabel: { color: VirtuoColors.textMuted, fontWeight: '800', fontSize: 11 },
  metricLine: { height: 3, width: 40, borderRadius: 999, marginTop: 6 },
  headRow: { flexDirection: 'row', gap: 10, alignItems: 'center' },
  section: { color: VirtuoColors.text, fontWeight: '900', fontSize: 13 },
  bulletRow: { flexDirection: 'row', gap: 10, alignItems: 'center', marginTop: 10 },
  dot: { width: 6, height: 6, borderRadius: 3, backgroundColor: VirtuoColors.cyan },
  bullet: { flex: 1, color: VirtuoColors.textMuted, fontWeight: '700', fontSize: 12, lineHeight: 16 },
  detailRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255,255,255,0.06)',
  },
  detailKey: { color: VirtuoColors.textMuted, fontWeight: '800', fontSize: 12 },
  detailVal: { color: VirtuoColors.text, fontWeight: '900', fontSize: 12 },
});

