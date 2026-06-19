import { LinearGradient } from 'expo-linear-gradient';
import React, { type ReactNode } from 'react';
import { Platform, StyleSheet, View } from 'react-native';

import { VirtuoColors } from '@/constants/virtuomate-theme';

export function GradientScreen({ children }: { children: ReactNode }) {
  return (
    <View style={styles.root}>
      <LinearGradient
        colors={[VirtuoColors.bg0, VirtuoColors.bg1, '#1B0B3A']}
        locations={[0, 0.55, 1]}
        style={StyleSheet.absoluteFill}
      />
      <View style={styles.gridOverlay} pointerEvents="none" />
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: VirtuoColors.bg0 },
  gridOverlay: {
    ...StyleSheet.absoluteFillObject,
    opacity: 0.18,
    ...(Platform.select({
      web: {
        backgroundImage:
          'linear-gradient(rgba(255,255,255,0.08) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.08) 1px, transparent 1px)',
        backgroundSize: '44px 44px',
      },
      default: {
        // On native we keep a subtle overlay without heavy drawing.
        backgroundColor: 'rgba(255,255,255,0.03)',
      },
    }) as object),
  },
});

