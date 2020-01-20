#! /bin/bash

function help() {
	echo "gem5 installer for Ubuntu with PARSEC benchmarks"
	echo ""
	echo "$0 [--help] <number of cores> <architecture>"
	echo "  --help               Display this message"
	echo "  <number of cores>    Specify how many cores to use for compilation."
	echo "  <architecture>       Specify the architecture ISA to compile. Currently available: "
	echo "                       \{ALPHA, ARM, MIPS, POWER, SPARC, X86\}"
	exit
}

function checkISA() {
       if [[ $1 == "ALPHA" ]] || [[ $1 == "ARM" ]] || [[ $1 == "MIPS" ]] || [[ $1 == "POWER" ]] || [[ $1 == "SPARC" ]] || [[ $1 == "X86" ]]; then
               echo "[INFO] Using $ISA for compilation"
       else
               echo "[ERROR] Unknown ISA $ISA"
	       echo ""
	       help
	       exit
       fi
}

if [[ $1 == "--help" ]]; then
	help
fi

if [[ $# -ne 2 ]]; then
	help
else
	CORES=$1
	ISA=$2
	echo "[INFO] Using $CORES cores for compilation"
	checkISA $ISA
fi

function downloadFiles() {
	wget -q $1
	if [[ $? -ne 0 ]]; then
		echo "[ERROR] An error ocurred while dowloading $1"
		echo "        Check your network connection and try again"
		exit
	fi
}

# Update and install dependencies
echo "[INFO] Updating and installing dependencies"
sudo apt-get update && sudo apt-get install bzip2 swig gcc m4 python python-dev libgoogle-perftools-dev g++ scons git zlib1g-dev protobuf-compiler libprotobuf-dev build-essential python-dev swig python-protobuf libgoogle-perftools-dev automake python-pip libboost-all-dev -y

if [[ $? -ne 0 ]]; then
	echo "[ERROR] An error ocurred while installing dependencies"
	echo "        Check the output and try again"
	exit
fi

# Install python dependencies
pip install six

if [[ $? -ne 0 ]]; then
	echo "[ERROR] An error ocurred while installing python dependencies"
	echo "        Check the output and try again"
	exit
fi

# Clone repository
echo "[INFO] Cloning gem5 repository"
git clone https://gem5.googlesource.com/public/gem5

if [[ $? -ne 0 ]]; then
	echo "[ERROR] An error ocurred while cloning gem5 repository"
	echo "        Check your network connection and try again"
	exit
fi

# Get PARSEC files
echo "[INFO] Creating directories and obtaining files"
cd gem5
mkdir benchmarks
cd benchmarks
echo "[INFO]  - writescripts.pl: Create PARSEC benchmark script"
downloadFiles http://www.cs.utexas.edu/~parsec_m5/writescripts.pl
echo "[INFO]  - inputsets.txt"
downloadFiles http://www.cs.utexas.edu/~parsec_m5/inputsets.txt
echo "[INFO]  - hack_back_ckpt.rcS"
downloadFiles http://www.cs.utexas.edu/~parsec_m5/hack_back_ckpt.rcS

# Download full system files
echo "[INFO] Downloading full system files. This might take a while"
downloadFiles http://www.m5sim.org/dist/current/m5_system_2.0b3.tar.bz2
tar xjf m5_system_2.0b3.tar.bz2 

# Replace kernel with the one provided by PARSEC
echo "[INFO] Downloading PARSEC kernel replacement"
wget -q http://www.cs.utexas.edu/~parsec_m5/vmlinux_2.6.27-gcc_4.3.4
mv vmlinux_2.6.27-gcc_4.3.4 m5_system_2.0b3/binaries/vmlinux

# Replace image with the one provided by PARSEC
echo "[INFO] Downloading PARSEC disk image replacement. This might take a while"
wget -q http://www.cs.utexas.edu/~parsec_m5/linux-parsec-2-1-m5-with-test-inputs.img.bz2
echo "[INFO] Extracting PARSEC disk image. This might take a while"
bzip2 -d linux-parsec-2-1-m5-with-test-inputs.img.bz2
mv linux-parsec-2-1-m5-with-test-inputs.img m5_system_2.0b3/disks/linux-latest.img

cd ..

# Compile ISA
echo "[INFO] Compiling gem5 with $ISA ISA"
echo "       This will take a long time. Get something to eat meanwhile"
scons ./build/$ISA/gem5.opt -j "$CORES"

if [[ $? -ne 0 ]]; then
	echo "[ERROR] An error ocurred while compiling"
	echo "        Check the output and try again. "
	echo "        Check that you have not assigned more cores than your CPU has"
	exit
fi

echo "Done!"
echo "Open gem5/configs/common/SysPaths.py. path should be similar to this:"
echo "  path = [ ... , '$(pwd)/benchmarks/m5_system_2.0b3' ]"
echo "Add the following directory to the path variable:"
echo "  $(pwd)/benchmarks/m5_system_2.0b3"
echo " "
echo "Run full system simulations with the following command":
echo "  ./build/$ISA/gem5.opt configs/example/fs.py -n 1 --cpu-type=MinorCPU --caches --kernel=vmlinux"
echo "Feel free to modify and execute diferent scripts"
