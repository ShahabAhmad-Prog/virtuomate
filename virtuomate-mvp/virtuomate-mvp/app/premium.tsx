import { Ionicons } from '@expo/vector-icons';
import React from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';

import { GradientScreen } from '@/components/ui/gradient-screen';
import { TopBar } from '@/components/ui/top-bar';
import { VButton } from '@/components/ui/v-button';
import { VCard } from '@/components/ui/v-card';
import { VirtuoColors, VirtuoRadii, VirtuoSpacing } from '@/constants/virtuomate-theme';

function PriceCard({
  title,
  price,
  suffix,
  highlight,
}: {
  title: string;
  price: string;
  suffix: string;
  highlight?: string;
}) {
  return (
    <VCard style={[styles.priceCard, highlight ? styles.priceCardHi : undefined]}>
      <View style={styles.priceTop}>
        <Text style={styles.priceTitle}>{title}</Text>
        {highlight ? (
          <View style={styles.badge}>
            <Text style={styles.badgeText}>{highlight}</Text>
          </View>
        ) : null}
      </View>
      <View style={{ flexDirection: 'row', alignItems: 'flex-end', gap: 6, marginTop: 10 }}>
        <Text style={styles.priceAmt}>{price}</Text>
        <Text style={styles.priceSuffix}>{suffix}</Text>
      </View>
      <View style={{ height: 12 }} />
      <VButton title="Select" variant={highlight ? 'primary' : 'outline'} onPress={() => {}} />
    </VCard>
  );
}

export default function PremiumScreen() {
  return (
    <GradientScreen>
      <TopBar title="Upgrade Neural Access" />
      <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
        <Text style={styles.sub}>Unlock unlimited AI potential</Text>

        <View style={{ height: 14 }} />
        <PriceCard title="Monthly" price="$29" suffix="per month" />
        <View style={{ height: 12 }} />
        <PriceCard title="Annual" price="$249" suffix="per year" highlight="Most Popular" />
        <View style={{ height: 12 }} />
        <PriceCard title="Lifetime" price="$499" suffix="one-time" />

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16 }}>
          <Text style={styles.section}>Neural Features Comparison</Text>

          <View style={{ height: 10 }} />
          <Text style={styles.tier}>Basic Access</Text>
          {['5 coaching sessions per month', 'Basic avatar customization', 'Standard feedback', 'Community support'].map((t) => (
            <View key={t} style={styles.bulletRow}>
              <Ionicons name="checkmark" size={14} color={VirtuoColors.textMuted} />
              <Text style={styles.bullet}>{t}</Text>
            </View>
          ))}

          <View style={{ height: 12 }} />
          <View style={styles.premiumBox}>
            <Text style={styles.tierPremium}>Premium Neural Access</Text>
            {[
              'Unlimited coaching sessions',
              'Advanced avatar customization',
              'AI-powered detailed feedback',
              'Priority support 24/7',
              'Video CV creator',
              'Advanced analytics',
              'Custom role-play scenarios',
              'Export all session recordings',
              'Personalized learning path',
              'Certificate of completion',
            ].map((t) => (
              <View key={t} style={styles.bulletRow}>
                <Ionicons name="checkmark" size={14} color={VirtuoColors.cyan} />
                <Text style={[styles.bullet, { color: VirtuoColors.text }]}>{t}</Text>
              </View>
            ))}
          </View>
        </VCard>

        <View style={{ height: 14 }} />
        <VCard style={styles.guarantee}>
          <Text style={styles.guaranteeText}>30-Day Money Back Guarantee</Text>
          <Text style={styles.guaranteeSub}>Try premium risk-free. Full refund if you&apos;re not satisfied.</Text>
        </VCard>

        <View style={{ height: 18 }} />
      </ScrollView>
    </GradientScreen>
  );
}

const styles = StyleSheet.create({
  container: { paddingHorizontal: VirtuoSpacing.lg, paddingBottom: 24 },
  sub: { color: VirtuoColors.textMuted, fontSize: 12, marginTop: 2 },
  priceCard: { padding: 16 },
  priceCardHi: { borderColor: 'rgba(59,231,255,0.22)', backgroundColor: 'rgba(59,231,255,0.06)' },
  priceTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  priceTitle: { color: VirtuoColors.text, fontWeight: '900', fontSize: 14 },
  priceAmt: { color: VirtuoColors.cyan, fontWeight: '900', fontSize: 28 },
  priceSuffix: { color: VirtuoColors.textMuted, fontWeight: '800', fontSize: 12, marginBottom: 4 },
  badge: {
    height: 22,
    paddingHorizontal: 10,
    borderRadius: 999,
    backgroundColor: 'rgba(139,92,255,0.35)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.18)',
    justifyContent: 'center',
  },
  badgeText: { color: VirtuoColors.text, fontWeight: '900', fontSize: 10 },
  section: { color: VirtuoColors.text, fontWeight: '900', fontSize: 13 },
  tier: { color: VirtuoColors.textMuted, fontWeight: '900', fontSize: 12, marginBottom: 6 },
  tierPremium: { color: VirtuoColors.text, fontWeight: '900', fontSize: 12, marginBottom: 8 },
  bulletRow: { flexDirection: 'row', gap: 10, alignItems: 'center', marginTop: 8 },
  bullet: { color: VirtuoColors.textMuted, fontSize: 12, fontWeight: '700' },
  premiumBox: {
    marginTop: 10,
    padding: 14,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(139,92,255,0.18)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.16)',
  },
  guarantee: {
    padding: 16,
    backgroundColor: 'rgba(60,255,178,0.10)',
    borderColor: 'rgba(60,255,178,0.18)',
  },
  guaranteeText: { color: VirtuoColors.green, fontWeight: '900', fontSize: 13, textAlign: 'center' },
  guaranteeSub: { color: VirtuoColors.textMuted, fontWeight: '700', fontSize: 12, textAlign: 'center', marginTop: 6 },
});

