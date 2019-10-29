# Update and install dependencies
sudo apt-get update
sudo apt-get install swig gcc m4 python python-dev libgoogle-perftools-dev g++ scons git zlib1g-dev protobuf-compiler libprotobuf-dev build-essential python-dev swig python-protobuf libgoogle-perftools-dev automake python-pip libboost-all-dev -y

# Install python dependencies
pip install six

# Clone repository
git clone https://gem5.googlesource.com/public/gem5

# Get PARSEC files
cd gem5
mkdir benchmarks
cd benchmarks
wget http://www.cs.utexas.edu/~parsec_m5/writescripts.pl
wget http://www.cs.utexas.edu/~parsec_m5/inputsets.txt
wget http://www.cs.utexas.edu/~parsec_m5/hack_back_ckpt.rcS
# Download full system files
wget http://www.m5sim.org/dist/current/m5_system_2.0b3.tar.bz2
tar xzf m5_system_2.0b3.tar.bz2
echo "Open gem5/configs/common/SysPaths.py. path should be similar to this:"
echo "  path = [ ... , '$(pwd)/m5_system_2.0b3' ]"
echo "Add the following directory to the path variable:"
echo "  $(pwd)/m5_system_2.0b3"
cd ..

# Compile ALPHA
scons ./build/ALPHA/gem5.opt -j 2

echo "Done!"
echo "Run simulations with the following command":
echo "  ./build/ALPHA/gem5.opt configs/example/fs.py -n 1 --cpu-type=MinorCPU --caches --kernel=vmlinux"
echo "Feel free to modify and execute diferent scripts"
