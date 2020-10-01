
sudo apt-get --yes update && sudo apt-get --yes upgrade
sudo apt-get update

sudo apt-get --yes install gfortran g++ git

# needed for newest version of openmc with dagmc
sudo apt remove -y cmake
#pip3 install cmake==3.12.0
# this will install the latet cmake like 3.18
pip3 install cmake

sudo apt-get install -y python3 python3-pip python3-dev python3-tk

sudo apt-get install --yes imagemagick hdf5-tools  libhdf5-dev wget  libsilo-dev eog
# use may install latest paraview from other source
sudo apt-get install --yes paraview
sudo apt-get --yes install dpkg libxkbfile1libblas-dev liblapack-dev libeigen3-dev

# needed to allow NETCDF on MOAB which helps with tet meshes in OpenMC
sudo apt-get --yes install libnetcdf-dev libnetcdf13

# all below can be compressed into one line command
pip3 install numpy --user
pip3 install pandas --user
pip3 install six --user
pip3 install h5py --user
pip3 install Matplotlib --user
pip3 install uncertainties --user
pip3 install lxml --user
pip3 install scipy --user
pip3 install cython --user
pip3 install vtk --user
pip3 install pytest --user
pip3 install codecov --user
pip3 install pytest-cov --user
pip3 install pylint --user
pip3 install plotly --user
pip3 install tqdm --user
pip3 install pyside2 --user # required by openmc plotter

# needed for workshop tasks
pip3 install neutronics_material_maker --user
pip3 install parametric_plasma_source --user

# Clone and install NJOY2016
cd ~
git clone https://github.com/njoy/NJOY2016 #/opt/NJOY2016
cd NJOY2016
mkdir build
cd build
cmake -Dstatic=on .. && make 2>/dev/null
sudo make install


sudo rm /usr/bin/python
sudo ln -s /usr/bin/python3 /usr/bin/python

# MOAB Variables
MOAB_INSTALL_DIR=$HOME/MOAB

# DAGMC Variables
DAGMC_INSTALL_DIR=$HOME/DAGMC
set -ex

echo 'export MOAB_INSTALL_DIR=$HOME/MOAB' >> ~/.bashrc
echo 'export DAGMC_INSTALL_DIR=$HOME/DAGMC' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$MOAB_INSTALL_DIR/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$DAGMC_INSTALL_DIR/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
# echo '$PATH:/openmc/build/bin/' >> ~/.bashrc

pip install cython

# MOAB Install
cd ~
mkdir MOAB
cd MOAB
git clone -b Version5.1.0 https://bitbucket.org/fathomteam/moab/
mkdir build
cd build
# this installs without netcdf but with pymoab
#cmake ../moab -DENABLE_HDF5=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$MOAB_INSTALL_DIR -DENABLE_PYMOAB=ON
# this installs with netcdf but without pymoab
cmake ../moab -DENABLE_HDF5=ON -DENABLE_MPI=off -DENABLE_NETCDF=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$MOAB_INSTALL_DIR
make -j
make -j install
# this 2nd build is required which is a shame
# this is to be used if you want pymoab
# cmake ../moab -DBUILD_SHARED_LIBS=OFF
# otherwise if you want netcdf
cmake ../moab -DBUILD_SHARED_LIBS=OFF
make -j install

# if you installed pymoab run these two commands as well
# cd pymoab
# bash install.sh

#needs setting in bashrc
LD_LIBRARY_PATH=$MOAB_INSTALL_DIR/lib:$LD_LIBRARY_PATH
echo 'export PATH=$PATH:$MOAB_INSTALL_DIR/bin' >> ~/.bashrce


# DAGMC Install
cd ~
mkdir DAGMC
cd DAGMC
git clone -b develop https://github.com/svalinn/DAGMC.git
mkdir build
cd build
# cmake ../dagmc -DBUILD_TALLY=ON -DCMAKE_INSTALL_PREFIX=$DAGMC_INSTALL_DIR -DMOAB_DIR=$MOAB_INSTALL_DIR -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_EXE=ON
# cmake ../dagmc -DBUILD_TALLY=ON -DCMAKE_INSTALL_PREFIX=$DAGMC_INSTALL_DIR -DMOAB_DIR=$MOAB_INSTALL_DIR -DBUILD_STATIC_LIBS=OFF
cmake ../dagmc -DBUILD_TALLY=ON -DCMAKE_INSTALL_PREFIX=$DAGMC_INSTALL_DIR -DMOAB_DIR=$MOAB_INSTALL_DIR
make -j install
# rm -rf $HOME/DAGMC/dagmc
#needs setting in bashrc
LD_LIBRARY_PATH=$DAGMC_INSTALL_DIR/lib:$LD_LIBRARY_PATH
echo 'export PATH=$PATH:~/DAGMC/bin' >> ~/.bashrc


