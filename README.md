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
- The time to **decrypt** and **verify** a file took about 3 seconds.

To run the benchmarks, the following command can be used:

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

**Total time** is less than 15 seconds *per user*.
