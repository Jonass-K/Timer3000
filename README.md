#  Timer3000

![Screenshot](./Screenshot.png)

## Installation:

You can easily download the app from the newest [release](https://github.com/Jonass-K/Timer3000/releases/) and install it with a little tweak.

The problem is, apple just allows signed apps to be installed. This means that macOS adds an attribute (tag) you first need to remove, to install it.

```
cd <path_of_downloaded_folder>
xattr -d com.apple.quarantine Timer3000.app
```

Another way would be to just download the source code, Xcode and the build, archive and copy the app for yourself.
