#!/bin/bash

dataset = $1
config_name = $2

PROJECT_DIR="VQGAN_PYTORCH_LIGHTNING"



# Vérifier si le répertoire du projet existe déjà
if [ ! -d "$PROJECT_DIR" ]; then
    # Clone the GitHub repository
    git clone https://github.com/ACOOLS/VQGAN_PYTORCH_LIGHTNING.git
    cd "$PROJECT_DIR"
else
    echo "Le répertoire $PROJECT_DIR existe déjà."
    cd "$PROJECT_DIR"
fi

# Vérifier si le dataset existe déjà
DATASET_ZIP="${dataset}_last_version.zip"
folder="${dataset}"
if [ ! -d "$folder" ]; then
    # Download dataset
    wget "https://github.com/ACOOLS/VQGanomaly-ResNet-CareNet-Vit/releases/download/${dataset}/${DATASET_ZIP}" && unzip "$DATASET_ZIP" && rm "$DATASET_ZIP"
else
    echo "Le répertoire $folder existe déjà."
fi



# Chemin de l'environnement virtuel
VENV_PATH="myenv"

# Vérifier si l'environnement virtuel existe déjà
if [ ! -d "$VENV_PATH" ]; then
    # Install Python environment manager and create a virtual environment
    apt install python3.10-venv -y 
    python -m venv "$VENV_PATH"
fi

# Activer l'environnement virtuel
source "$VENV_PATH/bin/activate"

# Vérifier si les packages sont déjà installés
PACKAGES_INSTALLED=$(pip freeze)
REQUIRED_PACKAGES=(
    "pytorch-lightning==1.0.8"
    "omegaconf==2.0.0"
    "albumentations==0.4.3"
    "opencv-python==4.5.5.64"
    "pudb==2019.2"
    "imageio==2.9.0"
    "imageio-ffmpeg==0.4.2"
    "torchmetrics==0.4.0"
    "test-tube>=0.7.5"
    "streamlit>=0.73.1"
    "einops==0.3.0"
    "torch-fidelity==0.3.0"
    "wandb"
)

for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! echo "$PACKAGES_INSTALLED" | grep -q "$pkg"; then
        pip install "$pkg"
    fi
done

# Set environment variable
export WANDB_API_KEY=cab75a759f850c41f43a9ee4951f98aa6f4a1863

# Install necessary libraries
apt install -y libgl1-mesa-glx

# Upgrade OpenCV
pip install --upgrade opencv-python


# TRAIN
python3 main.py --paperspace --base configs/${dataset}/custom_vqgan_1CH_${dataset}_${config_name}.yaml -t --gpus 0, > ${dataset}_${config_name}.log

