# IceCube-Simulation-Install

[![Build Status](https://github.com/fiedl/icecube-simulation-install/workflows/build/badge.svg)](https://github.com/fiedl/icecube-simulation-install/actions)

This repository provides reproducible install instructions for the icecube-simulation framework.

## Installation on macOS and Ubuntu

The file [install.sh](install.sh) contains instructions on how to install the icecube-simulation framework on macOS and Ubuntu.

 ## Use as Github Action

In order to have icecube-simulation built during a [github-actions workflow](https://github.com/features/actions), you may include this script as workflow step like this:

```yaml
# .github/workflows/build.yml

name: build

jobs:
  build:
    runs-on: ubuntu-18.04

    steps:
    - uses: actions/checkout@v1
    - name: "Checkout and build icecube-simulation framework"
      run: curl https://raw.githubusercontent.com/fiedl/icecube-simulation-install/master/install.sh | sudo bash -v -e
      env:
        RELEASE: V06-01-01
        PLATFORM: ubuntu-18.04
        SVN: ${{ secrets.SVN }}
        SVN_ICECUBE_USERNAME: icecube
        SVN_ICECUBE_PASSWORD: ${{ secrets.SVN_ICECUBE_PASSWORD }}
    - name: "Checkout and build your sub-project against icecube-simulation"
      # ...
```

This will checkout icecube-simulation into `~/icecube/software/icecube-simulation-V06-01-01/src` and build it into `~/icecube/software/icecube-simulation-V06-01-01/debug_build`.

Parameters:
- `RELEASE`: The release number of the icecube-simulation framework you would like to install. May be a release like "V06-01-01", or "trunk", which will fetch the current svn trunk of the framework.
- `PLATFORM`: The operating system, the script will run on. This is needed to install the dependencies with the appropriate package manager. Supported: "ubuntu-18.04", "macOS-10.14"
- `SVN`: The url of our svn repository, ending with "/svn".
- `SVN_ICECUBE_USERNAME`: The svn user to use to fetch the icecube-simulation sourcecode.
- `SVN_ICECUBE_PASSWORD`: The svn password to use to fetch the icecube-simulation sourcecode.

For a working example, have a look at:
- TODO: monopole-generator
- TODO: clsim

## Automated Build Using Vagrant on macOS

In order to have the install scriot run on a virtual machine, this repository provides [Vagrant](http://vagrantup.com) instructions in the [Vagrantfile](Vagrantfile).

```bash
# Clone this repository
git clone git@github.com:fiedl/icecube-simulation-install.git
```

For the automated code checkout to work, you need to provide svn credentials in a secrets file, which is not included in this repository. Please create the following file and provide credentials there:

```bash
# .secrets.sh
export SVN="our svn url"
export SVN_ICECUBE_USERNAME="our svn username"
export SVN_ICECUBE_PASSWORD="our svn password"
```

After that, install and run vagrant:

```bash
# Install Vagrant
brew cask instal vagrant

# Start the virtual machine and run the install instructions
vagrant up
```

After changing the install scripts, rerun via `vagrant provision` or `vagrant reload --provision`.

## Additional Resources

- Based on: Install instructions for monopole-generator: https://github.com/fiedl/monopole-generator-install
- Based on: Install instructions for hole-ice clsim: https://github.com/fiedl/hole-ice-install
- [IceCube documentation on installing on OS X with Python 2](http://software.icecube.wisc.edu/documentation/projects/cmake/supported_platforms/osx.html)
- [Installing icecube-simulation V05-00-07 with Python 2 on macOS Sierra](https://github.com/fiedl/hole-ice-study/blob/master/notes/2016-11-15_Installing_IceSim_on_macOS_Sierra.md)
- [Installing icecube-simulation V05-00-07 with Python 2 in Zeuthen](https://github.com/fiedl/hole-ice-study/blob/master/notes/2018-01-23_Installing_IceSim_in_Zeuthen.md)
- Install instructions by Kevin M.: https://code.icecube.wisc.edu/projects/icecube/ticket/2225#comment:2
- Install instructions for ubuntu: http://software.icecube.wisc.edu/documentation/projects/cmake/supported_platforms/debian_variants.html