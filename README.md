The new desktop app for HDS

## Features

- Local connection for one overlay and one watch
- Connection support:
  - Overlays with websocket
  - Watches with REST connections

## Getting started

1. Download the binary for your platform [here](https://github.com/Rexios80/hds_desktop/releases/latest).
2. Complete the steps required by your platform to run the app

<details>
<summary>Windows</summary>

1. Run the downloaded file
2. Click "Allow access" on this popup
![](https://i.imgur.com/CZr6Wcs.png)
</details>
   
<details>
<summary>MacOS</summary>

1. Run the following in a terminal:
```bash
chmod +x hds_desktop_macos_intel
```
OR
```bash
chmod +x hds_desktop_macos_apple_silicon
```

2. Press "OK" on this popup:
![](https://i.imgur.com/2ZLn590.png)

3. Open System Preferences > Security & Privacy > General and click "Open Anyway"
![](https://i.imgur.com/CcyEWa3.png)

4. Click "Open" on this popup
![](https://i.imgur.com/JpTF1wR.png)
</details>

<details>
<summary>Linux</summary>

1. Run the following in a terminal:
```bash
chmod +x hds_desktop_linux
```

2. Run the app
</details>

## Usage

1. Disable HDS Cloud in the watch app and overlay settings
2. The desktop app will list possible IP addresses of your machine. Pick the correct one and input it into the watch app settings.
3. Everything else is the same as with HDS Cloud

## Additional information

If you need to change the port, run the binary with the `--port` flag

For additional help, join the [Discord server](https://discord.gg/FayYYcm)