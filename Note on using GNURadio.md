# A few note on using GNURadio with USRP

## Preparation

All of following preparations we have done in verification should be done before runing a flow graph.

```sh
### 1. Set socket buffer
sudo sysctl -w net.core.wmem_max=50000000
sudo sysctl -w net.core.rmem_max=50000000
sudo sysctl -w kernel.shmmax=2147483648
### 2. Set the MTU of the USRP's eth connection to 9000 (automatic is not accepted)
### 3. Check and Set the ring buffer of the eth, make sure it's set to max
ethtool -g <eth_interface> # check
ethtool -G <interface> rx 4096 tx 4096 # 4096 corresponds to the max value seen in last command
```

## Notes when using GNURadio in ubuntu 20.04

When using GNURadio with USRP in ubuntu 20.04, we usually install an old version directly through apt, which has a GNURadio version of `3.8.1.0` and a UHD of version `3.15.0.0-2build5`. There are a few things worth noting:

1. GNURadio of legacy version 3.8 **does not** include autoremoval of DC offset, Tx IQ balance, and Rx IQ balance. Even through there exist an FE Corrections in the USRP Source properties we can see in GUI, it does not take any effect. This can be verified by viewing the source code of verion `maint-3.8`. This is a little negligence in this version and the issue was fixed in newer versions such as `3.9`. However, for the Tx, there isn't any API for applying this auto-correction and therefore no effect there as well. In short, using these version, there exists **no** auto-correction for any USRP device if you use USRP Source or USRP Sink block.

2. When running top blocks for third party flow graphs, the GUI always tend to stuck and give a 'not responding' error. Sometime the whole system gets stuck as well and the only thing you can do is hard reboot. Therefore, it is recommended to use GUI to generate the `.py` file of a top block and then directly run the `.py` file through a terminal. No crashing or stucking will happen in this case. It may relate to a QT GUI problem and I hope in newer version it is solved.

## TO DO

1. Set up an ubuntu 22.04 which has GNURadio of version `3.10.1.1` and UHD of version `4.1.0.5-3` to check if our USRP work fine.

