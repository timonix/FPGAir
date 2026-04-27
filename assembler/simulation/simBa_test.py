# TODO: Otestad!


from pathlib import Path

import pytest

from SimBa import BeagleSim


ASSEMBLER_DIR = Path(__file__).parent.parent


def _simulator():
    return BeagleSim(
        output_file_path=ASSEMBLER_DIR / "output.rom",
        metadata_file_path=ASSEMBLER_DIR / "metadata.txt",
        ram_file_path=ASSEMBLER_DIR / "ram.ram",
        instruction_map_path=ASSEMBLER_DIR / "instruction_map.csv",
    )


def _program_labels():
    labels_started = False
    labels = {}

    for line in (ASSEMBLER_DIR / "metadata.txt").read_text(encoding="utf-8").splitlines():
        if line.startswith("--- Labels"):
            labels_started = True
            continue
        if not labels_started or not line.strip():
            continue

        name, address = line.split()
        labels[name] = int(address)

    return labels


@pytest.mark.parametrize("program_name, program_address", _program_labels().items())
def test_program_executes_without_errors(program_name, program_address, monkeypatch):
    sim = _simulator()
    monkeypatch.setattr(sim, "print_instruction", lambda instruction: None)
    monkeypatch.setattr(sim, "uart_print", lambda address: None)

    sim.PC = program_address
    max_steps = len(sim.output_lines)

    for _ in range(max_steps):
        assert 0 <= sim.PC < len(sim.output_lines), (
            f"{program_name} PC moved outside ROM: {sim.PC}"
        )

        instruction_address = sim.PC
        instruction = sim.output_lines[instruction_address]

        try:
            result = sim.run_instruction(instruction)
        except Exception as exc:
            pytest.fail(
                f"{program_name} crashed at line {instruction_address} "
                f"with instruction {instruction}: {exc}"
            )

        assert result.error is None, (
            f"{program_name} failed at line {instruction_address} "
            f"with instruction {instruction}: {result.error}"
        )

        sim.PC += 1
        if result.program_finished:
            return

    pytest.fail(f"{program_name} did not halt within {max_steps} instructions")
