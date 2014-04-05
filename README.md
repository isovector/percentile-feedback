# Percentile Feedback

Percentile feedback implementation

## About

Based on [code by Nick Winter](http://www.nickwinter.net/codecombat-stats), made available under the Apache License 2.0.

Read more about percentile feedback on [Seth Robert's blog](http://blog.sethroberts.net/category/percentile-feedback/).

## Questions

<dl>
<dt>What is custom midnight?</dt>
<dd>By default, the graph origin starts at midnight. But if you typically wake up at 8am, the first 8 hours of your graph are going to show zero hours worked. And when you finally start working, your efficiency score is going to be very low. Conversly, if you're a bit of a night owl, any work you do after midnight is going to show up on the next day's graph. To get around this problem, you can specify a custom midnight. Say, 6am. This marks the point you <em>actually</em> consider it to be a new day.</dd>
<dt>How are past data points plotted?</dt>
<dd>@@</dd>
<dt>Why does my percentile show as "50%" when I very nearly beat my most productive day so far?
</dt>
<dd>
<p>Percentiles are more like ranks. Imagine that you're competing in a race with two other people. Whatever order you all finish in, the positions are 1st, 2nd, and 3rd. If you win by just one second, you still get the gold medal for coming 1st, just as you do when you beat your closest competitor by several minutes.

<p>Now, imagine if instead of ranks such as "1st" and so on, we mapped these into percentages instead. 1st becomes 100%, 2nd becomes 50%, and 3rd becomes 0%. This is why if you logged two previous days, and then very nearly beat your most productive day on the third day, your percentile score will be 50%. Even though you came very close, you're still 2nd!

<p>So, why not just say "2nd" instead of 50%? Well, think about what happens when you log more days. Imagine that on the 5th day, you have your least productive day so far, and so you're 5th. In this case, "5th" means last. Now imagine that after logging 60 days, you come 5th. In this case, 5th is one of your most productive days! In other words, if you come 5th in a race with only five people in it, then you're last. If you came 5th in a race with 60 people in it, then you did quite well. In fact, you finished in the top 8.33% of all competitors. This is your percentile score.

<p>Percentile scores are a way of giving a normalised rank out of the total number of competitors. When you're competing against your previous scores, you'll have much more finely balanced percentiles the more days you log.
</dd>
</dl>

## Running

Load `index.html` in your browser.

The HTML will run as long as there as a `data.js` file.

This file can be created however you like. At the moment, there are only a handful of ways provided. But if there's something you'd like to use this with, create an issue, or submit a pull request!

### Manual

Run `data.py --log-period SECONDS` to log `SECONDS` of time.

This command logs your data to the `periods.txt` file, which is authoritative record of your work time. Keep it safe. You can then run `data.py --convert-log periods.txt` to generate the `data.js` file.

If you're using a tool that is able to call a script with a number of seconds, this method will work for you. One example is a Pomodoro app that executes some AppleScript upon completion.

There is an app called [Timer](http://martakostova.github.io/timer/) that is able to run AppleScript.

The AppleScript might look something like this:

```
do shell script "/path/to/data.py --log-period 3600"
do shell script "/path/to/data.py --convert-log /path/to/periods.txt"
display notification "Logged 60 minutes of work!"
```

This logs a period of 3600 seconds (one hour) and displays a system notification.

If you are using a UNIX-like system, there may be similar things you can do. If you have a neat idea for this, please open an issue or submit a pull request!

### Emacs

If you use the clock feature of Org, you can parse an Org file and send this to the tool.

Your Org file will look like this:

```
* Sample Task
CLOCK: [2014-03-31 Mon 16:50]--[2014-03-31 Mon 17:32] =>  0:42
CLOCK: [2014-03-31 Mon 15:23]--[2014-03-31 Mon 15:51] =>  0:28
CLOCK: [2014-03-31 Mon 15:03]--[2014-03-31 Mon 15:10] =>  0:07
```

Run `data.py --convert-org FILE` to create the `data.js` file.

Alternatively, configure Emacs to run this command every time you save the file.

```lisp
;; Org clock percentile feedback integration

(setq my-org-file "/path/to/times.org")
(setq my-org-py "/path/to/percentile-feedback/org.py")

(defun process-org-file ()
  (when (string-equal (buffer-file-name) my-org-file)
    (shell-command (concat "python " my-org-py " --convert-org " my-org-file))
    (message "Processed org file")))

(add-hook 'after-save-hook 'process-org-file)
```

## License

Licenced under the Apache License 2.0.

See [LICENCE.md](LICENSE.md) and [NOTICE.md](NOTICE.md) for more information.
