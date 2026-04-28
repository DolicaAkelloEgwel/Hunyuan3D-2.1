set -e

CUDA_VERSION="$1";

CUDA_MAJOR="${CUDA_VERSION%%.*}"
CUDA_MINOR="${CUDA_VERSION##*.}" 

echo $CUDA_MAJOR
echo $CUDA_MINOR

case "$CUDA_VERSION" in
  "12.4") CUDA_PATCH="0" ;;
  "13.2") CUDA_PATCH="1" ;;
  *)
    echo "Unknown full version for $CUDA_VERSION"
    exit 1
    ;;
esac

exit

# now I'm not even sure what's happening
sudo bash -c 'cat .source >> /etc/apt/sources.list.d/ubuntu.sources'

sudo apt update
sudo apt install software-properties-common -y

sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update

# install python
sudo apt install -y python3.10 python3.10-venv python3.10-dev build-essential cmake

# install pip
curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10
python3.10 -m pip --version

# install cuda for WSL
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/${CUDA_MAJOR}.${CUDA_MINOR}.${CUDA_PATCH}/local_installers/cuda-repo-wsl-ubuntu-${CUDA_MAJOR}-${CUDA_MINOR}-local_${CUDA_MAJOR}.${CUDA_MINOR}.${CUDA_PATCH}-1_amd64.deb
sudo dpkg -i cuda-repo-wsl-ubuntu-${CUDA_MAJOR}-${CUDA_MINOR}-local_${CUDA_MAJOR}.${CUDA_MINOR}.${CUDA_PATCH}-1_amd64.deb
sudo cp /var/cuda-repo-wsl-ubuntu-${CUDA_MAJOR}-${CUDA_MINOR}-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda-toolkit-${CUDA_MAJOR}-${CUDA_MINOR}

# set cuda path
echo "CUDA_HOME=/usr/local/cuda" >> .bashrc
echo "PATH=$CUDA_HOME/bin:$PATH" >> .bashrc
. ~/.bashrc

# create and activate venv
python3.10 -m venv hunyuan
. hunyuan/bin/activate

# pip stuff
pip install --upgrade pip setuptools wheel

if [[ "$CUDA_VERSION" = "12.4" ]]; then
  pip install torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 --index-url https://download.pytorch.org/whl/cu${CUDA_MAJOR}${CUDA_MINOR}
else
  pip install torch torchvision
fi

pip install bpy==4.0 --extra-index-url https://download.blender.org/pypi/
pip install -r requirements.txt

# other stuff ...?
cd hy3dpaint/custom_rasterizer
pip install --no-build-isolation .
cd ../..
cd hy3dpaint/DifferentiableRenderer
bash compile_mesh_painter.sh
cd ../..

# get a model file
wget https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth -P hy3dpaint/ckpt

# delete the cuda installaer
rm cuda-repo-wsl-ubuntu-*
