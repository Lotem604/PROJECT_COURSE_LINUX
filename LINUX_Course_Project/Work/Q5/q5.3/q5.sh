#!/bin/bash

CONTAINER_5_2_IMAGE="../q5.2"
CONTAINER_5_3_IMAGE="."
CONTAINER_5_3_RUN="$(realpath ../q5.2)"

IMAGE_5_2="watermark-app-5.2"
IMAGE_5_3="watermark-app-5.3"

# Build Docker
echo "🔨 Building Docker image for $CONTAINER_5_2_IMAGE..."
docker build -t "$IMAGE_5_2" "$CONTAINER_5_2_IMAGE"
if [ $? -ne 0 ]; then
    echo "Failed to build $IMAGE_5_2. Exiting..."
    exit 1
fi
echo "Built $IMAGE_5_2 successfully!"

echo "🔨 Building Docker image for $CONTAINER_5_3_IMAGE..."
docker build -t "$IMAGE_5_3" "$CONTAINER_5_3_IMAGE"
if [ $? -ne 0 ]; then
    echo "Failed to build $IMAGE_5_3. Exiting..."
    exit 1
fi
echo "Built $IMAGE_5_2 successfully!"

cd ../q5.2
echo "Running Docker container: $image_name..."
docker run -it -v "$(pwd)":/app $IMAGE_5_2 --plant "Rose" --height 50 55 60 65 70 --leaf_count 35 40 45 50 55 --dry_weight 2.0 2.0 2.1 2.1 3.0
if [ $? -ne 0 ]; then
    echo " Docker container $image_name failed. Exiting..."
    exit 1
fi
echo "Docker container $image_name finished successfully!"

cd ../q5.3

echo "Running Docker container: $IMAGE_5_3..."
docker run --rm -v "$CONTAINER_5_3_RUN:/images" "$IMAGE_5_3" /images
if [ $? -ne 0 ]; then
    echo "Docker container $IMAGE_5_3 failed. Exiting..."
    exit 1
fi
echo "Docker container $IMAGE_5_3 finished successfully!"


echo "🧹 Cleaning up..."

docker ps -q --filter ancestor="$IMAGE_5_2" | xargs -r docker stop
docker ps -q --filter ancestor="$IMAGE_5_3" | xargs -r docker stop

docker ps -a -q --filter ancestor="$IMAGE_5_2" | xargs -r docker rm
docker ps -a -q --filter ancestor="$IMAGE_5_3" | xargs -r docker rm

docker rmi -f "$IMAGE_5_2" "$IMAGE_5_3" 2>/dev/null

echo "Cleanup done!"