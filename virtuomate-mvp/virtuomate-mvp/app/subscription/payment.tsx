import { Ionicons } from '@expo/vector-icons';
import React from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';

import { GradientScreen } from '@/components/ui/gradient-screen';
import { TopBar } from '@/components/ui/top-bar';
import { VButton } from '@/components/ui/v-button';
import { VCard } from '@/components/ui/v-card';
import { VirtuoColors, VirtuoRadii, VirtuoSpacing } from '@/constants/virtuomate-theme';

export default function PaymentScreen() {
  return (
    <GradientScreen>
      <TopBar title="Payment Methods" />
      <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
        <Text style={styles.sub}>
          Subscription & payment processing (UI stub to match SDS “subscription handling / payment gateway”).
        </Text>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16 }}>
          <Text style={styles.section}>Saved methods</Text>
          <View style={{ height: 12 }} />

          <View style={styles.method}>
            <View style={styles.methodIcon}>
              <Ionicons name="card-outline" size={18} color={VirtuoColors.text} />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.methodTitle}>Visa •••• 4242</Text>
              <Text style={styles.methodSub}>Default • Expires 10/28</Text>
            </View>
            <Ionicons name="checkmark" size={18} color={VirtuoColors.cyan} />
          </View>

          <View style={{ height: 10 }} />
          <View style={styles.method}>
            <View style={styles.methodIcon}>
              <Ionicons name="logo-paypal" size={18} color={VirtuoColors.text} />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.methodTitle}>PayPal</Text>
              <Text style={styles.methodSub}>Not connected</Text>
            </View>
          </View>

          <View style={{ height: 14 }} />
          <VButton title="Add Payment Method" iconLeft={<Ionicons name="add" size={18} color="#0B0720" />} onPress={() => {}} />
        </VCard>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16 }}>
          <Text style={styles.section}>Billing</Text>
          <View style={{ height: 10 }} />
          {[
            ['Plan', 'Premium Neural Access'],
            ['Billing cycle', 'Annual'],
            ['Next payment', 'Jan 4, 2027'],
          ].map(([k, v]) => (
            <View key={k} style={styles.detailRow}>
              <Text style={styles.detailKey}>{k}</Text>
              <Text style={styles.detailVal}>{v}</Text>
            </View>
          ))}
        </VCard>

        <View style={{ height: 18 }} />
      </ScrollView>
    </GradientScreen>
  );
}

const styles = StyleSheet.create({
  container: { paddingHorizontal: VirtuoSpacing.lg, paddingBottom: 24 },
  sub: { color: VirtuoColors.textMuted, fontSize: 12, marginTop: 2 },
  section: { color: VirtuoColors.text, fontWeight: '900', fontSize: 13 },
  method: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    padding: 14,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
  },
  methodIcon: {
    width: 36,
    height: 36,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
    alignItems: 'center',
    justifyContent: 'center',
  },
  methodTitle: { color: VirtuoColors.text, fontWeight: '900', fontSize: 12 },
  methodSub: { color: VirtuoColors.textMuted, fontWeight: '700', fontSize: 11, marginTop: 4 },
  detailRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255,255,255,0.06)',
  },
  detailKey: { color: VirtuoColors.textMuted, fontWeight: '800', fontSize: 12 },
  detailVal: { color: VirtuoColors.text, fontWeight: '900', fontSize: 12 },
});

