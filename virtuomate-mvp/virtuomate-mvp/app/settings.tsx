import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import React from 'react';
import { Pressable, ScrollView, StyleSheet, Switch, Text, View } from 'react-native';

import { GradientScreen } from '@/components/ui/gradient-screen';
import { TopBar } from '@/components/ui/top-bar';
import { VButton } from '@/components/ui/v-button';
import { VCard } from '@/components/ui/v-card';
import { VTextInput } from '@/components/ui/v-text-input';
import { VirtuoColors, VirtuoRadii, VirtuoSpacing } from '@/constants/virtuomate-theme';

function RowItem({
  title,
  icon,
  onPress,
}: {
  title: string;
  icon: keyof typeof Ionicons.glyphMap;
  onPress?: () => void;
}) {
  return (
    <Pressable style={styles.rowItem} onPress={onPress}>
      <View style={styles.rowLeft}>
        <Ionicons name={icon} size={16} color={VirtuoColors.textMuted} />
        <Text style={styles.rowText}>{title}</Text>
      </View>
      <Ionicons name="chevron-forward" size={16} color={VirtuoColors.textFaint} />
    </Pressable>
  );
}

export default function SettingsScreen() {
  return (
    <GradientScreen>
      <TopBar title="User Configuration" />
      <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
        <Text style={styles.sub}>Manage your neural interface preferences</Text>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16 }}>
          <View style={styles.profileRow}>
            <View style={styles.avatar} />
            <View style={{ flex: 1 }}>
              <Text style={styles.name}>Shahab Ahmad</Text>
              <Text style={styles.email}>mianshahab77777@email.com</Text>
              <View style={{ height: 10 }} />
              <VButton title="Change Photo" variant="outline" onPress={() => {}} />
            </View>
          </View>

          <View style={{ height: 12 }} />
          <View style={styles.planRow}>
            <View style={styles.planLeft}>
              <Ionicons name="ribbon-outline" size={16} color={VirtuoColors.textMuted} />
              <View>
                <Text style={styles.planTitle}>Free Plan</Text>
                <Text style={styles.planSub}>5 sessions remaining</Text>
              </View>
            </View>
            <VButton title="Upgrade" onPress={() => {}} />
          </View>
        </VCard>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16 }}>
          <Text style={styles.section}>Personal Information</Text>
          <View style={{ height: 12 }} />

          <Text style={styles.label}>Full Name</Text>
          <VTextInput value="Shahab Ahmad" editable={false} />
          <View style={{ height: 12 }} />

          <Text style={styles.label}>Email Address</Text>
          <VTextInput value="mianshahab77777@email.com" editable={false} />
          <View style={{ height: 12 }} />

          <Text style={styles.label}>Phone Number</Text>
          <VTextInput value="+1 234 567 8900" editable={false} />
          <View style={{ height: 14 }} />
          <VButton title="Save Changes" onPress={() => {}} />
        </VCard>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16 }}>
          <Text style={styles.section}>Notifications</Text>
          <View style={{ height: 10 }} />
          {[
            { title: 'Email Notifications', sub: 'Receive updates via email', on: true },
            { title: 'Push Notifications', sub: 'Get notified on your device', on: true },
            { title: 'Session Reminders', sub: 'Remind me to practice', on: true },
            { title: 'Achievement Alerts', sub: 'Notify when I earn badges', on: false },
          ].map((x) => (
            <View key={x.title} style={styles.toggleRow}>
              <View style={{ flex: 1 }}>
                <Text style={styles.toggleTitle}>{x.title}</Text>
                <Text style={styles.toggleSub}>{x.sub}</Text>
              </View>
              <Switch value={x.on} onValueChange={() => {}} trackColor={{ false: '#2A2A3A', true: '#2D7BFF' }} />
            </View>
          ))}
        </VCard>

        <View style={{ height: 14 }} />
        <VCard style={{ padding: 16 }}>
          <Text style={styles.section}>Security & Privacy</Text>
          <View style={{ height: 10 }} />
          <RowItem title="Change Password" icon="lock-closed-outline" />
          <View style={{ height: 10 }} />
          <RowItem title="Privacy Settings" icon="shield-checkmark-outline" />
          <View style={{ height: 10 }} />
          <RowItem
            title="Payment Methods"
            icon="card-outline"
            onPress={() => router.push('/subscription/payment')}
          />
        </VCard>

        <View style={{ height: 14 }} />
        <VButton title="Download My Data" variant="outline" onPress={() => {}} />
        <View style={{ height: 10 }} />
        <VButton title="Sign Out" variant="outline" onPress={() => {}} style={styles.dangerBtn} />
        <Text style={styles.delete}>Delete Account</Text>

        <View style={{ height: 18 }} />
      </ScrollView>
    </GradientScreen>
  );
}

const styles = StyleSheet.create({
  container: { paddingHorizontal: VirtuoSpacing.lg, paddingBottom: 26 },
  sub: { color: VirtuoColors.textMuted, fontSize: 12, marginTop: 2 },
  profileRow: { flexDirection: 'row', gap: 14, alignItems: 'center' },
  avatar: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: 'rgba(255,255,255,0.08)',
    borderWidth: 2,
    borderColor: 'rgba(59,231,255,0.25)',
  },
  name: { color: VirtuoColors.text, fontWeight: '900', fontSize: 14 },
  email: { color: VirtuoColors.cyan, fontWeight: '800', fontSize: 11, marginTop: 4 },
  planRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 12,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
  },
  planLeft: { flexDirection: 'row', gap: 10, alignItems: 'center' },
  planTitle: { color: VirtuoColors.text, fontWeight: '900', fontSize: 12 },
  planSub: { color: VirtuoColors.textMuted, fontWeight: '700', fontSize: 11, marginTop: 2 },
  section: { color: VirtuoColors.text, fontWeight: '900', fontSize: 13 },
  label: { color: VirtuoColors.textMuted, fontSize: 12, marginBottom: 8, fontWeight: '700' },
  toggleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255,255,255,0.06)',
  },
  toggleTitle: { color: VirtuoColors.text, fontWeight: '900', fontSize: 12 },
  toggleSub: { color: VirtuoColors.textMuted, fontWeight: '700', fontSize: 11, marginTop: 4 },
  rowItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 12,
    borderRadius: VirtuoRadii.lg,
    backgroundColor: 'rgba(255,255,255,0.04)',
    borderWidth: 1,
    borderColor: VirtuoColors.stroke,
  },
  rowLeft: { flexDirection: 'row', gap: 10, alignItems: 'center' },
  rowText: { color: VirtuoColors.text, fontWeight: '800', fontSize: 12 },
  dangerBtn: { borderColor: 'rgba(255,92,124,0.30)' },
  delete: { marginTop: 10, color: VirtuoColors.textFaint, fontSize: 11, fontWeight: '800', textAlign: 'center' },
});

