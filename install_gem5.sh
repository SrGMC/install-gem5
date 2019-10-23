# Update and install dependencies
sudo apt-get update
sudo apt-get install swig gcc m4 python python-dev libgoogle-perftools-dev g++ scons git zlib1g-dev protobuf-compiler libprotobuf-dev build-essential python-dev swig python-protobuf libgoogle-perftools-dev automake python-pip -y

# Install python dependencies
pip install six

# Clone repository
git clone https://gem5.googlesource.com/public/gem5

# Get Full System files (For ALPHA and SPLASH Benchmarks). Currently unused
wget http://www.m5sim.org/dist/current/m5_system_2.0b3.tar.bz2
wget http://www.m5sim.org/dist/current/linux-dist.tgz
wget http://www.gem5.org/dist/m5_benchmarks/v1-splash-alpha.tgz

# Compile ALPHA
scons ./build/ALPHA/gem5.opt