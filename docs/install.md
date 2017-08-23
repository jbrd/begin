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

* (Required) Install the Ruby development toolchain:

  ```bash
  sudo apt-get install ruby-dev
  ```

* (Required) Install CMake:

  ```bash
  sudo apt-get install cmake
  ```

* (Required) Install pkg-config:

  ```bash
  sudo apt-get install pkg-config
  ```

* (Required) Install begin:

  ```bash
  gem install begin_cli
  ```

## Mac OS X

* (Recommended) Install a Package Manager (such as Homebrew)

  * Ensure your Package Manager is up-to-date

* (Required) Ensure CMake is installed on your system

* (Required) Ensure Ruby is installed on your system

* (Required) Ensure pkg-config is installed on your syste

* (Required) Install Begin

  ```bash
  gem install begin_cli
  ```

## Windows 10

### Bash for Windows (Recommended)

* (Required) Install Bash for Windows by running the Bash command and following the instructions

* (Required) Launch Bash for Windows and follow the installation instructions above for Linux (Ubuntu)

* This is the easiest way of getting Begin up and running on Windows

### Native (Difficult)

* (Required) Install Ruby

  * The [RubyInstaller](https://rubyinstaller.org/) project makes it easy to
    install on Windows

  * Ensure Ruby has been added to your `PATH` environment variable

  * Ensure the Ruby development toolchain is installed.
  
* (Required) Install the Ruby development toolchain

  * [RubyInstaller](https://rubyinstaller.org/) has an option to install this once
    Ruby has been installed
    
  * Otherwise, run `ridk install` in the Command Prompt to install it

* (Required) Install CMake:

  * Note that the `cmake` package on its own does not contain all the necessary dependencies required to generate MSYS Makefiles. Instead, you should pick one of the following:

    * For 32-bit systems, launch your MSYS environment and run:
    
      ```bash
      pacman -S mingw-w64-i686-cmake
      ```

    * For 64-bit systems, launch your MSYS environment and run:
    
      ```bash
      pacman -S mingw-w64-x86_64-cmake
      ```

* (Required) Install pkg-config:

  * Launch your MSYS environment and run:
  
    ```bash
    pacman -S pkg-config
    ```

* (Required) Install libssh2:

  * Launch your MSYS environment and run:
  
    ```bash
    pacman -S libssh2-devel
    ```

* (Required) Install Rugged (the libgit2 bindings for Ruby that Begin depends on):

  * Launch a Windows command prompt and run:
  
    ```bash
    gem install rugged
    ```

* (Required) Install Begin

  * Launch a Windows command prompt and run:
  
    ```bash
    gem install begin_cli
    ```

