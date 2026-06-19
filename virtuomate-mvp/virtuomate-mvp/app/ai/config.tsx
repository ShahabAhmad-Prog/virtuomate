import { Ionicons } from '@expo/vector-icons';
import { router, useLocalSearchParams } from 'expo-router';
import React, { useMemo, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import { GradientScreen } from '@/components/ui/gradient-screen';
import { Segmented, type Segment } from '@/components/ui/segmented';
import { TopBar } from '@/components/ui/top-bar';
import { VButton } from '@/components/ui/v-button';
import { VCard } from '@/components/ui/v-card';
import { VirtuoColors, VirtuoRadii, VirtuoSpacing } from '@/constants/virtuomate-theme';

type TabKey = 'aiModel' | 'visual' | 'voice' | 'neural';

function FauxSlider({ label, value, hint }: { label: string; value: number; hint?: string }) {
  return (
    <View style={{ marginBottom: 14 }}>
      <View style={styles.sliderTop}>
        <Text style={styles.sliderLabel}>{label}</Text>
        <Text style={styles.sliderPct}>{Math.round(value * 100)}%</Text>
      </View>
      {hint ? <Text style={styles.sliderHint}>{hint}</Text> : null}
      <View style={styles.track}>
        <View style={[styles.fill, { width: `${Math.round(value * 100)}%` }]} />
        <View style={[styles.knob, { left: `${Math.round(value * 100) - 2}%` }]} />
      </View>
    </View>
  );
}

function ChoiceRow({
  title,
  subtitle,
  active,
}: {
  title: string;
  subtitle: string;
  active?: boolean;
}) {
  return (
    <View style={[styles.choiceRow, active ? styles.choiceRowActive : undefined]}>
      <View style={styles.choiceIcon}>
        <Ionicons name="volume-medium-outline" size={18} color={VirtuoColors.text} />
      </View>
      <View style={{ flex: 1 }}>
        <Text style={styles.choiceTitle}>{title}</Text>
        <Text style={styles.choiceSub}>{subtitle}</Text>
      </View>
      {active ? <Ionicons name="checkmark" size={18} color={VirtuoColors.cyan} /> : null}
    </View>
  );
}

export default function AiConfigScreen() {
  const params = useLocalSearchParams<{ tab?: string }>();
  const segments: Segment<TabKey>[] = useMemo(
    () => [
      { key: 'aiModel', label: 'AI Model' },
      { key: 'visual', label: 'Visual' },
      { key: 'voice', label: 'Voice' },
      { key: 'neural', label: 'Neural' },
    ],
    []
  );

  const initialTab: TabKey =
    params.tab === 'visual' || params.tab === 'voice' || params.tab === 'neural' || params.tab === 'aiModel'
      ? (params.tab as TabKey)
      : 'aiModel';
  const [tab, setTab] = useState<TabKey>(initialTab);
  const [empathy, setEmpathy] = useState(0.75);
  const [direct, setDirect] = useState(0.6);
  const [enthusiasm, setEnthusiasm] = useState(0.8);

  return (
    <GradientScreen>
      <TopBar
        title="AI Configuration"
        right={
          <Pressable style={styles.save} onPress={() => router.back()}>
            <Text style={styles.saveText}>Save</Text>
          </Pressable>
        }
      />

      <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
        <VCard style={{ padding: 16 }}>
          <View style={styles.heroRow}>
            <View style={styles.heroIcon}>
              <Ionicons name="flash" size={22} color={VirtuoColors.text} />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.heroTitle}>AI Neural Coach</Text>
              <Text style={styles.heroSub}>VIRTUOMATE v3.0 Neural Engine</Text>
              <View style={styles.pillsRow}>
                <View style={[styles.pill, { borderColor: 'rgba(59,231,255,0.35)' }]}>
                  <Text style={[styles.pillText, { color: VirtuoColors.cyan }]}>Processing</Text>
                  <Text style={styles.pillText2}>Fast</Text>
                </View>
                <View style={styles.pill}>
                  <Text style={[styles.pillText, { color: VirtuoColors.textMuted }]}>Memory</Text>
                  <Text style={styles.pillText2}>Active</Text>
                </View>
                <View style={styles.pill}>
                  <Text style={[styles.pillText, { color: VirtuoColors.green }]}>Learning</Text>
                  <Text style={styles.pillText2}>On</Text>
                </View>
              </View>
            </View>
          </View>

          <View style={{ height: 14 }} />
          <VButton
            title="Start Conversation with AI Coach"
            iconLeft={<Ionicons name="chatbubble-ellipses-outline" size={18} color="#0B0720" />}
            onPress={() => router.push('/ai/session')}
          />
          <Text style={styles.helper}>Test your avatar configuration in live conversation mode</Text>

          <View style={{ height: 14 }} />
          <Segmented value={tab} onChange={setTab} segments={segments} />
        </VCard>

        <View style={{ height: 14 }} />
        {tab === 'aiModel' ? (
          <VCard style={{ padding: 16 }}>
            <Text style={styles.sectionTitle}>AI Model</Text>
            <Text style={styles.sectionSub}>
              Select your coaching engine mode for different interaction styles.
            </Text>
            <View style={{ height: 10 }} />
            <VButton title="Neural Coach Mode" variant="ghost" onPress={() => {}} />
            <View style={{ height: 10 }} />
            <VButton title="Visual Avatar Mode" variant="ghost" onPress={() => setTab('visual')} />
            <View style={{ height: 10 }} />
            <VButton title="Voice Coaching Mode" variant="ghost" onPress={() => setTab('voice')} />
          </VCard>
        ) : null}

        {tab === 'visual' ? (
          <VCard style={{ padding: 16 }}>
            <Text style={styles.sectionTitle}>Upload Custom Avatar</Text>
            <Text style={styles.sectionSub}>Create your avatar from a photo</Text>
            <View style={{ height: 12 }} />

            <View style={styles.uploadRow}>
              <View style={styles.thumb} />
              <View style={{ flex: 1 }}>
                <Text style={styles.choiceTitle}>Custom Avatar Loaded</Text>
                <Text style={styles.choiceSub}>AI-enhanced processing active</Text>
              </View>
              <Ionicons name="close" size={18} color={VirtuoColors.red} />
            </View>

            <View style={styles.note}>
              <Ionicons name="sparkles-outline" size={16} color={VirtuoColors.textMuted} />
              <Text style={styles.noteText}>
                AI will process your photo to create a personalized holographic avatar representation
              </Text>
            </View>

            <View style={{ height: 14 }} />
            <Text style={styles.sectionTitle}>Avatar Skin Tone</Text>
            <View style={styles.dotsRow}>
              {['#F8D7B5', '#E7B38C', '#C88E67', '#8B5C3C', '#5A3A26'].map((c, i) => (
                <View key={i} style={[styles.dot, { backgroundColor: c }, i === 0 ? styles.dotActive : undefined]} />
              ))}
            </View>

            <View style={{ height: 12 }} />
            <Text style={styles.sectionTitle}>Hair Style</Text>
            <View style={styles.grid2}>
              {['Short', 'Medium', 'Long', 'Bald', 'Curly'].map((t) => (
                <Pressable key={t} style={[styles.tag, t === 'Short' ? styles.tagActive : undefined]}>
                  <Text style={[styles.tagText, t === 'Short' ? styles.tagTextActive : undefined]}>{t}</Text>
                </Pressable>
              ))}
            </View>

            <View style={{ height: 12 }} />
            <Text style={styles.sectionTitle}>Attire</Text>
            <View style={styles.grid2}>
              {['Professional', 'Casual', 'Formal', 'Creative'].map((t) => (
                <Pressable key={t} style={[styles.tag, t === 'Professional' ? styles.tagActive : undefined]}>
                  <Text
                    style={[
                      styles.tagText,
                      t === 'Professional' ? styles.tagTextActive : undefined,
                    ]}>
                    {t}
                  </Text>
                </Pressable>
              ))}
            </View>
          </VCard>
        ) : null}

        {tab === 'voice' ? (
          <VCard style={{ padding: 16 }}>
            <Text style={styles.sectionTitle}>Voice Synthesis Engine</Text>
            <Text style={styles.sectionSub}>Select voice profile for your AI coach</Text>
            <View style={{ height: 12 }} />

            <ChoiceRow title="Alex" subtitle="Neutral • American" active />
            <View style={{ height: 10 }} />
            <ChoiceRow title="Sarah" subtitle="Female • British" />
            <View style={{ height: 10 }} />
            <ChoiceRow title="Marcus" subtitle="Male • Australian" />
            <View style={{ height: 10 }} />
            <ChoiceRow title="Emma" subtitle="Female • Canadian" />
          </VCard>
        ) : null}

        {tab === 'neural' ? (
          <VCard style={{ padding: 16 }}>
            <Text style={styles.sectionTitle}>Neural Behavior Configuration</Text>
            <Text style={styles.sectionSub}>
              Adjust AI personality parameters to customize coaching style
            </Text>
            <View style={{ height: 12 }} />

            <FauxSlider
              label="Empathy Protocol"
              value={empathy}
              hint="Understanding and emotional support level in interactions"
            />
            <FauxSlider
              label="Directness Algorithm"
              value={direct}
              hint="Straightforwardness of feedback delivery"
            />
            <FauxSlider
              label="Enthusiasm Matrix"
              value={enthusiasm}
              hint="Energy and motivational intensity levels"
            />

            <View style={{ height: 4 }} />
            <View style={styles.rowBtns}>
              <VButton title="Low" variant="outline" style={{ flex: 1 }} onPress={() => setEmpathy(0.4)} />
              <View style={{ width: 10 }} />
              <VButton title="Balanced" variant="outline" style={{ flex: 1 }} onPress={() => setEmpathy(0.7)} />
              <View style={{ width: 10 }} />
              <VButton title="High" variant="outline" style={{ flex: 1 }} onPress={() => setEmpathy(0.9)} />
            </View>
          </VCard>
        ) : null}

        <View style={{ height: 18 }} />
      </ScrollView>
    </GradientScreen>
  );
}

