# install-gem5

Script that downloads and compiles gem5 along with the PARSEC benchmarks and Linux image. This script will also install the required dependencies for gem5 to run.

## How to run

1. Clone the repository: `git clone https://github.com/SrGMC/install-gem5.git`
2. Allow execution of instal_gem5.sh: `chmod a+x install_gem5.sh`
3. Run: `install_gem5.sh`
    - Append a number to choose the number of cores to use in compilation: `install_gem5.sh 8`

The script will download the necessary files and compile the ALPHA CPU arquitecture
