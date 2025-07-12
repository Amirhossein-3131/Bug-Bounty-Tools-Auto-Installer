# **Important Notes**

### **Go Environment Setup (Required for "Go Install" Method)**
If you choose **Method 2 (Go Install)**, ensure your `GOPATH` and `$HOME/go/bin` are correctly set in your environment variables.  

#### **How to Configure Go Path:**
1. Open your `.bashrc` (or `.zshrc` if using Zsh) in a text editor:  
   ```bash
   nano ~/.bashrc
   ```
2. Add the following line at the end of the file:  
   ```bash
   export PATH=$PATH:$HOME/go/bin
   ```
3. Save (`Ctrl+O`, then `Enter`) and exit (`Ctrl+X`).  
4. Apply the changes immediately:  
   ```bash
   source ~/.bashrc
   ```
5. Verify the path is set correctly:  
   ```bash
   echo $PATH
   ```
   (You should see `$HOME/go/bin` included.)

### **Why This Matters**
- Without this, tools installed via `go install` won't be accessible from the command line.
- Some tools (like `katana`, `gau`, `waybackurls`, etc.) require this for proper execution.

This step is **not needed** if you choose **Method 1 (Binary Install)**.  
