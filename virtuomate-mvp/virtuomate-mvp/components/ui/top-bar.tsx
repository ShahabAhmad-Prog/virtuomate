import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import React from 'react';
import { Pressable, StyleSheet, Text, View, type ViewProps } from 'react-native';

import { VirtuoColors, VirtuoSpacing } from '@/constants/virtuomate-theme';

export function TopBar({
  title,
  right,
  onBack,
  style,
}: {
  title?: string;
  right?: React.ReactNode;
  onBack?: () => void;
  style?: ViewProps['style'];
}) {
  return (
    <View style={[styles.row, style]}>
      <Pressable style={styles.back} onPress={onBack ?? (() => router.back())}>
        <Ionicons name="chevron-back" size={18} color={VirtuoColors.text} />
        <Text style={styles.backText}>Back</Text>
      </Pressable>
      <View style={{ flex: 1 }} />
      {title ? <Text style={styles.title}>{title}</Text> : null}
      <View style={{ flex: 1 }} />
      <View style={styles.right}>{right}</View>
    </View>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: VirtuoSpacing.lg,
    paddingTop: 50,
    paddingBottom: 10,
  },
  back: { flexDirection: 'row', alignItems: 'center', gap: 6, width: 70 },
  backText: { color: VirtuoColors.textMuted, fontWeight: '700', fontSize: 12 },
  title: { color: VirtuoColors.text, fontWeight: '900', fontSize: 14 },
  right: { width: 70, alignItems: 'flex-end' },
});

