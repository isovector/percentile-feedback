# Percentile Feedback

Percentile feedback implementation

## About

Based on [code by Nick Winter](http://www.nickwinter.net/codecombat-stats), made available under the Apache License 2.0.

Read more about percentile feedback on [Seth Robert's blog](http://blog.sethroberts.net/category/percentile-feedback/).

## Running

Load `index.html` in your browser.

The HTML will run as long as there as a `data.js` file.

This file can be created however you like. At the moment, there are only a handful of ways provided. But if there's something you'd like to use this with, create an issue, or submit a pull request!

### Manual

Run `log.py SECONDS` to log `SECONDS` of time.

This command logs your data to the `periods.txt` file, which is authoritative record of your work time. Keep it safe. The `data.js` file is then generated each time from the `periods.js` file.

If you're using a tool that is able to call a script with a number of seconds, this method will work for you. One example is a Pomodoro app that executes some AppleScript upon completion.

There is an app called [Timer](http://martakostova.github.io/timer/) that is able to run AppleScript.

The AppleScript might look something like this:

```
do shell script "PATH=/usr/local/bin /path/to/percentile-feedback/log.py 3600"
display notification "Logged 60 minutes of work!"
```

This calls `log.py` with 3600 seconds (one hour) and displays a system notification.

The `PATH` variable is set manually, because Python 3 is installed under `/usr/local/bin` on OS X with [Homebrew](http://brew.sh/) and AppleScript does not pick up your customised `PATH`, so you need to set it explicitly.

If you are using a UNIX-like system, there may be similar things you can do. If you have a neat idea for this, please open an issue or submit a pull request!

### Emacs

If you use the clock feature of Org, you can parse an Org file and send this to the tool.

Your Org file will look like this:

```
* Sample Task
:LOGBOOK:
CLOCK: [2014-03-31 Mon 16:50]--[2014-03-31 Mon 17:32] =>  0:42
CLOCK: [2014-03-31 Mon 15:23]--[2014-03-31 Mon 15:51] =>  0:28
CLOCK: [2014-03-31 Mon 15:03]--[2014-03-31 Mon 15:10] =>  0:07
:END:
```

Run `org.py FILE` to create the `data.js` file.

Alternatively, configure Emacs to run this command every time you save the file.

```lisp
;; Org clock percentile feedback integration

(setq my-org-file "/path/to/times.org")
(setq my-org-py "/path/to/percentile-feedback/org.py")

(defun process-org-file ()
  (when (string-equal (buffer-file-name) my-org-file)
    (shell-command (concat "python3 " my-org-py " " my-org-file))
    (message "Processed org file")))

(add-hook 'after-save-hook 'process-org-file)
```

## License

Licenced under the Apache License 2.0.

See [LICENCE.md](LICENSE.md) and [NOTICE.md](NOTICE.md) for more information.
