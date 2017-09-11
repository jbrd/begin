# Installation Guide

[Back to User Guide](index.html)

## Linux

### Ubuntu

* (Recommended) Ensure your system packages are up-to-date:

  ```bash
  sudo apt-get update
  sudo apt-get upgrade
  ```

* (Required) Install Ruby:

  ```bash
  sudo apt-get install ruby
  ```

* (Required) Install Begin:

  ```bash
  gem install begin_cli
  ```

## Mac OS X

* Ruby ships with OS X. But if you do need to install it, the easiest way to install Ruby on OS X is to use a package manager such as [Homebrew](http://brew.sh/):

  ```bash
  brew install ruby
  ```

* (Required) Install Begin:

  ```bash
  gem install begin_cli
  ```

## Windows 10

### Native

* (Required) Install Ruby

  * The [RubyInstaller](https://rubyinstaller.org/) project makes it easy to
    install on Windows

  * Ensure Ruby has been added to your `PATH` environment variable
  
* (Required) Install Begin

  * Launch a Windows command prompt and run:
  
    ```bash
    gem install begin_cli
    ```

### Windows Subsystem for Linux (WSL)

* Since the Windows 10 Anniversary Update, Windows is now capable of running a user-mode Linux distribution

* (Required) Enable Windows Subsystem for Linux (WSL) and then install Bash for Windows

  * [Read this guide](https://msdn.microsoft.com/en-gb/commandline/wsl/install_guide) for more details

* (Required) Launch Bash for Windows and follow the installation instructions above for Linux (Ubuntu)

