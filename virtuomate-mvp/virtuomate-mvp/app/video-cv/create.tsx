import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import React, { useState } from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';

import { GradientScreen } from '@/components/ui/gradient-screen';
import { TopBar } from '@/components/ui/top-bar';
import { VButton } from '@/components/ui/v-button';
import { VCard } from '@/components/ui/v-card';
import { VTextInput } from '@/components/ui/v-text-input';
import { VirtuoColors, VirtuoSpacing } from '@/constants/virtuomate-theme';

export default function VideoCvCreateScreen() {
  const [fullName, setFullName] = useState('John Doe');
  const [title, setTitle] = useState('Senior Software Engineer');
  const [summary, setSummary] = useState('');
  const [email, setEmail] = useState('john@example.com');
  const [phone, setPhone] = useState('+1 234 567 8900');

  return (
    <GradientScreen>
      <TopBar
        title="AI Video CV Creator"
        right={<Text style={styles.step}>Step 1/4</Text>}
      />

      <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
        <VCard style={{ padding: 16 }}>
          <View style={styles.avatarCard}>
            <View style={styles.avatarIcon}>
              <Ionicons name="flash" size={24} color={VirtuoColors.text} />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.avatarTitle}>Your AI Avatar</Text>
              <Text style={styles.avatarSub}>Neural Presenter v3.0</Text>
            </View>
            <View style={styles.greenDot} />
          </View>

          <View style={{ height: 14 }} />
          <Text style={styles.label}>
            Full Name <Text style={{ color: VirtuoColors.red }}>*</Text>
          </Text>
          <VTextInput value={fullName} onChangeText={setFullName} />

          <View style={{ height: 12 }} />
          <Text style={styles.label}>
            Professional Title <Text style={{ color: VirtuoColors.red }}>*</Text>
          </Text>
          <VTextInput value={title} onChangeText={setTitle} />

          <View style={{ height: 12 }} />
          <Text style={styles.label}>
            Professional Summary <Text style={{ color: VirtuoColors.red }}>*</Text>
          </Text>
          <View style={styles.textArea}>
            <VTextInput
              value={summary}
              onChangeText={setSummary}
              placeholder="A brief summary of your professional background and aspirations..."
              multiline
              style={{ height: 100, textAlignVertical: 'top', paddingTop: 10 }}
            />
          </View>

          <View style={{ height: 12 }} />
          <View style={styles.twoCol}>
            <View style={{ flex: 1 }}>
              <Text style={styles.label}>Email</Text>
              <VTextInput value={email} onChangeText={setEmail} autoCapitalize="none" />
            </View>
            <View style={{ width: 10 }} />
            <View style={{ flex: 1 }}>
              <Text style={styles.label}>Phone</Text>
              <VTextInput value={phone} onChangeText={setPhone} />
            </View>
          </View>

          <View style={{ height: 14 }} />
          <VButton
            title="Continue"
            iconLeft={<Ionicons name="arrow-forward" size={18} color="#0B0720" />}
            onPress={() => router.push('/video-cv/preview')}
          />
        </VCard>

        <View style={{ height: 18 }} />
      </ScrollView>
    </GradientScreen>
  );
}

const styles = StyleSheet.create({
  container: { paddingHorizontal: VirtuoSpacing.lg, paddingBottom: 24 },
  step: { color: VirtuoColors.textMuted, fontWeight: '900', fontSize: 12 },
  avatarCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    padding: 14,
    borderRadius: 16,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
  },
  avatarIcon: {
    width: 44,
    height: 44,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.08)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  greenDot: { width: 10, height: 10, borderRadius: 5, backgroundColor: VirtuoColors.green },
  avatarTitle: { color: VirtuoColors.text, fontWeight: '900', fontSize: 13 },
  avatarSub: { color: VirtuoColors.cyan, fontWeight: '800', fontSize: 11, marginTop: 4 },
  label: { color: VirtuoColors.textMuted, fontSize: 12, marginBottom: 8, fontWeight: '700' },
  textArea: { borderRadius: 16, overflow: 'hidden' },
  twoCol: { flexDirection: 'row' },
});

