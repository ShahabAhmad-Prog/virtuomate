import { Ionicons } from '@expo/vector-icons';
import React from 'react';
import { Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';

import { GradientScreen } from '@/components/ui/gradient-screen';
import { TopBar } from '@/components/ui/top-bar';
import { VCard } from '@/components/ui/v-card';
import { VirtuoColors, VirtuoRadii, VirtuoSpacing } from '@/constants/virtuomate-theme';

export default function InterviewSimulationScreen() {
  return (
    <GradientScreen>
      <TopBar
        title="Interview Simulation"
        right={<Text style={styles.step}>1/3</Text>}
      />

      <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
        <View style={styles.progress}>
          <View style={[styles.progressSeg, { flex: 1, backgroundColor: VirtuoColors.cyan }]} />
          <View style={[styles.progressSeg, { flex: 1, backgroundColor: 'rgba(139,92,255,0.6)' }]} />
          <View style={[styles.progressSeg, { flex: 1, backgroundColor: 'rgba(255,255,255,0.10)' }]} />
        </View>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16 }}>
          <View style={styles.aiRow}>
            <View style={styles.aiIcon}>
              <Ionicons name="hardware-chip-outline" size={18} color={VirtuoColors.text} />
            </View>
            <View style={{ flex: 1 }}>
              <View style={styles.aiTop}>
                <Text style={styles.aiTitle}>AI Interviewer v3.0</Text>
                <View style={styles.badge}>
                  <Text style={styles.badgeText}>Introduction</Text>
                </View>
              </View>
              <View style={styles.waveTrack}>
                <View style={styles.waveBar} />
                <View style={[styles.waveBar, { height: 14, opacity: 0.9 }]} />
                <View style={[styles.waveBar, { height: 10, opacity: 0.7 }]} />
              </View>
              <Text style={styles.prompt}>
                Tell me about yourself and your professional background.
              </Text>
            </View>
          </View>
        </VCard>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16 }}>
          <View style={styles.confRow}>
            <Ionicons name="trending-up-outline" size={16} color={VirtuoColors.cyan} />
            <Text style={styles.confTitle}>AI Confidence Analysis</Text>
            <View style={{ flex: 1 }} />
            <Text style={styles.confPct}>72%</Text>
          </View>
          <Text style={styles.confSub}>Real-time neural analysis of speech patterns and clarity</Text>
          <View style={{ height: 10 }} />
          <View style={styles.confTrack}>
            <View style={[styles.confFill, { width: '72%' }]} />
          </View>
        </VCard>

        <View style={{ height: 14 }} />
        <View style={styles.responseTop}>
          <Text style={styles.responseTitle}>Your Response</Text>
          <Pressable style={styles.voiceBtn} onPress={() => {}}>
            <Ionicons name="mic-outline" size={14} color={VirtuoColors.text} />
            <Text style={styles.voiceBtnText}>Voice Input</Text>
          </Pressable>
        </View>
        <VCard style={{ padding: 12 }}>
          <TextInput
            placeholder="Type your answer here or use voice input..."
            placeholderTextColor={VirtuoColors.textFaint}
            style={styles.textArea}
            multiline
          />
          <View style={styles.metaRow}>
            <Text style={styles.meta}>0 chars</Text>
            <Text style={styles.meta}>~1 min</Text>
          </View>
        </VCard>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16, backgroundColor: 'rgba(255,255,255,0.10)' }}>
          <View style={styles.suggestTop}>
            <Ionicons name="bulb-outline" size={16} color={VirtuoColors.cyan} />
            <Text style={styles.suggestTitle}>AI Strategy Suggestions</Text>
          </View>
          <View style={{ height: 10 }} />
          {[
            'Keep it concise (2-3 minutes)',
            'Focus on relevant experience',
            'End with why you’re interested in this role',
          ].map((t) => (
            <View key={t} style={styles.bulletRow}>
              <Text style={styles.bulletDot}>•</Text>
              <Text style={styles.bullet}>{t}</Text>
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
  step: { color: VirtuoColors.cyan, fontWeight: '900', fontSize: 12 },
  progress: { flexDirection: 'row', gap: 10 },
  progressSeg: { height: 6, borderRadius: 999 },
  aiRow: { flexDirection: 'row', gap: 12, alignItems: 'flex-start' },
  aiIcon: {
    width: 42,
    height: 42,
    borderRadius: 21,
    backgroundColor: 'rgba(255,255,255,0.08)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  aiTop: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  aiTitle: { color: VirtuoColors.text, fontWeight: '900', fontSize: 13 },
  badge: {
    height: 20,
    paddingHorizontal: 10,
    borderRadius: 999,
    backgroundColor: 'rgba(255,92,124,0.22)',
    borderWidth: 1,
    borderColor: 'rgba(255,92,124,0.28)',
    justifyContent: 'center',
  },
  badgeText: { color: VirtuoColors.text, fontWeight: '900', fontSize: 10 },
  waveTrack: {
    height: 18,
    borderRadius: 999,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    marginTop: 10,
    paddingHorizontal: 10,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  waveBar: { width: 4, height: 12, borderRadius: 3, backgroundColor: VirtuoColors.green },
  prompt: { marginTop: 12, color: VirtuoColors.text, fontWeight: '800', fontSize: 13, lineHeight: 18 },
  confRow: { flexDirection: 'row', gap: 10, alignItems: 'center' },
  confTitle: { color: VirtuoColors.text, fontWeight: '900', fontSize: 12 },
  confPct: { color: VirtuoColors.cyan, fontWeight: '900', fontSize: 12 },
  confSub: { color: VirtuoColors.textMuted, fontWeight: '700', fontSize: 11, marginTop: 8 },
  confTrack: {
    height: 10,
    borderRadius: 999,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    overflow: 'hidden',
  },
  confFill: { height: '100%', backgroundColor: VirtuoColors.purple },
  responseTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  responseTitle: { color: VirtuoColors.cyan, fontWeight: '900', fontSize: 12 },
  voiceBtn: {
    flexDirection: 'row',
    gap: 8,
    alignItems: 'center',
    height: 28,
    paddingHorizontal: 12,
    borderRadius: 999,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
  },
  voiceBtnText: { color: VirtuoColors.text, fontWeight: '900', fontSize: 11 },
  textArea: { minHeight: 90, color: VirtuoColors.text, fontSize: 12, fontWeight: '700' },
  metaRow: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 8 },
  meta: { color: VirtuoColors.textFaint, fontSize: 10, fontWeight: '700' },
  suggestTop: { flexDirection: 'row', gap: 10, alignItems: 'center' },
  suggestTitle: { color: VirtuoColors.text, fontWeight: '900', fontSize: 12 },
  bulletRow: { flexDirection: 'row', gap: 8, marginTop: 8 },
  bulletDot: { color: VirtuoColors.cyan, fontWeight: '900' },
  bullet: { flex: 1, color: VirtuoColors.textMuted, fontWeight: '700', fontSize: 12, lineHeight: 16 },
});

