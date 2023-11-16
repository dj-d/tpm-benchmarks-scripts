# USAGE

## Wrapper

Wrapper is a script that "wrap" the TPM commands to encrypt, decrypt, sign and verify a file.

### Usage

The script can be used as follows:

```bash
./wrapper.sh [options]
```

The options are:

| Option            | Description                | Optional | Default         |
| ----------------- | -------------------------- | -------- | --------------- |
| `-h, --help`      | Show help                  |          |                 |
| `-d, --decrypt`   | Decrypt the file           |          |                 |
| `-e, --encrypt`   | Encrypt file               |          |                 |
| `-s, --sign`      | Sign file                  | &check;  |                 |
| `-v, --verify`    | Verify signature           | &check;  |                 |
| `-k, --key-path`  | Key path in TPM            |          |                 |
| `-o, --output`    | Output file name           |          |                 |
| `-p, --file-path` | File path                  |          |                 |
| `-i, --init`      | Initialize TPM keys        |          |                 |
| `--enc-key`       | Encryption key path in TPM | &check;  | HS/SRK/ENC_KEY  |
| `--sign-key`      | Signing key path in TPM    | &check;  | HS/SRK/SIGN_KEY |
| `--signature`     | Signature path             | &check;  | signature       |

### Example

The following example shows how to use the script to encrypt a file:

#### Initialization

```bash
# Initialize the TPM keys
./wrapper.sh -i

# or if you want to creare a custom key

## custom encryption key
./wrapper.sh -i --enc-key <enc-key-path>

## custom signing key
./wrapper.sh -i --sign-key <sign-key-path>

## custom encryption key and signing key
./wrapper.sh -i --enc-key <enc-key-path> --sign-key <sign-key-path>
```

#### Encryption

```bash
# Encrypt the file
./wrapper.sh -e -p <file_path> -o <output_file>

# or if you want to sign the file

./wrapper.sh -e -s -p <file_path> -o <output_file>

# or if you want to sign the file and specify the signature path

./wrapper.sh -e -s -p <file_path> -o <output_file> --signature <signature_path>

# or if you want to use a custom encryption key and signing key

./wrapper.sh -e -s -p <file_path> -o <output_file> --enc-key <enc-key-path> --sign-key <sign-key-path>
```

#### Decryption

```bash
# Decrypt the file
./wrapper.sh -d -p <file_path> -o <output_file>

# or if you want to verify the signature

./wrapper.sh -d -v -p <file_path> -o <output_file>

# or if you want to verify the signature and specify the signature path

./wrapper.sh -d -v -p <file_path> -o <output_file> --signature <signature_path>

# or if you want to use a custom encryption key and signing key

./wrapper.sh -d -v -p <file_path> -o <output_file> --enc-key <enc-key-path> --sign-key <sign-key-path>
```

## Key Rotation

The key rotation is a script that rotates the encryption and signing keys speed using the TPM.

### Requirements

It's mandatory to initialize the TPM keys before running the script. [Initialization](#initialization)

### Usage

The script can be used as follows:

```bash
./key_rotation.sh [options]
```

The options are:

| Option            | Description     | Optional | Default         |
| ----------------- | --------------- | -------- | --------------- |
| `-h, --help`      | Show help       |          |                 |
| `-p, --plaintext` | Plaintext file  |          |                 |
| `-s, --start`     | Start iteration | &check;  | 1               |
| `-e, --end`       | End iteration   |          |                 |
| `--enc-key`       | Encryption key  | &check;  | HS/SRK/ENC_KEY  |
| `--sign-key`      | Signing key     | &check;  | HS/SRK/SIGN_KEY |

### Example

The following example shows how to use the script to rotate the keys:

```bash
# Rotate the keys
./key_rotation.sh -p <plaintext_file> -s <start_iteration> -e <end_iteration>

# or if the key are different from the default ones

./key_rotation.sh -p <plaintext_file> -s <start_iteration> -e <end_iteration> --enc-key <enc_key-path> --sign-key <sign_key-path>
```

After the execution, the script displays the time taken to decrypt and verify the files and a message indicating if the decrypted file is equal to the plaintext file.
