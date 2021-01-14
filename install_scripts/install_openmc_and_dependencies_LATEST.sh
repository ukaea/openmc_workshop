
# This script installs [Miniconda3, Python 3.8.5, CadQuery=master](require manual installation), NJOY, Embree, MOAB, Double-down,
# Pymoab, DAGMC, OpenMC, Parametric plasma source, Neutronics material maker, ENDF nuclear data, Windowed Multipole data.


# Install Miniconda3

# Download Miniconda3 for Linux from this website: https://docs.conda.io/en/latest/miniconda.html

# cd ~/Downloads
# bash Miniconda3-latest-Linux-x86_64.sh

# Run conda init to initialise conda

# conda create -y --name cqmaster
# conda activate cqmaster
# conda clean --all

# Install specific version of python (not required)
# CadQuery=master requires Python >3.8
# Cadquery=2 requires Python <3.8

# conda install -c conda-forge -c python python=3.8.5
# conda clean --all

# Install Cadquery

# conda install -c conda-forge -c cadquery cadquery=master
# conda clean --all


# Install general dependencies

sudo apt-get update -y && upgrade -y

sudo apt-get install -y libgl1-mesa-glx libgl1-mesa-dev libglu1-mesa-dev
sudo apt-get install -y freeglut3-dev libosmesa6 libosmesa6-dev libgles2-mesa-dev
sudo apt-get clean


# Install neutronics dependencies

sudo apt-get install -y wget git gfortran g++ cmake imagemagick
sudo apt-get install -y mpich libmpich-dev libhdf5-serial-dev libhdf5-mpich-dev


# Install MOAB dependencies

sudo apt-get --yes install libeigen3-dev
sudo apt-get --yes install libblas-dev
sudo apt-get --yes install liblapack-dev
sudo apt-get --yes install libnetcdf-dev
sudo apt-get --yes install libtbb-dev
sudo apt-get --yes install libglfw3-dev


# Clone and install NJOY2016

cd ~
sudo git clone https://github.com/njoy/NJOY2016 /opt/NJOY2016
cd /opt
sudo chmod -R 777 NJOY2016
cd /opt/NJOY2016
mkdir build
cd build
cmake -Dstatic=on ..
sudo make 2>/dev/null
sudo make install

echo "export PATH=$PATH:/opt/NJOY2016/build" >> ~/.bashrc

# Clone and install Embree

cd ~
git clone https://github.com/embree/embree
cd embree
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=.. -DEMBREE_ISPC_SUPPORT=OFF
make -j4
sudo make -j4 install


# Clone and install MOAB

cd ~
pip install --upgrade numpy cython
mkdir MOAB
cd MOAB
mkdir build
git clone  --single-branch --branch develop https://bitbucket.org/fathomteam/moab/
cd build
cmake ../moab -DENABLE_HDF5=ON -DENABLE_NETCDF=ON -DENABLE_BLASLAPACK=OFF -DBUILD_SHARED_LIBS=OFF -DENABLE_FORTRAN=OFF -DCMAKE_INSTALL_PREFIX=$HOME/MOAB
make -j4
make -j4 install
cmake ../moab -DBUILD_SHARED_LIBS=ON -DENABLE_HDF5=ON -DENABLE_PYMOAB=ON -DENABLE_BLASLAPACK=OFF -DENABLE_FORTRAN=OFF -DCMAKE_INSTALL_PREFIX=$HOME/MOAB
# make -j4
make -j4 install
cd pymoab

# The following commands are taken from $HOME/MOAB/build/pymoab/install.sh (use as reference)

# PYMOAB_INSTALL_PREFIX=$HOME/MOAB/lib/python3.8/site-packages
# export PYTHONPATH="$PYMOAB_INSTALL_PREFIX:$PYTHONPATH"
# $HOME/miniconda3/envs/cqmaster/bin/python setup.py install --prefix=$HOME/MOAB --record $HOME/MOAB/lib/python3.8/site-packages/install_files.txt
# python setup.py install


# Clone and install Double-Down

cd ~
git clone https://github.com/pshriwise/double-down
cd double-down
mkdir build
cd build
# cmake .. -DCMAKE_INSTALL_PREFIX=.. -DMOAB_DIR=/usr/local -DEMBREE_DIR=~/embree/lib/cmake/embree-3.12.1
cmake .. -DCMAKE_INSTALL_PREFIX=.. -DMOAB_DIR=$HOME/MOAB -DEMBREE_DIR=$HOME/embree/lib/cmake/embree-3.12.1
make -j4
make -j4 install


# Clone and install DAGMC

cd ~
mkdir DAGMC
cd DAGMC
git clone -b develop https://github.com/svalinn/dagmc
mkdir build
cd build
# cmake ../dagmc -DBUILD_TALLY=ON -DCMAKE_INSTALL_PREFIX=~/DAGMC -DMOAB_DIR=/usr/local
cmake ../dagmc -DBUILD_TALLY=ON -DCMAKE_INSTALL_PREFIX=$HOME/DAGMC -DMOAB_DIR=$HOME/MOAB
make -j4 install
# rm -rf ~/DAGMC/dagmc ~/DAGMC/build   # don't know why these are deleted as need to point to build directory during OpenMC compile


# Clone and install OpenMC with DAGMC

sudo git clone --recurse-submodules https://github.com/openmc-dev/openmc.git /opt/openmc
cd /opt
sudo chmod -R 777 openmc
cd /opt/openmc
mkdir build
cd build
cmake -Doptimize=on -Ddagmc=ON -DDAGMC_DIR=$HOME/DAGMC/build -DHDF5_PREFER_PARALLEL=off ..
make -j4
sudo make -j4 install
cd ..
# pip install -e .[test]
pip install -e .


# Clone and install parametric plasma source

cd ~
git clone https://github.com/open-radiation-sources/parametric-plasma-source.git
cd parametric-plasma-source
git checkout develop
mkdir build
cd build
cmake .. -DOPENMC_DIR=/opt/openmc
make
cd ..
pip install -e .


# Download nuclear data

cd ~
git clone https://github.com/openmc-dev/data.git
cd data
python3 convert_nndc71.py
python3 convert_tendl.py
python3 convert_fendl.py 

echo "export OPENMC_CROSS_SECTIONS=$HOME/data/nndc-b7.1-hdf5/cross_sections.xml" >> ~/.bashrc

# Windowed multipole data - by default, OpenMC looks in / directory for this data
# cd ~
# wget https://github.com/mit-crpg/WMP_Library/releases/download/v1.1/WMP_Library_v1.1.tar.gz
# tar -xf WMP_Library_v1.1.tar.gz
# sudo mv WMP_Library /
