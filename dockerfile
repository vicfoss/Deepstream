# Use the NVIDIA DeepStream 6.3 base image for Jetson
#FROM nvcr.io/nvidia/deepstream-l4t:6.3-samples
FROM dustynv/deepstream:r35.4.1

# Set working directory
WORKDIR /app
# Ensure writable directories
RUN mkdir -p /var/lib/apt/lists/partial /tmp && chmod -R 777 /var/lib/apt/lists/ /tmp

# Remove problematic repositories
RUN sed -i '/focal-backports/d' /etc/apt/sources.list && \
    sed -i '/focal-security/d' /etc/apt/sources.list

# Add NVIDIA GPG key
RUN apt-key adv --fetch-keys https://repo.download.nvidia.com/jetson/jetson-ota-public.asc

# Install dependencies required for building the LPR app
ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_VER=11.4

# Copy all files into the /app directory
COPY . /app/

#Copy the Engine files /app directory
COPY LPDNet_usa_pruned_tao5.onnx_b16_gpu0_fp32.engine /app/
COPY us_lprnet_baseline18_deployable.onnx_b1_gpu0_fp32.engine /app/

COPY sample.mp4 /app/
COPY deepstream_app_config.txt /app/
COPY LPR_label.txt /app/
COPY LPD_label.txt /app/
COPY libnvdsinfer_custom_impl_lpr.so /app/
COPY config_infer_primary.txt /app/
COPY config_infer_secondary.txt /app/

# Add NVIDIA GPG key
RUN apt-key adv --fetch-keys https://repo.download.nvidia.com/jetson/jetson-ota-public.asc

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

# Set permissions for the custom parser (if needed)
RUN chmod +x /app/libnvdsinfer_custom_impl_lpr.so

# Set environment variables
ENV LD_LIBRARY_PATH=/app:$LD_LIBRARY_PATH
ENV DISPLAY=:0

# Set the entrypoint to run the DeepStream pipeline
ENTRYPOINT ["deepstream-app"]
CMD ["-c", "deepstream_app_config.txt"]
