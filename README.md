# emacs
emacs installation and config

## Download Emacs for macOS
[Emacs 26.3](https://emacsformacosx.com/)

MacOS comes with Emacs 22 already preinstalled in /usr/bin/emacs. It can't be removed without disabling mac's [system integrity protection](https://developer.apple.com/library/archive/documentation/Security/Conceptual/System_Integrity_Protection_Guide/ConfiguringSystemIntegrityProtection/ConfiguringSystemIntegrityProtection.html). Instead of doing that, make sure that `emacs` command always calls the most up-to-date installation by adding the following scripts to /usr/local/bin and making sure that this path supersedes /usr/bin in $PATH. 

`emacs`:
```
#!/bin/sh
/Applications/Emacs.app/Contents/MacOS/Emacs "$@"
```

`ec`:
```
#!/bin/sh
which osascript > /dev/null 2>&1 && osascript -e 'tell application "Emacs" to activate'
emacsclient -c "$@"
```
Note: run `sudo chmod x+a <script name>` to convert script to executable.

Following instructions from [here](https://emacsformacosx.com/tips)





