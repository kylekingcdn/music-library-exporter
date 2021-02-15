<p align="center">
  <a><img src="https://i.imgur.com/nZU1lCj.png" alt="Logo" width="100" height="100"></a>
</p>
<h3 align="center">Music Library Exporter</h3>
<p align="center">A lightweight macOS application that brings back automated iTunes Library XML generation</p>
<p align="center">
  <a href="https://music-exporter.app">Visit our website</a>
  ·
  <a href="https://github.com/kylekingcdn/music-library-exporter/issues">Report a bug</a>
  ·
  <a href="https://github.com/kylekingcdn/music-library-exporter/issues">Request a feature</a>
</p>
<p align="center">
  <a href="https://apps.apple.com/us/app/music-library-exporter/id1553648567">
    <img src="https://i.imgur.com/Ui2XClS.png" height="50px" alt="Download on the App Store">
  </a>
</p>


## Information
Music Library Exporter allows you to export your library and playlists from the native macOS Music app.

The library is exported in an XML format, and is compatible with other applications, services, and tools that rely on the Music (previously iTunes) XML library format.

![Music Library Exporter Screenshot](https://i.imgur.com/38obfhV.jpg)


## Features
- Automatically export your library with a custom set schedule (even when the app is closed!)
- Manually exclude specific playlists
- Customize playlist sorting
- Optionally flatten the playlist hierarchy (no folders, all playlists appear top-level)
- Specify output directory/filename for your generated library
- Perform a find & replace on the file paths of songs to allow for remote path mapping in external applications


## Setup
1. Clone the repo
   ```
   git clone 'https://github.com/kylekingcdn/music-library-exporter.git'
   ```
1. Change to project directory
   ```
   cd music-library-exporter
   ```
1. Copy Sentry.base.xcconfig (this is required for the xcode build to run properly)
   ```
   cp Config/Common/Sentry.base.xcconfig Config/Common/Sentry.xcconfig
   ```
1. Update codesigning configuration as desired (`Config/Common/Signing.xcconfig`)
1. Open `Music Library Exporter.xcodeproj` in Xcode
1. Specify the build target (if required)
1. Build!


## License
This project is licensed under the **GNU General Public License v3.0**. See [`LICENSE`](https://github.com/kylekingcdn/music-library-exporter/blob/master/LICENSE) for more information.


## Acknowledgements
* [OrderedDictionary](https://github.com/nicklockwood/OrderedDictionary)
* [XPMArgumentParser](https://github.com/mysteriouspants/ArgumentParser)
