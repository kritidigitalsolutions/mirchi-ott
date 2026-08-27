// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.OptIn;
import androidx.media3.common.MediaItem;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.exoplayer.rtsp.RtspMediaSource;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.exoplayer.upstream.DefaultLoadErrorHandlingPolicy;
import androidx.media3.exoplayer.upstream.LoadErrorHandlingPolicy;

final class RtspVideoAsset extends VideoAsset {
  RtspVideoAsset(@NonNull String assetUrl) {
    super(assetUrl);
  }

  @NonNull
  @Override
  public MediaItem getMediaItem() {
    return new MediaItem.Builder().setUri(assetUrl).build();
  }

  // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
  @OptIn(markerClass = UnstableApi.class)
  @Override
  @NonNull
  public MediaSource.Factory getMediaSourceFactory(@NonNull Context context) {
    // Custom LoadErrorHandlingPolicy to avoid track exclusion crashes as suggested by Play Console
    LoadErrorHandlingPolicy loadErrorHandlingPolicy =
        new DefaultLoadErrorHandlingPolicy() {
          @Override
          @Nullable
          public LoadErrorHandlingPolicy.FallbackSelection getFallbackSelectionFor(
              @NonNull LoadErrorHandlingPolicy.FallbackOptions fallbackOptions,
              @NonNull LoadErrorHandlingPolicy.LoadErrorInfo loadErrorInfo) {
            return null;
          }
        };

    return new RtspMediaSource.Factory().setLoadErrorHandlingPolicy(loadErrorHandlingPolicy);
  }
}
