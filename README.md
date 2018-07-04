# Cars Sensor

## By Boffelli Jacopo, Cantoni Giorgio & Nicola Pirotta

A system based on the MIPS R2000 microprocessor (clock equal to 250 MHz) is in charge
of the management of a speed camera system for the detection of car speed.
The system uses two sensors at a distance of one meter from each other able to detect the
presence of a car.
The microprocessor management program must be able to detect when
a car passes at a higher speed than 90 km / h predicted by the highway code in a
extra-urban stretch. When this happens, after a second has passed, the program of
management must control the shutter release of a camera with a pulse
with a duration of 500 ms and then restart the check on the next car, etc.
In particular, the lines 15 and 14 of the 16-bit cell named IN_OUT read the sensors which
they signal crossing when, from the low logical level, each line goes to the level
logical high. Line 15 is connected to the first sensor that a car meets in the sense of
march.
Line 3 of the same cell IN_OUT is used instead to control the trip of the
camera.
Finally on lines 7 and 6 of IN_OUT you must send a number that represents the speed
measured according to the following convention:
00: speed <90 km / h;
01: speed between 90 and 100 km / h;
10: speed between 100 and 110 km / h;
11: speed> 110 km / h.
This information is used to display an indication on the frame that allows to
quantify the extent of the infringement.
For the sake of simplicity, it is assumed that only one car at a time is in the measurement area.

The memory cells mentioned above are assigned arbitrary addresses that fall, however,
in the data area of ​​the MIPS architecture.
