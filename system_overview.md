# System Overview

![alt text](image.png)
Source: https://www.libreinfo.org/comment-fonctionne-un-drone-quadrirotor/

## TODO
- Test PID
- ***More better filter with GYYYYRO***

Board: Tang Nano 9
![Alt text](Pin_overview.png)



Ports used:
|Port |Function | Bank | Comment
--- | --- | --- | --- |
|4|Reset|
|10|Builtin LED|
|11|Builtin LED|
|13|Builtin LED|
|14|Builtin LED|
|15|Builtin LED|
|16|Builtin LED|
|17|TX|
|18|RX|
|31|Gyro SDA|2
|32|Gyro SCL|2
|33|GPS TX|2
|34|GPS RX|2
|41|Magnetometer SDA|2
|42|Magnetometer SCL|2
|-|Motor 1|1|Front Left
|52|Clk|
|-|Motor 2|1|Front Right
|-|Motor 3|1|Rear Left
|-|Motor 4|1|Rear Right
|38|Motor 5|1
|37|Motor 6|1
|39|Motor 7|1
|36|Motor 8|1
|70|Radio 8|1|Extra
|71|Radio 7|1|Extra
|72|Radio 6|1|Left Knob [CCW 1017 - CW 1976]
|73|Radio 5|1|Right Knob [CCW 1016 - CW 1976]
|74|Radio 4|1|Right Horizontal [Left 1155 - Right 1872]
|75|Radio 3|1|Right Stick Vertical [Down 1850 - Up 1195]
|76|Radio 2|1|Left Stick Vertical [Down 1080 -  Up 1870]
|77|Radio 1|1|Left Stick Horizontal [Left 1058 - Right 1957]
|26|mpu interrupt|2
|24|debug|2
|||
|||



```mermaid
---
title: Components

config:
    class:
        hideEmptyMembersBox: true
---
classDiagram
    

    class esc:::hardware{
        motor_1
        motor_2
        motor_3
        motor_4
        }
        esc <-- pulser

    class pulser:::vhdl
        pulser <-- mixer
        pulser <-- sequencer

    class mixer:::software
        mixer <-- pid_roll
        mixer <-- pid_pitch
        mixer <-- pid_yaw
        mixer <-- radio_throttle

    class pid_roll:::software
        pid_roll <-- combine_acc_gyro
        pid_roll <-- radio_roll

    class pid_pitch:::software
        pid_pitch <-- combine_acc_gyro
        pid_pitch <-- radio_pitch

    class pid_yaw:::software
        pid_yaw <-- scale_bias_mpu
        pid_yaw <-- radio_yaw

    class combine_acc_gyro:::software
        combine_acc_gyro <-- estimate_acc_vector
        combine_acc_gyro <--> estimate_gyro_vector 

    class estimate_gyro_vector:::software
        estimate_gyro_vector <-- scale_bias_mpu

    class estimate_acc_vector:::software
        estimate_acc_vector <-- scale_bias_mpu

    class scale_bias_mpu:::software
        scale_bias_mpu <-- brute_6050      
    
    class brute_6050:::vhdl
        brute_6050 <-- accelerometer
        brute_6050 <-- gyroscope
        brute_6050 <-- sequencer

    class sequencer:::vhdl
        sequencer <-- arming

    class arming:::vhdl
        arming <-- radio_roll
        arming <-- radio_pitch
        arming <-- radio_yaw
        arming <-- radio_arming
        arming <-- radio_throttle

    class radio_throttle:::vhdl
        radio_throttle <-- radio_reciever

    class radio_pitch:::vhdl
        radio_pitch <-- radio_reciever

    class radio_roll:::vhdl
        radio_roll <-- radio_reciever

    class radio_yaw:::vhdl
        radio_yaw <-- radio_reciever

    class radio_arming:::vhdl
        radio_arming <-- radio_reciever

    class gyroscope:::hardware
    class accelerometer:::hardware
    class radio_reciever::: hardware




    classDef vhdl fill:#69f
    classDef software fill:#606
    classDef hardware fill:#930
```
