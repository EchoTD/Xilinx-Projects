#!/usr/bin/env python3
import serial, struct

PORT = "/dev/ttyUSB1"      # COMx on Windows
BAUD = 115200
LSB_PER_G = 1024.0         # 1 g = 1024 counts

ser = serial.Serial(PORT, BAUD, timeout=0.1)
buf = bytearray()

print("   X(cnt)    Y(cnt)    Z(cnt)  |   X(g)     Y(g)     Z(g)")
print("-----------------------------------------------------------")

try:
    while True:
        buf.extend(ser.read(64))

        # search for a complete 9-byte packet: 58 XX xx 59 YY yy 5A ZZ zz
        while True:
            if len(buf) < 9:
                break
            h = buf.find(b'\x58')                 # look for 'X' header
            if h == -1:
                buf.clear(); break
            if len(buf) - h < 9:                  # need full packet
                break
            if buf[h+3] == 0x59 and buf[h+6] == 0x5A:
                x = struct.unpack('>h', buf[h+1:h+3])[0]
                y = struct.unpack('>h', buf[h+4:h+6])[0]
                z = struct.unpack('>h', buf[h+7:h+9])[0]
                print(f"{x:10d}{y:10d}{z:10d}  |"
                      f"{x/LSB_PER_G:7.3f}{y/LSB_PER_G:9.3f}{z/LSB_PER_G:9.3f}")
                del buf[:h+9]                      # remove parsed bytes
            else:
                del buf[:h+1]                      # sync forward
except KeyboardInterrupt:
    pass
finally:
    ser.close()
