# USAGE

## Script usage

The script can be used as follows:

```bash
./wrapper.sh [options]
```

The options are:

| Option            | Description                |
| ----------------- | -------------------------- |
| `-h, --help`      | Show help                  |
| `-d, --decrypt`   | Decrypt the file           |
| `-e, --encrypt`   | Encrypt file               |
| `-s, --sign`      | Sign file                  |
| `-v, --verify`    | Verify signature           |
| `-k, --key-path`  | Key path in TPM            |
| `-o, --output`    | Output file name           |
| `-p, --file-path` | File path                  |
| `-i, --init`      | Initialize TPM keys        |
| `--encption-key`  | Encryption key path in TPM |
| `--sign-key`      | Signing key path in TPM    |

## Example

The following example shows how to use the script to encrypt a file:

```bash
# Initialize the TPM keys
./wrapper.sh -i
```

```bash
# Encrypt the file
./wrapper.sh -e -p <file_path> -o <output_file>
```

```bash
# Decrypt the file
./wrapper.sh -d -p <file_path> -o <output_file>
```

```bash
# Encrypt and Sign the file
./wrapper.sh -e -s -p <file_path> -o <output_file>
```

```bash
# Decrypt and Verify the file   
./wrapper.sh -d -v -p <file_path> -o <output_file>
```
