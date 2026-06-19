import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import React from 'react';
import { StyleSheet, Text, View } from 'react-native';

import { GradientScreen } from '@/components/ui/gradient-screen';
import { VButton } from '@/components/ui/v-button';
import { VCard } from '@/components/ui/v-card';
import { VirtuoColors, VirtuoSpacing } from '@/constants/virtuomate-theme';

export default function Welcome() {
  return (
    <GradientScreen>
      <View style={styles.container}>
        <View style={styles.logoWrap}>
          <View style={styles.logoCircle}>
            <Ionicons name="flash" size={34} color={VirtuoColors.text} />
          </View>
          <View style={styles.logoDot} />
        </View>

        <Text style={styles.title}>VIRTUOMATE</Text>
        <Text style={styles.subtitle}>NEURAL COACHING SYSTEM v3.0</Text>
        <Text style={styles.tagline}>
          Advanced AI-Powered Intelligence for Professional Evolution
        </Text>

        <View style={{ height: 18 }} />
        <VCard style={styles.card}>
          <VButton
            title="Neural Network Coaching"
            variant="ghost"
            iconLeft={<Ionicons name="git-network-outline" size={18} color={VirtuoColors.cyan} />}
            onPress={() => router.push('/auth/login')}
          />
          <View style={{ height: 10 }} />
          <VButton
            title="Adaptive AI Learning"
            variant="ghost"
            iconLeft={<Ionicons name="sparkles-outline" size={18} color={VirtuoColors.cyan} />}
            onPress={() => router.push('/auth/login')}
          />
          <View style={{ height: 10 }} />
          <VButton
            title="Real-time Performance Analysis"
            variant="ghost"
            iconLeft={<Ionicons name="flash-outline" size={18} color={VirtuoColors.cyan} />}
            onPress={() => router.push('/auth/login')}
          />

          <View style={{ height: 16 }} />
          <VButton
            title="Initialize System"
            iconLeft={<Ionicons name="flash" size={18} color="#0B0720" />}
            onPress={() => router.push('/auth/login')}
          />
          <Text style={styles.footerLine}>
            ALL SYSTEMS OPERATIONAL • READY FOR DEPLOYMENT
          </Text>
        </VCard>
      </View>
    </GradientScreen>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, paddingHorizontal: VirtuoSpacing.lg, paddingTop: 70 },
  logoWrap: { alignSelf: 'center', marginBottom: 16 },
  logoCircle: {
    width: 86,
    height: 86,
    borderRadius: 43,
    backgroundColor: 'rgba(255,255,255,0.08)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.14)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  logoDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: VirtuoColors.green,
    position: 'absolute',
    right: 10,
    top: 52,
  },
  title: {
    color: VirtuoColors.text,
    fontSize: 34,
    fontWeight: '900',
    letterSpacing: 2,
    textAlign: 'center',
  },
  subtitle: {
    color: VirtuoColors.cyan,
    fontSize: 12,
    fontWeight: '800',
    letterSpacing: 1.8,
    textAlign: 'center',
    marginTop: 6,
  },
  tagline: {
    color: VirtuoColors.textMuted,
    fontSize: 13,
    textAlign: 'center',
    marginTop: 10,
    lineHeight: 18,
  },
  card: { marginTop: 14, padding: 16 },
  footerLine: {
    marginTop: 12,
    color: VirtuoColors.textFaint,
    fontSize: 10,
    letterSpacing: 1.2,
    textAlign: 'center',
  },
});

