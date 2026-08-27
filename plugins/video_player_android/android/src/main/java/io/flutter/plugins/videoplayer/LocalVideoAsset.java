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
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.exoplayer.upstream.DefaultLoadErrorHandlingPolicy;
import androidx.media3.exoplayer.upstream.LoadErrorHandlingPolicy;

final class LocalVideoAsset extends VideoAsset {
  LocalVideoAsset(@NonNull String assetUrl) {
    super(assetUrl);
  }

  @NonNull
  @Override
  public MediaItem getMediaItem() {
    return new MediaItem.Builder().setUri(assetUrl).build();
  }

  @OptIn(markerClass = UnstableApi.class)
  @NonNull
  @Override
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

    return new DefaultMediaSourceFactory(context)
        .setLoadErrorHandlingPolicy(loadErrorHandlingPolicy);
  }
}
