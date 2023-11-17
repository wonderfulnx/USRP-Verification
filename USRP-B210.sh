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

## UHD Standard Testing
### 1. Probe and see the info
uhd_find_device
uhd_usrp_probe
### 2. Test with uhd benchmarks and examples
cd /usr/lib/uhd/examples
sudo ./benchmark_rate --rx_rate 56e6 --tx_rate 56e6 --tx_otw sc12 --rx_otw sc12
sudo ./test_dboard_coercion --tx 2512e6 --rx 2512e6
sudo ./test_messages
sudo ./test_timed_commands
sudo ./usrp_list_sensors
### 3. Test transmitting and receiving, Remember to plug an antenna
sudo ./tx_waveforms --freq 2422e6 --rate 5e6 --gain 30
uhd_fft -A TX/RX -s 25e6 -g 30 -f 2422e6 --otw-format sc16
uhd_fft -A TX/RX -s 50e6 -g 30 -f 2422e6 --otw-format sc8
### 4. Latency test
sudo ./latency_test --args="serial=323573C" --nsamps=256 --nruns=1000 --rtt=0.001 --rate=25e6 --from-eob --verbose
### Some note
### - N210 has a maximum bandwidth ability of 125MHz (125Msps) at 16 bit sampling depth when using one channel.
