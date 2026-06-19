import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import React from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import { GradientScreen } from '@/components/ui/gradient-screen';
import { TopBar } from '@/components/ui/top-bar';
import { VCard } from '@/components/ui/v-card';
import { VirtuoColors, VirtuoRadii, VirtuoSpacing } from '@/constants/virtuomate-theme';

function StatPill({ icon, label, value, valueColor }: { icon: keyof typeof Ionicons.glyphMap; label: string; value: string; valueColor?: string }) {
  return (
    <View style={styles.statPill}>
      <Ionicons name={icon} size={16} color={VirtuoColors.textMuted} />
      <View style={{ flex: 1 }}>
        <Text style={styles.statLabel}>{label}</Text>
        <Text style={[styles.statValue, valueColor ? { color: valueColor } : undefined]}>{value}</Text>
      </View>
    </View>
  );
}

export default function AiSessionScreen() {
  return (
    <GradientScreen>
      <TopBar
        title="AI Neural Coach"
        right={
          <Pressable style={styles.menuBtn} onPress={() => {}}>
            <Ionicons name="ellipsis-vertical" size={16} color={VirtuoColors.text} />
          </Pressable>
        }
      />

      <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
        <View style={styles.switchRow}>
          <Text style={styles.switchHint}>Want a more natural conversation?</Text>
          <Pressable style={styles.switchBtn} onPress={() => router.push('/ai/voice-session')}>
            <Ionicons name="call" size={14} color="#08161A" />
            <Text style={styles.switchBtnText}>Switch to Voice Mode</Text>
          </Pressable>
        </View>

        <View style={{ height: 18 }} />
        <View style={styles.avatarWrap}>
          <View style={styles.avatar} />
          <View style={styles.moodPill}>
            <Text style={styles.moodText}>Happy</Text>
          </View>
          <Text style={styles.ready}>• Ready</Text>
        </View>

        <View style={{ height: 18 }} />
        <View style={styles.statsRow}>
          <StatPill icon="aperture-outline" label="Neural" value="Active" valueColor={VirtuoColors.cyan} />
          <StatPill icon="pulse-outline" label="Processing" value="98%" valueColor={VirtuoColors.text} />
          <StatPill icon="trending-up-outline" label="Engagement" value="High" valueColor={VirtuoColors.green} />
          <StatPill icon="flash-outline" label="Response" value="Fast" valueColor={VirtuoColors.yellow} />
        </View>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 14 }}>
          <View style={styles.msgRow}>
            <View style={styles.botIcon}>
              <Ionicons name="sparkles" size={16} color={VirtuoColors.text} />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.msgTitle}>
                Hello! I&apos;m your AI Neural Coach. I&apos;m here to help you develop professionally and
                achieve your career goals. How can I assist you today?
              </Text>
              <Text style={styles.msgTime}>04:23</Text>
            </View>
          </View>
        </VCard>

        <View style={{ height: 18 }} />
        <Text style={styles.sectionTitle}>Control Avatar Expression</Text>
        <VCard style={{ padding: 12 }}>
          <View style={styles.exprGrid}>
            {['Happy', 'Thinking', 'Encouraging', 'Neutral', 'Surprised', 'Listening'].map((t) => (
              <View key={t} style={[styles.expr, t === 'Happy' ? styles.exprActive : undefined]}>
                <Text style={[styles.exprText, t === 'Happy' ? styles.exprTextActive : undefined]}>{t}</Text>
              </View>
            ))}
          </View>
        </VCard>

        <View style={{ height: 18 }} />
      </ScrollView>
    </GradientScreen>
  );
}

const styles = StyleSheet.create({
  container: { paddingHorizontal: VirtuoSpacing.lg, paddingBottom: 26 },
  menuBtn: {
    width: 34,
    height: 34,
    borderRadius: 17,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  switchRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  switchHint: { color: VirtuoColors.textMuted, fontSize: 12, fontWeight: '700' },
  switchBtn: {
    flexDirection: 'row',
    gap: 8,
    alignItems: 'center',
    height: 32,
    paddingHorizontal: 12,
    borderRadius: 999,
    backgroundColor: 'rgba(60,255,178,0.92)',
  },
  switchBtnText: { color: '#07171B', fontWeight: '900', fontSize: 12 },
  avatarWrap: { alignItems: 'center' },
  avatar: {
    width: 128,
    height: 128,
    borderRadius: 64,
    backgroundColor: 'rgba(255,255,255,0.08)',
    borderWidth: 2,
    borderColor: 'rgba(59,231,255,0.25)',
  },
  moodPill: {
    marginTop: 10,
    paddingHorizontal: 14,
    height: 28,
    borderRadius: 999,
    backgroundColor: 'rgba(139,92,255,0.32)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.18)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  moodText: { color: VirtuoColors.text, fontWeight: '900', fontSize: 12 },
  ready: { marginTop: 6, color: VirtuoColors.cyan, fontWeight: '800', fontSize: 12 },
  statsRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 10 },
  statPill: {
    flexBasis: '48%',
    flexGrow: 1,
    flexDirection: 'row',
    gap: 10,
    padding: 12,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(255,255,255,0.05)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
  },
  statLabel: { color: VirtuoColors.textFaint, fontSize: 11, fontWeight: '800' },
  statValue: { color: VirtuoColors.text, fontSize: 12, fontWeight: '900', marginTop: 4 },
  msgRow: { flexDirection: 'row', gap: 10 },
  botIcon: {
    width: 30,
    height: 30,
    borderRadius: 15,
    backgroundColor: 'rgba(255,255,255,0.08)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  msgTitle: { color: VirtuoColors.text, fontSize: 12, lineHeight: 18, fontWeight: '700' },
  msgTime: { marginTop: 8, color: VirtuoColors.textFaint, fontSize: 10, fontWeight: '700' },
  sectionTitle: { color: VirtuoColors.text, fontSize: 13, fontWeight: '900', marginBottom: 10 },
  exprGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10 },
  expr: {
    flexBasis: '30%',
    flexGrow: 1,
    height: 42,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  exprActive: { backgroundColor: 'rgba(139,92,255,0.35)', borderColor: 'rgba(255,255,255,0.18)' },
  exprText: { color: VirtuoColors.textMuted, fontWeight: '900', fontSize: 12 },
  exprTextActive: { color: VirtuoColors.text },
});