# OpenMC Install, this must be installed to /opt/openmc, `parametric_plasma_source` python module has this path hard-coded
cd /opt
sudo git clone --recurse-submodules https://github.com/openmc-dev/openmc.git
cd /opt/openmc
sudo chmod 777 -R openmc
sudo git checkout develop
sudo mkdir build
sudo chmod 777 build
cd build
cmake -Ddagmc=ON -DDAGMC_ROOT=$DAGMC_INSTALL_DIR ..
# cmake -Ddagmc=ON -Ddebug=on -DDAGMC_ROOT=$DAGMC_INSTALL_DIR ..
sudo make -j
sudo make -j install
cd /opt/openmc/
sudo python3 setup.py develop --user
# to uninstall in build folder: sudo xargs rm < install_manifest.txt

# Nuclear data install
cd ~
git clone https://github.com/openmc-dev/data.git
cd data
python3 convert_fendl.py
python3 convert_tendl.py
python3 convert_nndc71.py


OPENMC_CROSS_SECTIONS_NNDC=~/data/nndc-b7.1-hdf5/cross_sections.xml
echo 'export OPENMC_CROSS_SECTIONS_NNDC=~/data/nndc-b7.1-hdf5/cross_sections.xml' >> ~/.bashrc
OPENMC_CROSS_SECTIONS_TENDL=~/data/tendl-2017-hdf5/cross_sections.xml
echo 'export OPENMC_CROSS_SECTIONS_TENDL=~/data/tendl-2019-hdf5/cross_sections.xml' >> ~/.bashrc
OPENMC_CROSS_SECTIONS_FENDL=~/data/fendl-3.1d-hdf5/cross_sections.xml
echo 'export OPENMC_CROSS_SECTIONS_FENDL=~/data/fendl-3.1d-hdf5/cross_sections.xml' >> ~/.bashrc

OPENMC_CROSS_SECTIONS=~/data/tendl-2017-hdf5/cross_sections.xml
echo 'export OPENMC_CROSS_SECTIONS=~/data/tendl-2019-hdf5/cross_sections.xml' >> ~/.bashrc


# openmc-plotter

cd $HOME
git clone https://github.com/openmc-dev/plotter.git
cd $HOME/plotter
pip install .
echo 'alias openmc-plotter=$HOME/.local/bin/openmc-plotter' >> ~/.bashrc


# dependancies for the occ_faceter
sudo apt-get --yes install software-properties-common
sudo add-apt-repository -y ppa:freecad-maintainers/freecad-stable
sudo apt-get --yes update && sudo apt-get --yes upgrade

sudo apt-get --yes install libcgal-dev
# this libocc*dev can match 7.3 on Ubuntu 18.04 and 7.4 on Ubuntu  20.04
sudo apt-get --yes install libocc*dev
sudo apt-get --yes install occ*
sudo apt-get --yes install  libtbb2 libtbb-dev

# install the occ_faceter, this currently uses a branch that could be merged
cd ~
git clone https://github.com/makeclean/occ_faceter.git
cd occ_faceter
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=..
make
make install
# consider installed to $DAGMC_INSTALL_DIR/bin
#sudo cp ../bin/steps2h5m /bin
sudo cp ../bin/occ_faceter /bin

# dependancies for PPP, in addition to occ_faceter
sudo apt-get install -y ccache

# those are not used by ppp, however indirect dependancies
sudo apt-get install -y libx11-dev  libxmu-dev libxi-dev libboost-dev

# installs the PPP
git clone  --recurse-submodules https://git.ccfe.ac.uk/scalable-multiphysics-framework/parallel-preprocessor.git
cd parallel-preprocessor
mkdir build
cd build
cmake ..
make -j

# test this ppp install by trying to import ppp from within python, further steps might be needed
