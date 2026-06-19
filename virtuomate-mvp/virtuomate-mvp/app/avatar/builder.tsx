import React from 'react';

import AiConfigScreen from '@/app/ai/config';

export default function AvatarBuilderRoute() {
  // Reuse the config screen; default starts on AI Model, user can switch to Visual.
  // This route exists for navigation parity with your SDS + screenshots.
  return <AiConfigScreen />;
}

