import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import React, { useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { GradientScreen } from '@/components/ui/gradient-screen';
import { VButton } from '@/components/ui/v-button';
import { VCard } from '@/components/ui/v-card';
import { VTextInput } from '@/components/ui/v-text-input';
import { VirtuoColors, VirtuoSpacing } from '@/constants/virtuomate-theme';

export default function LoginScreen() {
  const [email, setEmail] = useState('mianshahab77777@gmail.com');
  const [password, setPassword] = useState('password');

  return (
    <GradientScreen>
      <View style={styles.container}>
        <Pressable style={styles.back} onPress={() => router.back()}>
          <Ionicons name="chevron-back" size={18} color={VirtuoColors.text} />
          <Text style={styles.backText}>Back</Text>
        </Pressable>

        <View style={{ height: 10 }} />
        <View style={styles.headerRow}>
          <View style={styles.badge}>
            <Ionicons name="flash" size={18} color={VirtuoColors.text} />
          </View>
          <View style={{ marginLeft: 12 }}>
            <Text style={styles.h1}>Access Neural Interface</Text>
            <Text style={styles.h2}>Authenticate to access your AI coaching system</Text>
          </View>
        </View>

        <View style={{ height: 18 }} />
        <VCard style={{ padding: 18 }}>
          <Text style={styles.label}>Email Address</Text>
          <VTextInput value={email} onChangeText={setEmail} autoCapitalize="none" />

          <View style={{ height: 14 }} />
          <View style={styles.passRow}>
            <Text style={styles.label}>Password</Text>
            <Pressable onPress={() => {}}>
              <Text style={styles.link}>Forgot Password?</Text>
            </Pressable>
          </View>
          <VTextInput value={password} onChangeText={setPassword} secureTextEntry />

          <View style={{ height: 14 }} />
          <VButton
            title="Access System"
            iconLeft={<Ionicons name="flash" size={18} color="#0B0720" />}
            onPress={() => router.replace('/dashboard')}
          />

          <Text style={styles.or}>Or authenticate with</Text>
          <View style={styles.socialRow}>
            <VButton
              title="Google"
              variant="outline"
              style={{ flex: 1 }}
              iconLeft={<Ionicons name="logo-google" size={16} color={VirtuoColors.text} />}
              onPress={() => router.replace('/dashboard')}
            />
            <View style={{ width: 10 }} />
            <VButton
              title="Facebook"
              variant="outline"
              style={{ flex: 1 }}
              iconLeft={<Ionicons name="logo-facebook" size={16} color={VirtuoColors.text} />}
              onPress={() => router.replace('/dashboard')}
            />
          </View>
        </VCard>

        <View style={{ flex: 1 }} />
        <Pressable onPress={() => router.push('/auth/register')}>
          <Text style={styles.bottom}>
            Need access credentials? <Text style={styles.bottomLink}>Register New Account</Text>
          </Text>
        </Pressable>
      </View>
    </GradientScreen>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, paddingHorizontal: VirtuoSpacing.lg, paddingTop: 56, paddingBottom: 24 },
  back: { flexDirection: 'row', alignItems: 'center', gap: 6, alignSelf: 'flex-start' },
  backText: { color: VirtuoColors.textMuted, fontWeight: '700', fontSize: 12 },
  headerRow: { flexDirection: 'row', alignItems: 'center' },
  badge: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: 'rgba(255,255,255,0.08)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  h1: { color: VirtuoColors.text, fontSize: 18, fontWeight: '900' },
  h2: { color: VirtuoColors.textMuted, marginTop: 2, fontSize: 12 },
  label: { color: VirtuoColors.textMuted, fontSize: 12, marginBottom: 8, fontWeight: '700' },
  passRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  link: { color: VirtuoColors.cyan, fontSize: 12, fontWeight: '700' },
  or: {
    color: VirtuoColors.textFaint,
    fontSize: 11,
    textAlign: 'center',
    marginTop: 12,
    marginBottom: 10,
  },
  socialRow: { flexDirection: 'row' },
  bottom: { color: VirtuoColors.textMuted, textAlign: 'center', fontSize: 12 },
  bottomLink: { color: VirtuoColors.cyan, fontWeight: '800' },
});

