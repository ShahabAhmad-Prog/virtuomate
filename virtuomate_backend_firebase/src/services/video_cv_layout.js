'use strict';

/** 720p Video CV canvas and centered presenter avatar layout. */
const CV_W = 1280;
const CV_H = 720;
const AVATAR_SIZE = 640;

const AVATAR_X = Math.round((CV_W - AVATAR_SIZE) / 2);
const AVATAR_Y = Math.round((CV_H - AVATAR_SIZE) / 2);

/** Lower-face strip for lip-sync (proportional to avatar size). */
const MOUTH_Y = Math.round(AVATAR_SIZE * 0.519);
const MOUTH_H = Math.round(AVATAR_SIZE * 0.267);

module.exports = {
  CV_W,
  CV_H,
  AVATAR_SIZE,
  AVATAR_X,
  AVATAR_Y,
  MOUTH_Y,
  MOUTH_H,
};
