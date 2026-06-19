import React from 'react';
import { StyleSheet, TextInput, type TextInputProps, View } from 'react-native';

import { VirtuoColors, VirtuoRadii } from '@/constants/virtuomate-theme';

export function VTextInput(props: TextInputProps) {
  return (
    <View style={styles.wrap}>
      <TextInput
        placeholderTextColor={VirtuoColors.textFaint}
        style={styles.input}
        {...props}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    height: 44,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(255,255,255,0.05)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    paddingHorizontal: 14,
    justifyContent: 'center',
  },
  input: {
    color: VirtuoColors.text,
    fontSize: 14,
  },
});

