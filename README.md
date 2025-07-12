# Bug Bounty Tools Auto Installer

This script is a helper tool designed for quick and automated installation of a set of commonly used **Bug Bounty** and **Cybersecurity** tools on Linux servers.

By running this script, you can easily install popular tools like Katana, gau, waybackurls, gowitness, dalfox, and more, without hassle and be ready to start your bug bounty activities.

---

## Features

* Automatic system package update and essential dependency installation
* Two installation methods:

  * Download and install pre-built binaries
  * Install via Go and relevant package managers (go install, apt, pip)
* Additional tools installation like `arjun`, `cewl`, `feroxbuster`, and `lostools`
* Automatic cleanup of temporary files after installation

---

## Prerequisites

* Debian/Ubuntu-based Linux distribution (apt-based)
* `sudo` privileges
* Internet connection to download the tools

---

## Usage

1. Download or save the script file to your server:

```bash
wget https://your-repo-link/bugbounty-tools-installer.sh
```

2. Make the script executable:

```bash
chmod +x bugbounty-tools-installer.sh
```

3. Run the script:

```bash
sudo ./bugbounty-tools-installer.sh
```

4. When prompted, select the installation method:

```
Choose installation method for all tools:
1) Install all tools via binaries (download & move)
2) Install all tools via go install / apt / pip
Enter choice (1 or 2):
```

Enter your preferred option (1 or 2) and wait for the installation to complete.

---

## Installed Tools

* Katana
* gau (getallurls)
* waybackurls
* deduplicate
* gowitness
* dalfox
* ffuf
* httpx
* kiterunner
* nikto
* sqlmap
* arjun
* cewl
* feroxbuster
* lostools

---

## Important Notes

* Ensure that `GOPATH` and the `$HOME/go/bin` path are correctly set if you choose the Go install method.
* Installing Go-based tools may require Go version 1.18 or higher.
* This script is designed for Debian-based distributions and may need modifications for other distros.

---

## Contribution

If you have suggestions to add more tools or improve the script, feel free to contribute!
Please submit a Pull Request or open an Issue in the GitHub repository.



