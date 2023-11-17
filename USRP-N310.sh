# !!DO NOT RUN THIS SCRIPT DIRECTLY!

#################################################################
# This script helps you to test whether your USRP N210 is broken
#################################################################

## System Requirement
### 1. Secure Boot OFF
### 2. Since we are using PicoScenes, Ubuntu 20.04 LTS and its variants (Linux Mint, Kubuntu, Xubuntu, etc.).
### 3. No virtualization (as per PicoScenes's requirement)
### 4. Install up-to-date kernel versions
### 5. Internet connection (it's the best to have multiple Ethernet and Wireless connection methods)

## Preparation
### 1. Set socket buffer
sudo sysctl -w net.core.wmem_max=62500000
sudo sysctl -w net.core.rmem_max=62500000
sudo sysctl -w kernel.shmmax=2147483648
### 2. Set the MTU of the USRP's eth connection to 9000 (automatic is not accepted)
### 3. Check and Set the ring buffer of the eth, make sure it's set to max
ethtool -g <eth_interface> # check
ethtool -G <interface> rx 4096 tx 4096 # 4096 corresponds to the max value seen in last command

## UHD Standard Testing
### 1. Probe and see the info
uhd_usrp_probe
### 2. Test with uhd benchmarks and examples
cd /usr/lib/uhd/examples
sudo ./benchmark_rate --rx_rate 125e6 --tx_rate 125e6 --tx_otw sc16 --rx_otw sc16
sudo ./test_dboard_coercion --tx 2512e6 --rx 2512e6
sudo ./test_messages
sudo ./test_timed_commands
sudo ./usrp_list_sensors
### 3. Test transmitting and receiving, Remember to plug an antenna
sudo ./tx_waveforms --freq 2422e6 --rate 5e6 --gain 30
uhd_fft -A TX/RX -s 25e6 -g 30 -f 2422e6 --otw-format sc16
uhd_fft -A TX/RX -s 50e6 -g 30 -f 2422e6 --otw-format sc8
### 4. Latency test
sudo ./latency_test --args="addr=192.168.20.2,recv_frame_size=256" --nsamps=256 --nruns=1000 --rtt=0.001 --rate=25e6 --from-eob --verbose
### Some note
### - N210 has a maximum bandwidth ability of 125MHz (125Msps) at 16 bit sampling depth when using one channel.
