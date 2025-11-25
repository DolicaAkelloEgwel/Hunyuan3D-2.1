# install cuda 12.6 for WSL
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.6.0/local_installers/cuda-repo-wsl-ubuntu-12-6-local_12.6.0-1_amd64.deb
sudo dpkg -i cuda-repo-wsl-ubuntu-12-6-local_12.6.0-1_amd64.deb
sudo cp /var/cuda-repo-wsl-ubuntu-12-6-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-6

# install python3-config
sudo apt-get install -y python3-dev

# set cuda path
export CUDA_HOME=/usr/local/cuda
export PATH=$CUDA_HOME/bin:$PATH


# install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env

# sync
uv sync

# install requirements
cd hy3dpaint/custom_rasterizer 
uv pip install -e . --no-build-isolation

# change dir
cd ../../hy3dpaint/DifferentiableRenderer

# compile this thing...
bash compile_mesh_painter.sh

# this is also needed...
cd ../..
wget https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth -P hy3dpaint/ckpt


