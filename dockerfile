# Use the NVIDIA DeepStream 6.3 base image for Jetson
FROM nvcr.io/nvidia/deepstream-l4t:6.3-samples

# Set working directory
WORKDIR /app

# Ensure writable directories (temporary fixes for issues with apt)
RUN mkdir -p /var/lib/apt/lists/partial /tmp && chmod -R 777 /var/lib/apt/lists/ /tmp

# Remove problematic repositories (focal-backports and focal-security may cause issues)
RUN sed -i '/focal-backports/d' /etc/apt/sources.list && \
    sed -i '/focal-security/d' /etc/apt/sources.list

# Add NVIDIA GPG key (fetch once; no need to repeat later)
RUN apt-key adv --fetch-keys https://repo.download.nvidia.com/jetson/jetson-ota-public.asc

# Install dependencies required for building the LPR app
ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_VER=11.4

# Copy application files into the container
COPY . /app/

# Ensure necessary files are in the correct directory
COPY LPDNet_usa_pruned_tao5.engine /app/
COPY us_lprnet_baseline18_deployable.engine /app/


# Update package list and install dependencies
RUN apt-get update --allow-releaseinfo-change && apt-get install -y --no-install-recommends \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    gstreamer1.0-tools \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    libmpg123-0 \
    libvpx6 \
    libde265-0 \
    libx265-179 \
    libavcodec58 \
    libmpeg2-4 \
    libegl1-mesa \
    libgl1-mesa-glx \
    libgles2-mesa \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set executable permissions for the custom parser
RUN chmod +x /app/libnvdsinfer_custom_impl_lpr.so

# Set environment variables
ENV LD_LIBRARY_PATH=/app:/opt/nvidia/deepstream/deepstream-6.3/lib:$LD_LIBRARY_PATH
ENV DISPLAY=:0

# Set the entrypoint to run the DeepStream pipeline
ENTRYPOINT ["deepstream-app"]
CMD ["-c", "deepstream_multi_config.txt"]
