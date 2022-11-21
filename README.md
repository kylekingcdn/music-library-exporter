<p align="center">
  <a><img src="https://i.imgur.com/nZU1lCj.png" alt="Logo" width="100" height="100"></a>
</p>
<h3 align="center">Music Library Exporter</h3>
<p align="center">A lightweight macOS app used to automatically generate (and customize) an Apple Music/iTunes Music Library XML file.</p>
<p align="center">
  <a href="https://music-exporter.app">Visit our website</a>
  ·
  <a href="https://github.com/kylekingcdn/music-library-exporter/issues/new">Report a bug</a>
  ·
  <a href="https://github.com/kylekingcdn/music-library-exporter/issues/new">Request a feature</a>
</p>
<p align="center">
  <a href="https://apps.apple.com/us/app/music-library-exporter/id1553648567">
    <img src="https://i.imgur.com/Ui2XClS.png" height="50px" alt="Download on the App Store">
  </a>
</p>


## Information

Music Library Exporter allows you to export your library and playlists from the native macOS Music app.

The library is exported as an XML file and is compatible with other applications, services, and tools that rely on the `iTunes Music Library.xml` format.

![Music Library Exporter Screenshot](https://user-images.githubusercontent.com/13585221/203063700-9e5ec0fd-0cca-4991-8408-8b21e222f87e.png)


## Features

- **Automatic Exports**
  - Generate your Music Library XML automatically with a custom defined schedule (even when the app is closed!)
- **Broad Compatibility**
  - The XML library generated by Music Library Exporter is compatible with **Sonos**, **Plex**, **Traktor**, **rekordbox**, and more
- **Song Path Mapping**
  - Re-map song file paths by specifying search and replacement text (useful for remote path mapping in external applications or containers)
- **Custom Playlist Sorting**
  - Override the default sorting of individual playlists with over *30 options*
- **Playlist Exclusion**
  - Slip internal playlists and/or manually specify playlists to exclude
- **Folder Flattening Support**
  - Optionally flatten the hierarchy of your playlists (no folders, all playlists appear top-level)
- **Custom Output Location**
  - Specify the output directory and the filename for the generated XML library file


## Limitations

### Smart Playlist Rules

Music Library Exporter does not support smart playlist rules.

Smart playlists will appear as *regular playlists* for any 3rd party applications/services that use the XML library file generated by *Music Library Exporter*.

This is beneficial in almost all cases as most 3rd party applications do not have proper support for the smart playlist rules defined in the XML library generated by Apple Music/iTunes.


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
   cp src/Config/Common/Sentry.base.xcconfig src/Config/Common/Sentry.xcconfig
   ```
1. Update codesigning configuration as desired (`src/Config/Common/Signing.xcconfig`)
1. Open `Music Library Exporter.xcodeproj` in Xcode
1. Specify the build target (if required)
1. Build!


## Command-line usage

Aside from the main Music Library Exporter application, this project also includes a command-line program, **`music-library-exporter`**.

This command-line program has all of the same functionality of the main application except for scheduling. Scheduling exports with the CLI tool can be accomplished by using a launchd service. There is more information on creating a launchd service [below](#scheduling-exports-with-a-launchd-service).

The `music-library-exporter` CLI tool is *not* available in the macOS App Store verison of the application.

`music-library-exporter` can be downloaed from our [releases page](https://github.com/kylekingcdn/music-library-exporter/releases). We recommend copying the `music-library-exporter` CLI tool to your `/usr/local/bin` directory.

### Basic syntax

```
music-library-exporter <command> [options]
```

There are two main commands used by music-library-exporter: `export` and `print`. Various options are supported by each command (more information below).

### Exporting your library

Exporting can be accomplished by running `music-library-exporter export`.

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
- `--localhost_path_prefix`

*Note: Both `--output_path` and `--music_media_dir` are _manadatory_ unless you are using `--read_prefs` (valid values must be set in the application).*

### Printing playlist information

Printing can be accomplished by running `music-library-exporter print`.

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

music-library-exporter can be used with a launchd service to handle scheduled exports. An [example launchd service](https://github.com/kylekingcdn/music-library-exporter/blob/master/Examples/local.music-library-exporter.plist) property list is included in the Examples directory.

To install the service, copy it to `~/Library/LaunchAgents/` and run `launchctl load ~/Library/LaunchAgents/local.music-library-exporter.plist`.

More information on launchd services can be found [here](https://www.launchd.info). I personally recommend using the [LaunchControl](https://www.soma-zone.com/LaunchControl/) application to manage launchd services.

### Detailed option information

**`--read_prefs`**

> Allows for importing settings from the Music Library Exporter app's preferences.
> You may override any of the app's preferences by suppolying the corresponding option for the preference.

**`--music_media_dir <music_media_dir>, -m <music_media_dir>`**

> The value of this option MUST be set to the corresponding value in your Music app's Preferences.
> It can be found under: Preferences > Files > Music Media folder location.
> music-library-exporter can NOT validate what is entered for this value, so it is important to ensure that it is accurate.
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
> For an example of what this means, compare the output of `music-library-exporter print` to the output of `music-library-exporter print --flatten`,
> (Note: there will only be an observable difference if you are managing your music library's playlists with folders).

**`--exclude_internal, -n`**

> If set, this flag will prevent any internal playlists from being included in the exported library.
> Internal playlists include (but are not limited to): 'Library', 'Music', 'Downloaded', etc...

**`--exclude_ids <playlist_ids>, -e <playlist_ids>`**

> A comma separated list of playlist ids that you would like to exclude from the generated library.
> Playlist IDs can be determined by running the print command: `music-library-exporter print`
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
> `{PLAYLIST_ID}:{SORT_PROPERTY}-{SORT_ORDER}`
>
> Where:
> - `PLAYLIST_ID`  is the persistent ID of the playlist. Playlist IDs can be found with: `music-library-exporter print`
> - `SORT_PROPERTY`  is one of the values listed in the table below
> - `SORT_ORDER`   is either `a` (for ascending) or `d` (for descending)
>
> Example:
>
> `--sort "3245022223634E16:title-a,3FD8F8235DE3C8C9:dateadded-d"`
>
> | Sort property name | Sort property value |
> | ------------------ | -------------       |
> | Album              | album               |
> | Album Artist       | albumartist         |
> | Album Rating       | albumrating         |
> | Artist             | artist              |
> | Beats Per Minute   | bpm                 |
> | Bit Rate           | bitrate             |
> | Category           | category            |
> | Comments           | comments            |
> | Composer           | composer            |
> | Date Added         | dateadded           |
> | Date Modified      | datemodified        |
> | Description        | description         |
> | Disc Number        | discnumber          |
> | Genre              | genre               |
> | Grouping           | grouping            |
> | Kind               | kind                |
> | Last Played        | lastplayed          |
> | Last Skipped       | lastskipped         |
> | Movement Name      | movementname        |
> | Movement Number    | movementnumber      |
> | Plays              | plays               |
> | Rating             | rating              |
> | Release Date       | releasedate         |
> | Sample Rate        | samplerate          |
> | Size               | size                |
> | Skips              | skips               |
> | Time               | time                |
> | Title              | title               |
> | Track Number       | tracknumber         |
> | Work               | work                |
> | Year               | year                |

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

**`--localhost_path_prefix`**

> Enabling this flag will prefix all track location paths with `localhost`.
> This option is compatible with path remapping.
>
> Note: this option will only be needed and/or useful in a very limited set of environments (e.g. Plex on Synology)
>
> Example result: track paths will be generated as `file://localhost/Path/to/track.mp3` rather than `file:///Path/to/track.mp3`.


## Support

Have a question, comment or suggestion?

Please feel free to send us an [email](mailto:support@music-exporter.app) or [open an issue](https://github.com/kylekingcdn/music-library-exporter/issues/new).

We would love to hear from you!


## License

This project is licensed under the **GNU General Public License v3.0**. See [`LICENSE`](https://github.com/kylekingcdn/music-library-exporter/blob/master/LICENSE) for more information.


## Acknowledgements

- [OrderedDictionary](https://github.com/nicklockwood/OrderedDictionary)
- [XPMArgumentParser](https://github.com/mysteriouspants/ArgumentParser)
