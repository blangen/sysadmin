New Laptop
======
inst_laptop.sh is a script to set up an OS X computer for web development.

This script can be ran multiple times on the same machine safely, as it will
install, update, or skip packages with idempotence.

Requirements
------------

I support clean installations of these operating systems:

* [macOS Sierra](https://www.apple.com/macos/sierra/) (10.12)
* OS X El Capitan (10.11)
* OS X Yosemite (10.10)
* OS X Mavericks (10.9)

Older versions may work but aren't regularly tested. Bug reports for older
versions are welcome.

Install
-------
Begin by opening the Terminal application on your Mac. The easiest way to open
an application in OS X is to search for it via [Spotlight]. The default
keyboard shortcut for invoking Spotlight is `command-Space`. Once Spotlight
is up, just start typing the first few letters of the app you are looking for,
and once it appears, press `return` to launch it.

In your Terminal window, copy and paste the command below, then press `return`.

```sh
bash <(curl -s https://cdn.rawgit.com/blangen/sysadmin/cfa5576f/laptop/inst_newlaptop.sh)
```

The [script](https://github.com/blangen/sysadmin/blob/master/laptop/mac) itself is
available in this repo for you to review if you want to see what it does
and how it works.

Note that the script will ask you to enter your OS X password at various
points. This is the same password that you use to log in to your Mac.

**Once the script is done, quit and relaunch Terminal.**

Debugging
---------

Your last Laptop run will be saved to a file called `new_laptop.log` in your home
folder. Read through it to see if you can debug the issue yourself.

What it sets up
---------------

* [Bundler] for managing Ruby gems
* [chruby] for managing [Ruby] versions
* [Flux] for adjusting your Mac's display color so you can sleep better
* [GitHub Desktop] for setting up your SSH keys automatically
* [Heroku Toolbelt] for deploying and managing Heroku apps
* [Homebrew] for managing operating system libraries
* [Homebrew Cask] for quickly installing Mac apps from the command line
* [Homebrew Services] so you can easily stop, start, and restart services
* [hub] for interacting with the GitHub API
* [PhantomJS] for headless website testing
* [Postgres] for storing relational data
* [ruby-install] for installing different versions of Ruby
* [Sublime Text 3] for coding all the things
* [Zsh] as your shell (if you opt in)

[Bundler]: http://bundler.io/
[chruby]: https://github.com/postmodern/chruby
[Flux]: https://justgetflux.com/
[GitHub Desktop]: https://desktop.github.com/
[Heroku Toolbelt]: https://toolbelt.heroku.com/
[Homebrew]: http://brew.sh/
[Homebrew Cask]: http://caskroom.io/
[Homebrew Services]: https://github.com/Homebrew/homebrew-services
[hub]: https://github.com/github/hub
[PhantomJS]: http://phantomjs.org/
[Postgres]: http://www.postgresql.org/
[Ruby]: https://www.ruby-lang.org/en/
[ruby-install]: https://github.com/postmodern/ruby-install
[Sublime Text 3]: http://www.sublimetext.com/3
[Zsh]: http://www.zsh.org/

It should take less than 15 minutes to install (depends on your machine and
internet connection).

The script also lightly customizes your shell prompt so that it displays your
current directory in orange, followed by the current Ruby version or gemset in
green, and sets the prompt character to `$`. It also allows you to easily
distinguish directories from files when running `ls` by displaying directories
in a different color.

How to switch your shell back to bash from zsh (or vice versa)
--------------------------------------------------------------
1. Find out which shell you're currently running: `echo $SHELL`
2. Find out the location of the shell you want to switch to. For example, if
   you want to switch to `bash`, run `which bash`.
3. Verify if the shell location is included in `/etc/shells`.
   Run `cat /etc/shells` to see the contents of the file.
4. If the location of the shell is included, run `chsh -s [the location of the shell]`.
   For example, if `which bash` returned `/bin/bash`, you would run `chsh -s /bin/bash`.

   If the location of the shell is not in `/etc/shells`, add it, then run the `chsh` command.
   If you have Sublime Text, you can open the file by running `subl /etc/shells`.


