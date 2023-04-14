# hAbitti

A shell script is designed to create a modified version of Abitti, an educational exam environment software used in Finnish schools, with elevated privileges and access to internet.

## Requirements

Linux-based operating system (tested on Ubuntu 20.04.5)
xorriso installed via your preferred package manager
Access to sudo or a root account

## Usage

Clone the repository using `git clone https://github.com/Trimpsuz/habitti`

Run the script: Execute the script with root privileges using the following command: `sudo ./habittiBuilder.sh`

Extract the `filesystem.squashfs` of your preferred Abitti version into the directory

If the debian live image is not downloaded, the script will automatically download it for you

---

### Disclaimer

The software is provided as-is and without any warranties or guarantees. It is intended for educational purposes only and should not be used in a real exam environment. The modifications made by the script may not be suitable for all use cases. Read the [license](LICENSE) file for more details.
