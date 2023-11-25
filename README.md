# Recording Audio Data from Nexys 4 DDR Board Microphone and Transmitting it to a Mobile Device - LINUX

This is a Uni project made in VHDL using onboard DDR2 memory to sotre the recored audio, and UART protocol to comunicate via bluetooth

To test the UART transmision  you can:

`ll /dev/serial/by-id`

Which gives:

```
bogdan@VivoBook:~$ ll /dev/serial/by-id
total 0
drwxr-xr-x 2 root root 80 Nov 25 10:29 ./
drwxr-xr-x 4 root root 80 Nov 25 10:29 ../
lrwxrwxrwx 1 root root 13 Nov 25 10:29 usb-Digilent_Digilent_USB_Device_210292A3FCE3-if01-port0 -> ../../ttyUSB1
```

To test the UART transmision for bluetooth devices:
- Find device mac using:

  `bluetoothctl scan on`
  
- After that bind the device to rfcomm:

  `rfcomm bind /dev/rfcomm0 11:22:33:44:55:66`
  
- Optional you can link the rfcomm to a serial port:

  `sudo ln -s  /dev/rfcomm0 /dev/ttyUSB0`
  
- Setup `minicom` or `putty` to connect to your serial port:
  ```
  Start bits: 1,
  BAUD_RATE = 9600,
  Data bits: 8,
  Parity: None
  Stop bits: 1
  Flow contole: None
  ```
