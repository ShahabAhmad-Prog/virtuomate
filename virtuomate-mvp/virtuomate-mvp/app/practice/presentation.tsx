import { Ionicons } from '@expo/vector-icons';
import React from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';

import { GradientScreen } from '@/components/ui/gradient-screen';
import { TopBar } from '@/components/ui/top-bar';
import { VCard } from '@/components/ui/v-card';
import { VirtuoColors, VirtuoRadii, VirtuoSpacing } from '@/constants/virtuomate-theme';

export default function PresentationPracticeScreen() {
  return (
    <GradientScreen>
      <TopBar
        title="Presentation Practice"
        right={
          <View style={{ alignItems: 'flex-end' }}>
            <Text style={styles.timer}>00:00</Text>
            <Text style={styles.pct}>20%</Text>
          </View>
        }
      />

      <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
        <View style={styles.topMeta}>
          <Text style={styles.slideMeta}>Slide 1 of 5</Text>
        </View>
        <View style={styles.progressTrack}>
          <View style={[styles.progressFill, { width: '20%' }]} />
        </View>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16 }}>
          <View style={styles.audienceTop}>
            <View style={styles.groupIcon}>
              <Ionicons name="people-outline" size={18} color={VirtuoColors.text} />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.audienceTitle}>Virtual Audience</Text>
              <Text style={styles.audienceSub}>AI Neural Assessment Active</Text>
            </View>
            <View style={styles.dot} />
          </View>

          <View style={{ height: 14 }} />
          <View style={styles.faceBox}>
            <Text style={styles.face}>🙂</Text>
            <Text style={styles.faceText}>Audience is engaged and interested</Text>
          </View>
        </VCard>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16 }}>
          <View style={styles.sectionRow}>
            <Ionicons name="document-text-outline" size={16} color={VirtuoColors.cyan} />
            <Text style={styles.sectionTitle}>Introduction</Text>
          </View>

          <View style={{ height: 12 }} />
          <View style={styles.previewArea}>
            <View style={styles.slideBadge}>
              <Text style={styles.slideBadgeText}>1</Text>
            </View>
            <Text style={styles.previewText}>Slide Preview Area</Text>
          </View>

          <View style={{ height: 12 }} />
          <View style={styles.promptPill}>
            <Text style={styles.promptLabel}>Speaking Prompt</Text>
            <Text style={styles.promptText}>Introduce yourself and the topic</Text>
          </View>
        </VCard>

        <View style={{ height: 18 }} />
      </ScrollView>
    </GradientScreen>
  );
}

const styles = StyleSheet.create({
  container: { paddingHorizontal: VirtuoSpacing.lg, paddingBottom: 24 },
  timer: { color: VirtuoColors.text, fontWeight: '900', fontSize: 12 },
  pct: { color: VirtuoColors.textMuted, fontWeight: '800', fontSize: 11, marginTop: 4 },
  topMeta: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  slideMeta: { color: VirtuoColors.textMuted, fontWeight: '800', fontSize: 11 },
  progressTrack: {
    height: 6,
    borderRadius: 999,
    backgroundColor: 'rgba(255,255,255,0.08)',
    overflow: 'hidden',
    marginTop: 10,
  },
  progressFill: { height: '100%', backgroundColor: VirtuoColors.purple },
  audienceTop: { flexDirection: 'row', gap: 12, alignItems: 'center' },
  groupIcon: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: 'rgba(255,255,255,0.08)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  audienceTitle: { color: VirtuoColors.text, fontWeight: '900', fontSize: 13 },
  audienceSub: { color: VirtuoColors.cyan, fontWeight: '800', fontSize: 11, marginTop: 4 },
  dot: { width: 10, height: 10, borderRadius: 5, backgroundColor: VirtuoColors.green },
  faceBox: {
    height: 64,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 6,
  },
  face: { fontSize: 18 },
  faceText: { color: VirtuoColors.textMuted, fontWeight: '800', fontSize: 11 },
  sectionRow: { flexDirection: 'row', gap: 10, alignItems: 'center' },
  sectionTitle: { color: VirtuoColors.text, fontWeight: '900', fontSize: 13 },
  previewArea: {
    height: 140,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(255,255,255,0.03)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 10,
  },
  slideBadge: {
    width: 48,
    height: 48,
    borderRadius: 16,
    backgroundColor: 'rgba(139,92,255,0.35)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.18)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  slideBadgeText: { color: VirtuoColors.text, fontWeight: '900', fontSize: 18 },
  previewText: { color: VirtuoColors.textFaint, fontWeight: '800', fontSize: 12 },
  promptPill: {
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(59,231,255,0.06)',
    borderWidth: 1,
    borderColor: 'rgba(59,231,255,0.14)',
    padding: 12,
  },
  promptLabel: { color: VirtuoColors.cyan, fontWeight: '900', fontSize: 11 },
  promptText: { color: VirtuoColors.text, fontWeight: '800', fontSize: 12, marginTop: 6 },
});

