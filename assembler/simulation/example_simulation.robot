*** Settings ***
Library    SimBaLibrary.py

*** Test Cases ***
Word From Float Produces Expected Fixed Point
    ${result}=    Create Word From Float    1.5    20
    Should Be Equal As Integers    ${result}    1572864

Run NOP Instruction Returns OK
    ${status}=    Run Instruction And Return Status    00000000
    Should Be Equal    ${status}    OK

Run HALT Instruction Returns Finished
    ${status}=    Run Instruction And Return Status    11111110
    Should Be Equal    ${status}    FINISHED

Run Invalid Instruction Reports Error
    ${error}=    Run Instruction And Return Error    2A000001
    Should Contain    ${error}    Error: Wrong length or not binary
