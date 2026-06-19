import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { VirtuoColors, VirtuoRadii } from '@/constants/virtuomate-theme';

export type Segment<T extends string> = {
  key: T;
  label: string;
};

export function Segmented<T extends string>({
  value,
  onChange,
  segments,
}: {
  value: T;
  onChange: (v: T) => void;
  segments: Segment<T>[];
}) {
  return (
    <View style={styles.wrap}>
      {segments.map((s) => {
        const active = s.key === value;
        return (
          <Pressable
            key={s.key}
            onPress={() => onChange(s.key)}
            style={[styles.item, active ? styles.activeItem : undefined]}>
            <Text style={[styles.label, active ? styles.activeLabel : undefined]}>{s.label}</Text>
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    flexDirection: 'row',
    padding: 4,
    borderRadius: VirtuoRadii.xl,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    gap: 6,
  },
  item: {
    flex: 1,
    height: 34,
    borderRadius: VirtuoRadii.xl,
    alignItems: 'center',
    justifyContent: 'center',
  },
  activeItem: {
    backgroundColor: 'rgba(139,92,255,0.45)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.18)',
  },
  label: { color: VirtuoColors.textFaint, fontWeight: '700', fontSize: 12 },
  activeLabel: { color: VirtuoColors.text },
});

