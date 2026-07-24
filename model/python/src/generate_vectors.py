import random
from pathlib import Path
from model import ProcessingElement

COUNT = 100
SEED = 7
WIDTH = 8
OUTPUT_DIR = Path(__file__).resolve().parents[1] / "vectors"


def generate(width, seed, count):
    random.seed(seed)
    weight = random.randrange(-(2 ** (width - 1)), 2 ** (width - 1))
    pe = ProcessingElement(weight)
    inputs, outputs = [], []

    for i in range(count):
        a = random.randrange(-(2 ** (width - 1)), 2 ** (width - 1))
        b = random.randrange(-(2 ** (2 * width)), 2 ** (2 * width))
        c, d = pe.step(a, b)
        inputs.append({"id": i, "weight": weight, "a": a, "b": b})
        outputs.append({"id": i, "c": c, "d": d})

    return inputs, outputs


def write(output_dir, inputs, outputs):
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    with (output_dir / "pe_inputs.vec").open("w") as f:
        f.writelines(
            f"{row['id']} {row['weight']} {row['a']} {row['b']}\n"
            for row in inputs
        )

    with (output_dir / "pe_expected.vec").open("w") as f:
        f.writelines(
            f"{row['id']} {row['c']} {row['d']}\n"
            for row in outputs
        )


def main():
    inputs, outputs = generate(WIDTH, SEED, COUNT)
    write(OUTPUT_DIR, inputs, outputs)
    print(f"Generated {len(inputs)} PE vectors in {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
