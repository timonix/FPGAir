*** Settings ***
Library    ../SimBaLibrary.py

*** Test Cases ***
Get value at time returns expected values
    ${values}=    Get Value At Time    0.5
    Should Be Equal As Numbers    ${values[0]}    0.25
    Should Be Equal As Numbers    ${values[1]}    0.25
    Should Be Equal As Numbers    ${values[2]}    0.0