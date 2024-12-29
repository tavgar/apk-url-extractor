# APK URL Extractor

**APK URL Extractor** is a Bash script that automates:

1. **Decompiling** an APK using [Apktool](https://ibotpeaches.github.io/Apktool/).  
2. **Searching for URLs** in the resulting decompiled smali/files.  
3. **Filtering** URLs by a specific domain (e.g., `tiktok.com`) or returning **all** URLs.

## Features

- **Easy One-Command Execution**: Just specify the APK file and (optionally) the domain to filter.  
- **Automatic Decompilation**: No need to manually run `apktool d`; the script does that for you.  
- **Regex-based URL Filtering**: Quickly find references to `http://` or `https://` strings in `.smali`, `.json`, `.xml`, etc.  
- **Unique Results**: Results are sorted and deduplicated to remove repeated URLs.

## Requirements

- **Bash** (tested on Linux/macOS).  
- **[Apktool](https://ibotpeaches.github.io/Apktool/)** (installed and accessible in your `$PATH`).  
- **grep** (with extended regex support).  
- **sort** (standard on most Unix-like systems).

> **Note**: You can install `apktool` on Ubuntu/Debian via `sudo apt-get install apktool`, or follow the [official instructions](https://ibotpeaches.github.io/Apktool/install/).

## Usage

1. **Clone this repository** (or download the script directly):
   ```bash
   git clone https://github.com/<your-username>/apk-url-extractor.git
   cd apk-url-extractor
   ```

2. **Make the script executable**:
   ```bash
   chmod +x apk-url-extractor.sh
   ```

3. **Run the script**:
   ```bash
   ./apk-url-extractor.sh -a /path/to/your.apk [-d domain.com]
   ```

### Command-line Options

- **`-a <apk_file>`**: Path to the APK file you want to analyze. **(Required)**
- **`-d <domain>`**: (Optional) If provided, only URLs containing `<domain>` will be listed. Otherwise, **all** URLs found in the app are displayed.
- **`-h`**: Show help message and usage.

### Examples

```bash
# Extract ALL URLs from myapp.apk
./apk-url-extractor.sh -a myapp.apk

# Extract ONLY URLs containing "tiktok.com"
./apk-url-extractor.sh -a myapp.apk -d tiktok.com

# Extract ONLY URLs containing "example.com"
./apk-url-extractor.sh -a myapp.apk -d example.com
```

## Script Workflow

1. **Decompile**:  
   The script uses `apktool d` to decompile the given APK into a time-stamped folder (e.g., `apk_decompiled_1672536681`).

2. **Construct Regex**:  
   - If a domain is specified, the regex is `https?://[^"'\(\)<>]*<domain>[^"'\(\)<>]*`.
   - If no domain is specified, the regex matches **any** `http://` or `https://` substring.

3. **Search & Filter**:  
   - Recursively `grep` the decompiled folder.  
   - Print **only** the matching URLs (`-o`).  
   - Suppress filenames (`-h`).  
   - Remove duplicates (`sort -u`).

4. **Output**:  
   - The script prints matches to STDOUT.  
   - The decompiled folder remains on disk for further analysis.  
   - You can redirect output to a file:  
     ```bash
     ./apk-url-extractor.sh -a myapp.apk -d tiktok.com > found_tiktok_urls.txt
     ```

## Limitations

- **Obfuscated Apps**: If URLs are constructed dynamically or obfuscated, they may not appear in plain text. You might need advanced static or **dynamic analysis** to uncover them.
- **SSL Pinning / Encrypted Strings**: This script cannot handle runtime-decrypted URLs or bypass SSL pinning. Use [Frida](https://frida.re/) or similar for deeper analysis.

## Troubleshooting

- **“Command not found: apktool”**: Make sure `apktool` is installed and in your `$PATH`.
- **Permission Denied**: Run `chmod +x apk-url-extractor.sh`.
- **No URLs Found**:  
  - Verify the app actually makes network calls.  
  - The URLs might be obfuscated or dynamically generated.
