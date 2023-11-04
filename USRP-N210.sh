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
sudo sysctl -w net.core.wmem_max=50000000
sudo sysctl -w net.core.rmem_max=50000000
### 2. Set the MTU of the USRP's eth connection to 9000 (automatic is not accepted)
### 3. Check and Set the ring buffer of the eth, make sure it's set to max
ethtool -g <eth_interface> # check
ethtool -G <interface> rx 4096 tx 4096 # 4096 corresponds to the max value seen in last command

## UHD Standard Testing
### 1. Probe and see the info
uhd_usrp_probe
### 2. Test with uhd benchmarks and examples
cd /usr/lib/uhd/examples
sudo ./benchmark_rate --rx_rate 25e6 --tx_rate 25e6 --tx_otw sc16 --rx_otw sc16
sudo ./benchmark_rate --rx_rate 50e6 --tx_rate 50e6 --tx_otw sc8 --rx_otw sc8
sudo ./test_dboard_coercion --tx 2512e6 --rx 2512e6
sudo ./test_messages
sudo ./test_timed_commands
sudo ./usrp_list_sensors
### 3. Test transmitting and receiving, Remember to plug an antenna
sudo ./tx_waveforms --freq 2422e6 --rate 5e6 --gain 30
uhd_fft -A TX/RX -s 25e6 -g 30 -f 2422e6 --otw-format sc16
uhd_fft -A TX/RX -s 50e6 -g 30 -f 2422e6 --otw-format sc8
### Some note
### - N210 has the bandwidth ability of 25MHz (25Msps) at 16 bit sampling depth and 50MHz (50Msps) at 8 bit depth, no matter the daughter board is SBX or UBX

## Calibration of N210
## - !!Note: this requires unplug all antennas or any connected hardware on SMA ports!!
## - Cal files are stored at /root/.uhd/cal/
### 1. Three things need calibration
sudo uhd_cal_rx_iq_balance --verbose --args="serial=<device>"
sudo uhd_cal_tx_iq_balance --verbose --args="serial=<device>"
sudo uhd_cal_tx_dc_offset --verbose --args="serial=<device>"
### 2. show all cal files
sudo ls -al /root/.uhd/cal/

## Picoscenes (Picoscenes is also a very good tool for testing Tx/Rx ability of USRP, given that picoscenes is correctly installed)
### 0. Close the cpu protect regarding meltdown and specture, also run `ChangeCPUFreqGovernor performance` as PS suggestted.
###    If there is any other warning in PicoScenes, you should resolve it.
### 1. Do some preparation for PS, Check array status, Lookup the Wi-Fi NIC’s PhyPath ID by array_status
cd ~/Desktop
array_status
### 2. array_prepare_for_picoscenes <NIC_PHYPath> <freq> <mode>, may not work at non-standard freqiencies but doesn't matter
array_prepare_for_picoscenes wlp4s0 "2512 HT20"
### 3. QCA9300 Tx, while USRP Rx. The transmit power should be low when closely put the two devices.
###    Check the ps.txt file and search RxFrame to get packet reception rate, when working in non-standard frequencies, should be very high (given that the channel is pretty good).
###    PS may say that calibration files are not found, which is not true... It indeed found and used them, but the warning exists anyway...
###    Don't forget about pluging the antenna.
PicoScenes "-d debug;
            -i usrp192.168.10.2 --freq 2512e6 --rate 20e6          --mode logger --rx-cbw 20 --rx-ant TX/RX;
            -i wlp4s0           --freq 2512e6 --rate 20e6 --txcm 1 --mode injector --cbw 20 --coding ldpc --mcs 5 --repeat 1000 --delay 20000 --txpower 0;
            -q 3;" | tee ps.txt
### 4. USRP Tx, while QCA9300 Rx, other parameter you can try: --coding ldpc --format ht --mcs 5
PicoScenes "-d debug;
            -i wlp4s0           --freq 2512e6 --rate 20e6 --rxcm 1 --mode logger --rx-cbw 20;
            -i usrp192.168.10.2 --freq 2512e6 --rate 20e6          --mode injector --cbw 20 --coding ldpc --mcs 5 --repeat 1000 --delay 20000 --txpower 0.1;
            -q 3;" | tee ps.txt
### 5. If the Tx or Rx is not good, can add `--rate 25e6 --rx-resample-ratio 0.8` to 3 and `--rate 25e6 --tx-resample-ratio 1.25` to 4.
### 6. Restore NIC
RestoreNetwork
