import { Ionicons } from '@expo/vector-icons';
import React, { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import { GradientScreen } from '@/components/ui/gradient-screen';
import { TopBar } from '@/components/ui/top-bar';
import { VButton } from '@/components/ui/v-button';
import { VCard } from '@/components/ui/v-card';
import { VirtuoColors, VirtuoRadii, VirtuoSpacing } from '@/constants/virtuomate-theme';

const scenarios = [
  { title: 'Salary Negotiation', tag: 'Role-play', icon: 'cash-outline' as const },
  { title: 'Leadership Conversation', tag: 'Role-play', icon: 'people-outline' as const },
  { title: 'Conflict Resolution', tag: 'Role-play', icon: 'shield-checkmark-outline' as const },
  { title: 'Client Pitch', tag: 'Role-play', icon: 'briefcase-outline' as const },
];

export default function RolePlayScreen() {
  const [selected, setSelected] = useState(0);

  return (
    <GradientScreen>
      <TopBar title="Role Play Simulation" right={<Text style={styles.step}>1/3</Text>} />
      <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
        <Text style={styles.sub}>
          Practice real-world scenarios with an AI coach and get adaptive feedback.
        </Text>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16 }}>
          <Text style={styles.section}>Choose a scenario</Text>
          <View style={{ height: 10 }} />

          {scenarios.map((s, i) => {
            const active = i === selected;
            return (
              <Pressable
                key={s.title}
                onPress={() => setSelected(i)}
                style={[styles.row, active ? styles.rowActive : undefined]}>
                <View style={styles.icon}>
                  <Ionicons name={s.icon} size={18} color={VirtuoColors.text} />
                </View>
                <View style={{ flex: 1 }}>
                  <Text style={styles.title}>{s.title}</Text>
                  <Text style={styles.tag}>{s.tag}</Text>
                </View>
                {active ? <Ionicons name="checkmark" size={18} color={VirtuoColors.cyan} /> : null}
              </Pressable>
            );
          })}

          <View style={{ height: 12 }} />
          <VButton
            title="Start Role-play"
            iconLeft={<Ionicons name="play" size={18} color="#0B0720" />}
            onPress={() => {}}
          />
        </VCard>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16 }}>
          <Text style={styles.section}>What you’ll get</Text>
          <View style={{ height: 10 }} />
          {[
            'Live coaching prompts based on your replies',
            'Emotion-aware tone adjustments (stub)',
            'Performance insights & recommendations',
          ].map((t) => (
            <View key={t} style={styles.bulletRow}>
              <Text style={styles.dot}>•</Text>
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
  sub: { color: VirtuoColors.textMuted, fontSize: 12, marginTop: 2 },
  section: { color: VirtuoColors.text, fontWeight: '900', fontSize: 13 },
  row: {
    flexDirection: 'row',
    gap: 12,
    alignItems: 'center',
    padding: 14,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    marginTop: 10,
  },
  rowActive: { borderColor: 'rgba(59,231,255,0.22)', backgroundColor: 'rgba(59,231,255,0.06)' },
  icon: {
    width: 36,
    height: 36,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: { color: VirtuoColors.text, fontWeight: '900', fontSize: 12 },
  tag: { color: VirtuoColors.textMuted, fontWeight: '700', fontSize: 11, marginTop: 4 },
  bulletRow: { flexDirection: 'row', gap: 8, marginTop: 8 },
  dot: { color: VirtuoColors.cyan, fontWeight: '900' },
  bullet: { flex: 1, color: VirtuoColors.textMuted, fontWeight: '700', fontSize: 12, lineHeight: 16 },
});

