import { Ionicons } from '@expo/vector-icons';
import React from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';

import { GradientScreen } from '@/components/ui/gradient-screen';
import { TopBar } from '@/components/ui/top-bar';
import { VCard } from '@/components/ui/v-card';
import { VirtuoColors, VirtuoRadii, VirtuoSpacing } from '@/constants/virtuomate-theme';

function ExportRow({ title, subtitle, active }: { title: string; subtitle: string; active?: boolean }) {
  return (
    <View style={[styles.exportRow, active ? styles.exportActive : undefined]}>
      <View style={styles.exportIcon}>
        <Ionicons name="videocam-outline" size={16} color={VirtuoColors.textMuted} />
      </View>
      <View style={{ flex: 1 }}>
        <Text style={styles.exportTitle}>{title}</Text>
        <Text style={styles.exportSub}>{subtitle}</Text>
      </View>
      <View style={[styles.radio, active ? styles.radioOn : undefined]} />
    </View>
  );
}

export default function VideoCvPreviewScreen() {
  return (
    <GradientScreen>
      <TopBar title="Video CV Preview" right={<Ionicons name="pencil" size={18} color={VirtuoColors.text} />} />
      <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
        <VCard style={{ padding: 12 }}>
          <View style={styles.videoBox}>
            <View style={styles.play}>
              <Ionicons name="play" size={22} color={VirtuoColors.text} />
            </View>
          </View>
          <View style={styles.timeline}>
            <View style={styles.timelineFill} />
          </View>
          <View style={styles.timeRow}>
            <Text style={styles.time}>0:45</Text>
            <Text style={styles.time}>2:10</Text>
          </View>
        </VCard>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16 }}>
          <Text style={styles.section}>Video CV Details</Text>
          <View style={{ height: 12 }} />
          {[
            ['Created on:', 'January 4, 2026'],
            ['Duration:', '2:10 minutes'],
            ['Quality:', '1080p HD'],
            ['AI Avatar:', 'Alex (Professional)'],
          ].map(([k, v]) => (
            <View key={k} style={styles.detailRow}>
              <Text style={styles.detailKey}>{k}</Text>
              <Text style={styles.detailVal}>{v}</Text>
            </View>
          ))}
        </VCard>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16 }}>
          <Text style={styles.section}>Export Format</Text>
          <View style={{ height: 12 }} />
          <ExportRow title="MP4 Video" subtitle="12.5 MB • High" active />
          <View style={{ height: 10 }} />
          <ExportRow title="WebM Video" subtitle="8.2 MB • High" />
        </VCard>

        <View style={{ height: 18 }} />
      </ScrollView>
    </GradientScreen>
  );
}

const styles = StyleSheet.create({
  container: { paddingHorizontal: VirtuoSpacing.lg, paddingBottom: 24 },
  videoBox: {
    height: 170,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(255,255,255,0.05)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  play: {
    width: 54,
    height: 54,
    borderRadius: 27,
    backgroundColor: 'rgba(139,92,255,0.32)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.18)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  timeline: {
    height: 6,
    borderRadius: 999,
    backgroundColor: 'rgba(255,255,255,0.08)',
    overflow: 'hidden',
    marginTop: 12,
  },
  timelineFill: { width: '35%', height: '100%', backgroundColor: VirtuoColors.purple },
  timeRow: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 8 },
  time: { color: VirtuoColors.textFaint, fontSize: 11, fontWeight: '800' },
  section: { color: VirtuoColors.text, fontWeight: '900', fontSize: 13 },
  detailRow: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 10 },
  detailKey: { color: VirtuoColors.textMuted, fontWeight: '800', fontSize: 12 },
  detailVal: { color: VirtuoColors.text, fontWeight: '900', fontSize: 12 },
  exportRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    padding: 14,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
  },
  exportActive: { borderColor: 'rgba(59,231,255,0.22)', backgroundColor: 'rgba(59,231,255,0.06)' },
  exportIcon: {
    width: 34,
    height: 34,
    borderRadius: 17,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  exportTitle: { color: VirtuoColors.text, fontWeight: '900', fontSize: 12 },
  exportSub: { color: VirtuoColors.textMuted, fontWeight: '700', fontSize: 11, marginTop: 4 },
  radio: {
    width: 14,
    height: 14,
    borderRadius: 7,
    borderWidth: 2,
    borderColor: 'rgba(255,255,255,0.20)',
  },
  radioOn: { borderColor: VirtuoColors.cyan, backgroundColor: 'rgba(59,231,255,0.25)' },
});

