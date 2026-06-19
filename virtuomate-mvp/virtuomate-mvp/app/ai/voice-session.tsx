import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { GradientScreen } from '@/components/ui/gradient-screen';
import { TopBar } from '@/components/ui/top-bar';
import { VirtuoColors, VirtuoRadii, VirtuoSpacing } from '@/constants/virtuomate-theme';

function MiniPill({ label, value, icon }: { label: string; value: string; icon: keyof typeof Ionicons.glyphMap }) {
  return (
    <View style={styles.miniPill}>
      <Ionicons name={icon} size={14} color={VirtuoColors.textMuted} />
      <View style={{ flex: 1 }}>
        <Text style={styles.miniLabel}>{label}</Text>
        <Text style={styles.miniValue}>{value}</Text>
      </View>
    </View>
  );
}

export default function VoiceSessionScreen() {
  return (
    <GradientScreen>
      <TopBar
        title="Voice Session"
        right={
          <Pressable style={styles.gear} onPress={() => {}}>
            <Ionicons name="settings-outline" size={16} color={VirtuoColors.text} />
          </Pressable>
        }
      />

      <View style={styles.container}>
        <View style={styles.statusPill}>
          <Text style={styles.statusText}>Not Connected</Text>
        </View>

        <View style={{ height: 26 }} />
        <View style={styles.avatarWrap}>
          <View style={styles.avatar} />
          <Text style={styles.mood}>Happy</Text>
        </View>

        <View style={{ height: 18 }} />
        <View style={styles.row}>
          <MiniPill label="Neural Link" value="Active" icon="aperture-outline" />
          <MiniPill label="Quality" value="HD" icon="sparkles-outline" />
          <MiniPill label="Latency" value="12ms" icon="flash-outline" />
        </View>

        <View style={{ flex: 1 }} />
        <Pressable style={styles.endBtn} onPress={() => router.back()}>
          <Ionicons name="mic-off" size={20} color="#fff" />
        </Pressable>
        <Text style={styles.endText}>End Voice Session</Text>

        <View style={{ height: 18 }} />
        <View style={styles.controls}>
          <View style={styles.ctrl}>
            <Ionicons name="hand-left-outline" size={18} color={VirtuoColors.textMuted} />
          </View>
          <View style={[styles.ctrl, styles.ctrlActive]}>
            <Ionicons name="mic-outline" size={20} color={VirtuoColors.text} />
          </View>
          <View style={styles.ctrl}>
            <Ionicons name="volume-high-outline" size={18} color={VirtuoColors.textMuted} />
          </View>
        </View>
        <View style={styles.ctrlLabels}>
          <Text style={styles.ctrlLabel}>Hold to Talk</Text>
          <Text style={[styles.ctrlLabel, { color: VirtuoColors.text }]}>Mic On</Text>
          <Text style={styles.ctrlLabel}>Audio On</Text>
        </View>

        <View style={{ height: 20 }} />
      </View>
    </GradientScreen>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, paddingHorizontal: VirtuoSpacing.lg, paddingBottom: 22, alignItems: 'center' },
  gear: {
    width: 34,
    height: 34,
    borderRadius: 17,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  statusPill: {
    alignSelf: 'center',
    height: 28,
    borderRadius: 999,
    paddingHorizontal: 14,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    justifyContent: 'center',
  },
  statusText: { color: VirtuoColors.textMuted, fontWeight: '800', fontSize: 12 },
  avatarWrap: { alignItems: 'center' },
  avatar: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: 'rgba(255,255,255,0.08)',
    borderWidth: 2,
    borderColor: 'rgba(59,231,255,0.25)',
  },
  mood: {
    marginTop: 10,
    color: VirtuoColors.text,
    fontWeight: '900',
    fontSize: 12,
    backgroundColor: 'rgba(139,92,255,0.32)',
    borderRadius: 999,
    paddingHorizontal: 14,
    height: 28,
    textAlignVertical: 'center',
    includeFontPadding: false,
    paddingTop: 6,
  },
  row: { flexDirection: 'row', gap: 10, width: '100%', marginTop: 10 },
  miniPill: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    padding: 12,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(255,255,255,0.05)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
  },
  miniLabel: { color: VirtuoColors.textFaint, fontSize: 10, fontWeight: '800' },
  miniValue: { color: VirtuoColors.text, fontSize: 12, fontWeight: '900', marginTop: 4 },
  endBtn: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: '#FF3B5C',
    alignItems: 'center',
    justifyContent: 'center',
  },
  endText: { marginTop: 10, color: VirtuoColors.textMuted, fontWeight: '800', fontSize: 12 },
  controls: { flexDirection: 'row', gap: 18, alignItems: 'center' },
  ctrl: {
    width: 52,
    height: 52,
    borderRadius: 26,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  ctrlActive: { backgroundColor: 'rgba(255,255,255,0.10)', borderColor: 'rgba(59,231,255,0.25)' },
  ctrlLabels: { flexDirection: 'row', width: '100%', justifyContent: 'space-between', marginTop: 8 },
  ctrlLabel: { flex: 1, textAlign: 'center', color: VirtuoColors.textFaint, fontSize: 11, fontWeight: '800' },
});

