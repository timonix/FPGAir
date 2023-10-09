# System Overview

```mermaid
---
title: Components
---
classDiagram
    class top
        top <|-- DCCM
        top <|-- uart_top

    class DCCM
    
    class mpu6050

    class pwm 

    class uart_top
        uart_top <|-- uart_rx
        uart_top <|-- uart_tx

    class uart_rx

    class uart_tx

    class radio_channel

    class acc_angles
        acc_angles <|-- cordic_acc

    class cordic_acc