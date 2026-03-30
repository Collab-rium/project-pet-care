FROM cirrusci/flutter:stable

ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH="$PATH:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin"

WORKDIR /app

# Install basic tools and download Android commandline tools so this container can build Android APKs
RUN apt-get update \
  && apt-get install -y --no-install-recommends unzip wget ca-certificates openjdk-17-jdk \
  && rm -rf /var/lib/apt/lists/*

# Download Android commandline tools and install selected SDK components
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
  && wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O /tmp/cmdline.zip \
  && unzip /tmp/cmdline.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
  && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
  && rm /tmp/cmdline.zip

# Install Android SDK components and accept licenses
RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} \
    "platform-tools" "platforms;android-33" "build-tools;33.0.2" || true \
  && yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses || true

# Copy pubspec and get deps first to leverage Docker cache
COPY pubspec.* ./
RUN flutter pub get

# Copy rest of the frontend
COPY . .

# Build web if present (optional). For Android builds, use: docker compose run --rm frontend flutter build apk
RUN if [ -d "web" ]; then flutter build web --release || true; fi

CMD ["bash", "-c", "echo 'Flutter + Android SDK ready. Use this container to run builds (e.g. flutter build apk) or open a shell.' && sleep infinity"]
