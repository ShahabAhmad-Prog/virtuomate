import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import React, { useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { GradientScreen } from '@/components/ui/gradient-screen';
import { VButton } from '@/components/ui/v-button';
import { VCard } from '@/components/ui/v-card';
import { VTextInput } from '@/components/ui/v-text-input';
import { VirtuoColors, VirtuoSpacing } from '@/constants/virtuomate-theme';

export default function RegisterScreen() {
  const [fullName, setFullName] = useState('Shahab Ahmad');
  const [email, setEmail] = useState('mianshahab77777@gmail.com');
  const [password, setPassword] = useState('password');
  const [agree, setAgree] = useState(true);

  return (
    <GradientScreen>
      <View style={styles.container}>
        <Pressable style={styles.back} onPress={() => router.back()}>
          <Ionicons name="chevron-back" size={18} color={VirtuoColors.text} />
          <Text style={styles.backText}>Back</Text>
        </Pressable>

        <View style={{ height: 16 }} />
        <Text style={styles.h1}>Initialize User Profile</Text>
        <Text style={styles.h2}>Register to begin your neural coaching journey</Text>

        <View style={{ height: 18 }} />
        <VCard style={{ padding: 18 }}>
          <Text style={styles.label}>Full Name</Text>
          <VTextInput value={fullName} onChangeText={setFullName} />

          <View style={{ height: 14 }} />
          <Text style={styles.label}>Email Address</Text>
          <VTextInput value={email} onChangeText={setEmail} autoCapitalize="none" />

          <View style={{ height: 14 }} />
          <Text style={styles.label}>Password</Text>
          <VTextInput value={password} onChangeText={setPassword} secureTextEntry />

          <View style={{ height: 12 }} />
          <Pressable style={styles.checkboxRow} onPress={() => setAgree((v) => !v)}>
            <View style={[styles.checkbox, agree ? styles.checkboxOn : undefined]}>
              {agree ? <Ionicons name="checkmark" size={14} color="#0B0720" /> : null}
            </View>
            <Text style={styles.checkboxText}>
              I agree to the <Text style={styles.link}>Terms of Service</Text> and{' '}
              <Text style={styles.link}>Privacy Policy</Text>
            </Text>
          </Pressable>

          <View style={{ height: 14 }} />
          <VButton
            title="Create Account"
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
        <Pressable onPress={() => router.replace('/auth/login')}>
          <Text style={styles.bottom}>
            Already have an account? <Text style={styles.bottomLink}>Sign In</Text>
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
  h1: { color: VirtuoColors.text, fontSize: 20, fontWeight: '900' },
  h2: { color: VirtuoColors.textMuted, marginTop: 6, fontSize: 12 },
  label: { color: VirtuoColors.textMuted, fontSize: 12, marginBottom: 8, fontWeight: '700' },
  checkboxRow: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  checkbox: {
    width: 18,
    height: 18,
    borderRadius: 5,
    borderWidth: 1,
    borderColor: VirtuoColors.stroke2,
    backgroundColor: 'transparent',
    alignItems: 'center',
    justifyContent: 'center',
  },
  checkboxOn: { backgroundColor: VirtuoColors.cyan, borderColor: 'rgba(255,255,255,0.18)' },
  checkboxText: { flex: 1, color: VirtuoColors.textMuted, fontSize: 12 },
  link: { color: VirtuoColors.cyan, fontWeight: '800' },
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

