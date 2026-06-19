import React, { type ReactNode } from 'react';
import { StyleSheet, View, type ViewProps } from 'react-native';

import { VirtuoColors, VirtuoRadii } from '@/constants/virtuomate-theme';

type Props = ViewProps & {
  children: ReactNode;
};

export function VCard({ style, children, ...rest }: Props) {
  return (
    <View style={[styles.card, style]} {...rest}>
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: VirtuoColors.surface,
    borderRadius: VirtuoRadii.lg,
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    padding: 16,
  },
});