const styles = StyleSheet.create({
  container: { paddingHorizontal: VirtuoSpacing.lg, paddingBottom: 24 },
  save: {
    paddingHorizontal: 12,
    height: 30,
    borderRadius: 999,
    backgroundColor: 'rgba(59,231,255,0.18)',
    borderWidth: 1,
    borderColor: 'rgba(59,231,255,0.24)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  saveText: { color: VirtuoColors.text, fontWeight: '900', fontSize: 12 },
  heroRow: { flexDirection: 'row', gap: 14, alignItems: 'center' },
  heroIcon: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  heroTitle: { color: VirtuoColors.text, fontSize: 16, fontWeight: '900' },
  heroSub: { color: VirtuoColors.cyan, fontSize: 11, marginTop: 3, fontWeight: '800' },
  pillsRow: { flexDirection: 'row', gap: 8, marginTop: 10, flexWrap: 'wrap' },
  pill: {
    borderRadius: 12,
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    paddingHorizontal: 10,
    paddingVertical: 6,
    backgroundColor: 'rgba(255,255,255,0.04)',
  },
  pillText: { fontSize: 10, fontWeight: '900' },
  pillText2: { fontSize: 10, color: VirtuoColors.textMuted, fontWeight: '800', marginTop: 2 },
  helper: { color: VirtuoColors.textFaint, fontSize: 11, marginTop: 10, textAlign: 'center' },
  sectionTitle: { color: VirtuoColors.text, fontSize: 13, fontWeight: '900' },
  sectionSub: { color: VirtuoColors.textMuted, fontSize: 11, marginTop: 6 },

  uploadRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    padding: 12,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(59,231,255,0.08)',
    borderWidth: 1,
    borderColor: 'rgba(59,231,255,0.18)',
  },
  thumb: {
    width: 44,
    height: 44,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.08)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
  },
  note: {
    flexDirection: 'row',
    gap: 10,
    alignItems: 'center',
    padding: 12,
    marginTop: 10,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
  },
  noteText: { flex: 1, color: VirtuoColors.textMuted, fontSize: 11, lineHeight: 16 },
  dotsRow: { flexDirection: 'row', gap: 12, marginTop: 10, marginBottom: 2 },
  dot: { width: 28, height: 28, borderRadius: 14, borderWidth: 1, borderColor: 'rgba(255,255,255,0.16)' },
  dotActive: { borderColor: VirtuoColors.cyan, borderWidth: 2 },
  grid2: { flexDirection: 'row', flexWrap: 'wrap', gap: 10, marginTop: 10 },
  tag: {
    minWidth: '30%',
    flexGrow: 1,
    height: 38,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 12,
  },
  tagActive: { backgroundColor: 'rgba(139,92,255,0.35)', borderColor: 'rgba(255,255,255,0.18)' },
  tagText: { color: VirtuoColors.textMuted, fontWeight: '800', fontSize: 12 },
  tagTextActive: { color: VirtuoColors.text },

  choiceRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    padding: 14,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
  },
  choiceRowActive: { borderColor: 'rgba(59,231,255,0.26)', backgroundColor: 'rgba(59,231,255,0.06)' },
  choiceIcon: {
    width: 34,
    height: 34,
    borderRadius: 17,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  choiceTitle: { color: VirtuoColors.text, fontWeight: '900' },
  choiceSub: { color: VirtuoColors.textMuted, fontSize: 11, marginTop: 3 },

  sliderTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  sliderLabel: { color: VirtuoColors.text, fontWeight: '900', fontSize: 12 },
  sliderPct: { color: VirtuoColors.textMuted, fontSize: 12, fontWeight: '800' },
  sliderHint: { color: VirtuoColors.textMuted, fontSize: 11, marginTop: 6, marginBottom: 10 },
  track: {
    height: 10,
    borderRadius: 999,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    overflow: 'hidden',
  },
  fill: { height: '100%', backgroundColor: VirtuoColors.purple },
  knob: {
    position: 'absolute',
    top: -6,
    width: 22,
    height: 22,
    borderRadius: 11,
    backgroundColor: 'rgba(255,255,255,0.18)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.25)',
  },
  rowBtns: { flexDirection: 'row', marginTop: 10 },
});

