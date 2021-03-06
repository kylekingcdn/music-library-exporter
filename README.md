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
   git clone --recurse-submodules 'https://github.com/kylekingcdn/music-library-exporter.git'
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


## Command-line usage

Aside from the main Music Library Exporter application, this project also includes a command-line program called **`library-generator`**.

This command-line program has all of the same functionality of the main application except for scheduling. This can be accomplished by using a launchd service. There is more information on creating a launchd service [below](#scheduling-exports-with-a-launchd-service).

library-generator is *not* available in the macOS App Store verison of the application. library-generator can be downloaed from our [releases page](https://github.com/kylekingcdn/music-library-exporter/releases). We recommend copying library-generator to your `/usr/local/bin` directory.

### Basic syntax

```
library-generator <command> [options]
```

There are two main commands used by library-generator: `export` and `print`. Various options are supported by each command (more information below).

### Exporting your library

Exporting can be accomplished by running `library-generator export`.

The export command accepts the following options (detailed information on each option [here](#detailed-option-information)):
- `--read_prefs`
- `--music_media_dir <music_media_dir>, -m <music_media_dir>`
- `--output_path <path>, -o <path>`
- `--flatten, -f`
- `--exclude_internal, -n`
- `--exclude_ids <playlist_ids>, -e <playlist_ids>`
- `--sort <playlist_sorting_specifer>`
- `--remap_search <text_to_find>, -s <text_to_find>`
- `--remap_replace <replacement text>, -r <replacement text>`

*Note: Both `--output_path` and `--music_media_dir` are _manadatory_ unless you are using `--read_prefs` (valid values must be set in the application).*

### Printing playlist information

Printing can be accomplished by running `library-generator print`.

This command can either be used to determine the ID of a playlist (for use with the export command) or to preview the list of playlists that will be included in your export.

The print command accepts the following options (see detailed information on each option [here](#detailed-option-information)):
- `--read_prefs`
- `--flatten, -f`
- `--exclude_internal, -n`
- `--exclude_ids <playlist_ids>, -e <playlist_ids>`

> *Note:* These options are only really useful if used to preview the playlist hierarchy in the generated library, in which case you should use the same option values as your export command.

### Sharing your configuration/preferences from the main application

If you would like to use the same configuration as specified in the main Music Library Exporter application, you can pass the `--read_prefs` option to either command. Assuming your application's configuration is valid, no other options are required.

You can override any of the application preferences by additionally specifying the option for the corresponding preference.

### Scheduling exports with a launchd service

library-generator can be used with a launchd service to handle scheduled exports. An [example launchd service](https://github.com/kylekingcdn/music-library-exporter/blob/master/Examples/local.library-generator.plist) property list is included in the Examples directory.

To install the service, copy it to `~/Library/LaunchAgents/` and run `launchctl load ~/Library/LaunchAgents/local.library-generator.plist`.

More information on launchd services can be found [here](https://www.launchd.info). I personally recommend using the [LaunchControl](https://www.soma-zone.com/LaunchControl/) application to manage launchd services.

### Detailed option information

**`--read_prefs`**

> Allows for importing settings from the Music Library Exporter app's preferences.
> You may override any of the app's preferences by suppolying the corresponding option for the preference.

**`--music_media_dir <music_media_dir>, -m <music_media_dir>`**

> The value of this option MUST be set to the corresponding value in your Music app's Preferences.
> It can be found under: Preferences > Files > Music Media folder location.
> library-generator can NOT validate what is entered for this value, so it is important to ensure that it is accurate.
>
> NOTE: This option is mandatory unless the value is being imported via `--read_prefs`.
>
> Example:
>
> `--music_media_dir "/Macintosh HD/Users/Kyle/Music/Music/Media"`

**`--output_path <path>, -o <path>`**

> The desired output path of the generated library (directory and filename).
> Export behaviour is undetermined when using file extensions other than '.xml'.
> If you must change the extension: first run the export command and then run 'mv' afterwards to relocate it to the desired location.
>
> NOTE: This option is mandatory unless the value is being imported via `--read_prefs`.
>
> Example:
>
> `--output_path ~/Music/Music/GeneratedLibrary.xml`

**`--flatten, -f`**

> Setting this flag will flatten the generated playlist hierarchy, or in other words, folders will not be included.
> The playlists contained in any folders are still included in the exported library, they simply appear 'top-level'.
> For an example of what this means, compare the output of `library-generator print` to the output of `library-generator print --flatten`,
> (Note: there will only be an observable difference if you are managing your music library's playlists with folders).

**`--exclude_internal, -n`**

> If set, this flag will prevent any internal playlists from being included in the exported library.
> Internal playlists include (but are not limited to): 'Library', 'Music', 'Downloaded', etc...

**`--exclude_ids <playlist_ids>, -e <playlist_ids>`**

> A comma separated list of playlist ids that you would like to exclude from the generated library.
> Playlist IDs can be determined by running the print command: `library-generator print`
>
> Example:
>
> `--exclude_ids 1803375142671959318,5128334259688473588,57194740367344335011`

**`--sort <playlist_sorting_specifers>`**

> This option allows you to override the sorting of individual playlists.
> The value for this option is a comma-separated list of 'playlist sort specifier's.
>
> A playlist sort specifier has the following format:
>
> `{PLAYLIST_ID}:{SORT_COLUMN}-{SORT_ORDER}`
>
> Where:
> - `PLAYLIST_ID`  is the persistent ID of the playlist. Playlist IDs can be found with: `library-generator print`
> - `SORT_COLUMN`  is one of the following:  `title`, `artist`, `albumartist`, `dateadded`
> - `SORT_ORDER`   is either `a` (for ascending) or `d` (for descending)
>
> Example:
>
> `--sort "3245022223634E16:title-a,3FD8F8235DE3C8C9:dateadded-d"`

**`--remap_search <text_to_find>, -s <text_to_find>`**

> Specify the text you would like removed/replaced in each song's filepath.
> Using the remap option allows you to change the the root music directory in the filepath for each track in your library.
> This is especially useful when you are using your generted XML library in a remote or containerized environment (e.g. Plex)
>
> Example:
>
> `--remap_search "/Users/Kyle/Music/Music/Media.localized/Music" --remap_replace "/data/music"`

**`--remap_replace <replacement text>, -r <replacement text>`**

> Specify the new text you would like to use in each song's filepath.
> If included, you must also specify the `--remap_search` option.
> For example usage, please see the information for the `--remap_search` option above.


## Support

Have a question, comment or suggestion?

Please feel free to send us an [email](mailto:support@music-exporter.app) or [open an issue](https://github.com/kylekingcdn/music-library-exporter/issues/new).

We would love to hear from you!


## License

This project is licensed under the **GNU General Public License v3.0**. See [`LICENSE`](https://github.com/kylekingcdn/music-library-exporter/blob/master/LICENSE) for more information.


## Acknowledgements

- [OrderedDictionary](https://github.com/nicklockwood/OrderedDictionary)
- [XPMArgumentParser](https://github.com/mysteriouspants/ArgumentParser)
