/*
 * Copyright (C) 2013 Square, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.squareup.picasso;

import android.app.Notification;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.widget.ImageView;
import android.widget.RemoteViews;
import java.io.IOException;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;
import org.jetbrains.annotations.TestOnly;

import static com.squareup.picasso.BitmapHunter.forRequest;
import static com.squareup.picasso.Picasso.LoadedFrom.MEMORY;
import static com.squareup.picasso.PicassoDrawable.setBitmap;
import static com.squareup.picasso.PicassoDrawable.setPlaceholder;
import static com.squareup.picasso.RemoteViewsAction.AppWidgetAction;
import static com.squareup.picasso.RemoteViewsAction.NotificationAction;
import static com.squareup.picasso.Utils.OWNER_MAIN;
import static com.squareup.picasso.Utils.VERB_CHANGED;
import static com.squareup.picasso.Utils.VERB_COMPLETED;
import static com.squareup.picasso.Utils.VERB_CREATED;
import static com.squareup.picasso.Utils.checkMain;
import static com.squareup.picasso.Utils.checkNotMain;
import static com.squareup.picasso.Utils.createKey;
import static com.squareup.picasso.Utils.isMain;
import static com.squareup.picasso.Utils.log;

/** Fluent API for building an image download request. */
@SuppressWarnings("UnusedDeclaration") // Public API.
public class RequestCreator {
  private static int nextId = 0;

  private static int getRequestId() {
    if (isMain()) {
      return nextId++;
    }

    final CountDownLatch latch = new CountDownLatch(1);
    final AtomicInteger id = new AtomicInteger();
    Picasso.HANDLER.post(new Runnable() {
      @Override public void run() {
        id.set(getRequestId());
        latch.countDown();
      }
    });
    try {
      latch.await();
    } catch (final InterruptedException e) {
      Picasso.HANDLER.post(new Runnable() {
        @Override public void run() {
          throw new RuntimeException(e);
        }
      });
    }
    return id.get();
  }

  private final Picasso picasso;
  private final Request.Builder data;

  private boolean skipMemoryCache;
  private boolean noFade;
  private boolean deferred;
  private int placeholderResId;
  private int errorResId;
  private Drawable placeholderDrawable;
  private Drawable errorDrawable;

  RequestCreator(Picasso picasso, Uri uri, int resourceId) {
    if (picasso.shutdown) {
      throw new IllegalStateException(
          "Picasso instance already shut down. Cannot submit new requests.");
    }
    this.picasso = picasso;
    this.data = new Request.Builder(uri, resourceId);
  }

  @TestOnly RequestCreator() {
    this.picasso = null;
    this.data = new Request.Builder(null, 0);
  }

  /**
   * A placeholder drawable to be used while the image is being loaded. If the requested image is
   * not immediately available in the memory cache then this resource will be set on the target
   * {@link ImageView}.
   */
  public RequestCreator placeholder(int placeholderResId) {
    if (placeholderResId == 0) {
      throw new IllegalArgumentException("Placeholder image resource invalid.");
    }
    if (placeholderDrawable != null) {
      throw new IllegalStateException("Placeholder image already set.");
    }
    this.placeholderResId = placeholderResId;
    return this;
  }

  /**
   * A placeholder drawable to be used while the image is being loaded. If the requested image is
   * not immediately available in the memory cache then this resource will be set on the target
   * {@link ImageView}.
   * <p>
   * If you are not using a placeholder image but want to clear an existing image (such as when
   * used in an {@link android.widget.Adapter adapter}), pass in {@code null}.
   */
  public RequestCreator placeholder(Drawable placeholderDrawable) {
    if (placeholderResId != 0) {
      throw new IllegalStateException("Placeholder image already set.");
    }
    this.placeholderDrawable = placeholderDrawable;
    return this;
  }

  /** An error drawable to be used if the request image could not be loaded. */
  public RequestCreator error(int errorResId) {
    if (errorResId == 0) {
      throw new IllegalArgumentException("Error image resource invalid.");
    }
    if (errorDrawable != null) {
      throw new IllegalStateException("Error image already set.");
    }
    this.errorResId = errorResId;
    return this;
  }

  /** An error drawable to be used if the request image could not be loaded. */
  public RequestCreator error(Drawable errorDrawable) {
    if (errorDrawable == null) {
      throw new IllegalArgumentException("Error