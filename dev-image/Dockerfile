FROM cirrusci/flutter:stable

LABEL maintainer="you@example.com"
LABEL description="Development image with Flutter, OpenJDK and Android SDK command-line tools for Project Pet Care"

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$PATH:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin"

RUN apt-get update \
  && apt-get install -y --no-install-recommends unzip wget ca-certificates git openjdk-17-jdk procps \
  && rm -rf /var/lib/apt/lists/*

# Install Android command-line tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
  && wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O /tmp/cmdline.zip \
  && unzip -q /tmp/cmdline.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
  && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
  && rm /tmp/cmdline.zip

# Install essential Android SDK components and accept licenses
RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} \ 
    "platform-tools" "platforms;android-33" "build-tools;33.0.2" || true \
  && yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses || true

# Pre-cache Flutter artifacts for Android to speed up first builds
RUN flutter precache --android || true

# Create a non-root user for development (UID 1000 default). Developers may override with --user when running.
RUN useradd -m -s /bin/bash dev || true

WORKDIR /workspace

# Default entrypoint: an interactive shell. Developers will mount their project directory into /workspace.
ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["bash"]
