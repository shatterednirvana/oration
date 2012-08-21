# Oration [![Travis CI status](https://secure.travis-ci.org/ariofrio/oration.png)](http://travis-ci.org/ariofrio/oration) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/ariofrio/oration)

## Installation

### Linux

    apt-get install rubygems || yum install rubygems
    [sudo] gem install oration

### Windows

 1. [Install Ruby](http://rubyinstaller.org/)

 2. Open a Terminal (press <kbd>Win</kbd>-<kbd>R</kbd>, type `cmd`, and press <kbd>Enter</kbd>) and install Oration:

        gem install oration

## Usage

 1. Get some Python, Java or Go code and run: `oration --help`. Go is not supported on Azure, and Java is not supported on AppEngine.

 2. Run your app locally or deploy it. See `README.md` for instructions 
    (AppEngine: to do, [Azure][azure-readme]).

  [azure-readme]: https://github.com/ariofrio/oration/blob/master/templates/azure/py/README.md

## Hacking

To get the latest version of Oration from GitHub, run:

    gem install bundler
    git clone https://ariofrio@github.com/ariofrio/oration.git
    cd oration
    bundle install
    bundle exec oration [PARAMS...]

### Testing

 1. Install Python.
 1. Install [setuptools][] or [distribute][].
 2. Install [Pip][].
 3. `pip install webapp2 webob rocket`

  [setuptools]: http://pypi.python.org/pypi/setuptools
  [distribute]: http://pypi.python.org/pypi/distribute
  [pip]: http://www.pip-installer.org/en/latest/installing.html#using-the-installer

## Roadmap

See [ROADMAP.md][].

  [roadmap.md]: https://github.com/ariofrio/oration/blob/master/ROADMAP.md

