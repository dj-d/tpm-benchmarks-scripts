# TPM Benchmarks Scripts

This repository contains all the scripts to be able to replicate the benchmarks related to the use of TPM 2.0

## Structure

The repository is structured as follows:

```text
.
├── docs
│   ├── INSTALL.md
│   └── USAGE.md
├── README.md
├── scripts
│   ├── globals.sh
│   ├── key_rotation.sh
│   ├── tpm.sh
│   ├── utility.sh
│   └── wrapper.sh
```

## Requirements

To faithfully replicate the working environment, the following guide can be used: [INSTALL](docs/INSTALL.md)

## Usage

The following guide can be used to replicate the benchmarks: [USAGE](docs/USAGE.md).

## Results

The benchmark results to be analyzed are multiple:

- The time to **initialize the TPM keys** took less than 5 seconds.
- The time to **encrypt** and **sign** a file took about 6 seconds.
- The time to unroll the key rotation took:
  - less than 32 seconds for 10 epochs
  - about 45 seconds for 15 epochs
  - less than 1 minute and 6 seconds for 20 epochs
  - about 2 minutes and 41 seconds for 50 epochs
- The time to **decrypt** and **verify** a file took about 3 seconds.

To run the benchmarks on encryption and decryption, the following commands can be used:

```bash
# create a file with random file
echo "This is a test" > file

# get timing
time ./wrapper -i 
time ./wrapper -e -s -p file -o file.enc
time ./wrapper -d -v -p file.enc -o file.dec

# or 

time $(\
    ./wrapper -i && \
    ./wrapper -e -s -p file -o file.enc && \
    ./wrapper -d -v -p file.enc -o file.dec \
    )
```

To run the benchmarks on key rotation, the following commands can be used:

```bash
./key_rotation.sh -s <start-iteration> -e <end-iteration> -p "<initial-key-plaintext>"
```

Thus, the **total time** for *key initialization*, *encryption*, and *signing* of an object and *decryption* and *signature verification* operations is less than **15 seconds**. To this must be added the time required for *key rotation unrolling*, which varies with the number of epochs.
