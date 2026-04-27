# Robot Framework setup for assembler/simulation

This folder contains a minimal Robot Framework example for the simulation code.

## Install

Activate your workspace virtual environment, then install the test dependency:

```powershell
cd assembler\simulation
pip install -r requirements.txt
```

## Run the example test

```powershell
cd assembler\simulation
python -m robot example_simulation.robot
```

## Files

- `requirements.txt` — Robot Framework dependency for this folder.
- `SimBaLibrary.py` — Python keyword library for Robot Framework.
- `example_simulation.robot` — example Robot Framework test suite.
