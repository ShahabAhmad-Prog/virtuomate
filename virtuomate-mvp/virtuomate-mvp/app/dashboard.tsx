import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import React from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import { GradientScreen } from '@/components/ui/gradient-screen';
import { VButton } from '@/components/ui/v-button';
import { VCard } from '@/components/ui/v-card';
import { VirtuoColors, VirtuoRadii, VirtuoSpacing } from '@/constants/virtuomate-theme';

function MiniStat({ icon, label, value }: { icon: keyof typeof Ionicons.glyphMap; label: string; value: string }) {
  return (
    <View style={styles.miniStat}>
      <Ionicons name={icon} size={16} color={VirtuoColors.cyan} />
      <Text style={styles.miniValue}>{value}</Text>
      <Text style={styles.miniLabel}>{label}</Text>
    </View>
  );
}

export default function DashboardScreen() {
  return (
    <GradientScreen>
      <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
        <View style={styles.topRow}>
          <View>
            <Text style={styles.system}>SYSTEM ACTIVE</Text>
            <Text style={styles.name}>Shahab Ahmad</Text>
          </View>
          <View style={styles.topActions}>
            <Pressable style={styles.iconBtn} onPress={() => router.push('/settings')}>
              <Ionicons name="settings-outline" size={18} color={VirtuoColors.text} />
            </Pressable>
            <Pressable style={styles.iconBtn} onPress={() => router.push('/avatar/builder')}>
              <Ionicons name="person-circle-outline" size={20} color={VirtuoColors.text} />
            </Pressable>
          </View>
        </View>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16 }}>
          <View style={styles.coachRow}>
            <View style={styles.coachIcon}>
              <Ionicons name="brain-outline" size={22} color={VirtuoColors.text} />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.coachTitle}>Your AI Coach</Text>
              <Text style={styles.coachSub}>VIRTUOMATE Neural Engine v3.0</Text>
              <View style={styles.activityBar}>
                {Array.from({ length: 10 }).map((_, i) => (
                  <View
                    key={i}
                    style={[
                      styles.activityPill,
                      { opacity: 0.35 + (i % 3) * 0.2 },
                      i % 2 === 0 ? { backgroundColor: VirtuoColors.cyan } : { backgroundColor: VirtuoColors.purple },
                    ]}
                  />
                ))}
              </View>
              <Text style={styles.ready}>87% Ready</Text>
            </View>
          </View>

          <View style={{ height: 14 }} />
          <VButton
            title="Initialize AI Session"
            iconLeft={<Ionicons name="flash" size={18} color="#0B0720" />}
            onPress={() => router.push('/ai/session')}
          />
        </VCard>

        <View style={{ height: 14 }} />
        <View style={styles.statsRow}>
          <MiniStat icon="time-outline" label="Sessions" value="12" />
          <MiniStat icon="trending-up-outline" label="Progress" value="85%" />
          <MiniStat icon="ribbon-outline" label="Achievements" value="5" />
        </View>

        <View style={{ height: 14 }} />
        <Text style={styles.sectionTitle}>Active Mission</Text>
        <VCard style={{ padding: 16 }}>
          <View style={styles.missionRow}>
            <View style={styles.missionIcon}>
              <Ionicons name="radio-outline" size={18} color={VirtuoColors.text} />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.missionTitle}>Interview Preparation</Text>
              <Text style={styles.missionSub}>Neural optimization in progress</Text>
              <View style={styles.progressTrack}>
                <View style={[styles.progressFill, { width: '65%' }]} />
              </View>
              <Text style={styles.progressText}>65% Neural Pathways Optimized</Text>
            </View>
          </View>
          <View style={{ height: 12 }} />
          <VButton
            title="Resume Mission"
            variant="outline"
            iconLeft={<Ionicons name="play-outline" size={16} color={VirtuoColors.text} />}
            onPress={() => router.push('/practice/interview')}
          />
        </VCard>

        <View style={{ height: 14 }} />
        <Text style={styles.sectionTitle}>Session History</Text>
        <VCard style={{ padding: 0 }}>
          <Pressable style={styles.sessionRow} onPress={() => router.push('/practice/interview')}>
            <View style={styles.sessionIcon}>
              <Ionicons name="chatbubble-ellipses-outline" size={16} color={VirtuoColors.text} />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.sessionTitle}>Mock Interview Practice</Text>
              <Text style={styles.sessionSub}>2 hours ago</Text>
            </View>
            <View style={styles.sessionTag}>
              <Text style={styles.sessionTagText}>Interview</Text>
            </View>
          </Pressable>
          <View style={styles.divider} />
          <Pressable style={styles.sessionRow} onPress={() => router.push('/practice/presentation')}>
            <View style={styles.sessionIcon}>
              <Ionicons name="play-outline" size={16} color={VirtuoColors.text} />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.sessionTitle}>Presentation Skills</Text>
              <Text style={styles.sessionSub}>Yesterday</Text>
            </View>
            <View style={styles.sessionTag}>
              <Text style={styles.sessionTagText}>Presentation</Text>
            </View>
          </Pressable>
        </VCard>

        <View style={{ height: 16 }} />
        <View style={styles.quickRow}>
          <VButton
            title="Customize AI"
            variant="ghost"
            style={{ flex: 1 }}
            iconLeft={<Ionicons name="options-outline" size={18} color={VirtuoColors.cyan} />}
            onPress={() => router.push('/ai/config')}
          />
          <View style={{ width: 10 }} />
          <VButton
            title="Neural Analytics"
            variant="ghost"
            style={{ flex: 1 }}
            iconLeft={<Ionicons name="analytics-outline" size={18} color={VirtuoColors.cyan} />}
            onPress={() => router.push('/analytics')}
          />
        </View>

        <View style={{ height: 10 }} />
        <View style={styles.quickRow}>
          <VButton
            title="Video CV"
            variant="ghost"
            style={{ flex: 1 }}
            iconLeft={<Ionicons name="videocam-outline" size={18} color={VirtuoColors.cyan} />}
            onPress={() => router.push('/video-cv/create')}
          />
          <View style={{ width: 10 }} />
          <VButton
            title="Avatar Builder"
            variant="ghost"
            style={{ flex: 1 }}
            iconLeft={<Ionicons name="person-circle-outline" size={18} color={VirtuoColors.cyan} />}
            onPress={() => router.push('/ai/config?tab=visual')}
          />
        </View>

        <View style={{ height: 12 }} />
        <VButton
          title="Upgrade Neural Access"
          variant="outline"
          iconLeft={<Ionicons name="diamond-outline" size={18} color={VirtuoColors.text} />}
          onPress={() => router.push('/premium')}
        />

        <View style={{ height: 10 }} />
        <VButton
          title="Feedback & Recommendations"
          variant="outline"
          iconLeft={<Ionicons name="sparkles-outline" size={18} color={VirtuoColors.text} />}
          onPress={() => router.push('/feedback')}
        />

        <View style={{ height: 10 }} />
        <VButton
          title="Role Play Simulation"
          variant="outline"
          iconLeft={<Ionicons name="people-outline" size={18} color={VirtuoColors.text} />}
          onPress={() => router.push('/practice/role-play')}
        />
      </ScrollView>
    </GradientScreen>
  );
}

