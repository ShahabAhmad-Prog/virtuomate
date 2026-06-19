import React from 'react';
import { Pressable, StyleSheet, Text, type PressableProps, View } from 'react-native';

import { VirtuoColors, VirtuoRadii } from '@/constants/virtuomate-theme';

type Props = PressableProps & {
  title: string;
  iconLeft?: React.ReactNode;
  variant?: 'primary' | 'ghost' | 'outline';
};

export function VButton({ title, iconLeft, variant = 'primary', style, ...rest }: Props) {
  return (
    <Pressable
      accessibilityRole="button"
      style={({ pressed }) => [
        styles.base,
        variant === 'primary' ? styles.primary : undefined,
        variant === 'ghost' ? styles.ghost : undefined,
        variant === 'outline' ? styles.outline : undefined,
        pressed ? { opacity: 0.88, transform: [{ scale: 0.99 }] } : undefined,
        style as any,
      ]}
      {...rest}>
      {iconLeft ? <View style={styles.iconLeft}>{iconLeft}</View> : null}
      <Text style={[styles.text, variant !== 'primary' ? styles.textGhost : undefined]}>{title}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  base: {
    height: 48,
    borderRadius: VirtuoRadii.lg,
    paddingHorizontal: 16,
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
    gap: 10,
  },
  primary: {
    backgroundColor: VirtuoColors.purple,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.20)',
  },
  ghost: {
    backgroundColor: 'rgba(255,255,255,0.06)',
  },
  outline: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke2,
  },
  text: { color: '#0B0720', fontWeight: '800' },
  textGhost: { color: VirtuoColors.text, fontWeight: '700' },
  iconLeft: { marginRight: 2 },
});