const styles = StyleSheet.create({
  container: { paddingHorizontal: VirtuoSpacing.lg, paddingTop: 52, paddingBottom: 24 },
  topRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  system: { color: VirtuoColors.cyan, fontSize: 11, fontWeight: '900', letterSpacing: 1.2 },
  name: { color: VirtuoColors.text, fontSize: 18, fontWeight: '900', marginTop: 6 },
  topActions: { flexDirection: 'row', gap: 10 },
  iconBtn: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  coachRow: { flexDirection: 'row', gap: 14, alignItems: 'center' },
  coachIcon: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  coachTitle: { color: VirtuoColors.text, fontWeight: '900', fontSize: 16 },
  coachSub: { color: VirtuoColors.cyan, fontSize: 11, marginTop: 3, fontWeight: '800' },
  activityBar: { flexDirection: 'row', gap: 6, marginTop: 10, flexWrap: 'wrap' },
  activityPill: { width: 16, height: 6, borderRadius: 4 },
  ready: { color: VirtuoColors.textMuted, fontSize: 11, marginTop: 8, fontWeight: '700' },
  statsRow: { flexDirection: 'row', gap: 10 },
  miniStat: {
    flex: 1,
    height: 96,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 6,
  },
  miniValue: { color: VirtuoColors.text, fontSize: 18, fontWeight: '900' },
  miniLabel: { color: VirtuoColors.textMuted, fontSize: 11, fontWeight: '700' },
  sectionTitle: { color: VirtuoColors.text, fontSize: 14, fontWeight: '900', marginBottom: 10 },
  missionRow: { flexDirection: 'row', gap: 12, alignItems: 'center' },
  missionIcon: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  missionTitle: { color: VirtuoColors.text, fontWeight: '900', fontSize: 14 },
  missionSub: { color: VirtuoColors.textMuted, fontSize: 11, marginTop: 2 },
  progressTrack: {
    height: 8,
    borderRadius: 6,
    backgroundColor: 'rgba(255,255,255,0.07)',
    overflow: 'hidden',
    marginTop: 10,
  },
  progressFill: { height: '100%', backgroundColor: VirtuoColors.purple },
  progressText: { color: VirtuoColors.textFaint, fontSize: 11, marginTop: 8, fontWeight: '700' },
  quickRow: { flexDirection: 'row' },
  sessionRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    paddingHorizontal: 14,
    paddingVertical: 14,
  },
  sessionIcon: {
    width: 36,
    height: 36,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  sessionTitle: { color: VirtuoColors.text, fontWeight: '900', fontSize: 12 },
  sessionSub: { color: VirtuoColors.textMuted, fontWeight: '700', fontSize: 11, marginTop: 4 },
  sessionTag: {
    height: 24,
    paddingHorizontal: 10,
    borderRadius: 999,
    backgroundColor: 'rgba(139,92,255,0.25)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.16)',
    justifyContent: 'center',
  },
  sessionTagText: { color: VirtuoColors.text, fontWeight: '900', fontSize: 10 },
  divider: { height: 1, backgroundColor: 'rgba(255,255,255,0.06)' },
});

