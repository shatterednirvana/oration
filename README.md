# Oration [![Travis CI status](https://secure.travis-ci.org/ariofrio/oration.png)](http://travis-ci.org/ariofrio/oration)

(The tests haven't been updated to the latest refactoring in HEAD, stay tuned. :)

## Installation

Install Ruby and RubyGems: use [this][] on Windows, or run the following on
Linux:

    apt-get install ruby rubygems || yum install ruby rubygems

  [this]: http://rubyinstaller.org/

Then open a Terminal (on Windows, press <kbd>Win</kbd>-<kbd>R</kbd>, type
`cmd`, and press Enter) and install Oration:

    gem install oration

## Usage

Navigate to a directory with some Python or Go code and run:

    oration -file <file.py/.go> -function <function> -output ../azure-app -appid <app id> -cloud <appengine/azure>

Note that only Python is supported on Azure at the moment.

This is a description of all the options:

    -file       (Required, takes 1 argument)
                    The name of the file containing the function to execute.
    -function   (Required, takes 1 argument)
                    The name of the function that should be remotely executed.
    -output     (Required, takes 1 argument)
                    Where the newly constructed app should be written to.
    -appid      (Required, takes 1 argument)
                    An identifier to be used for this app (in AppEngine, it's the appid).
    -cloud      (Required, takes 1 argument)
                    The cloud to which this app will be deployed (appengine, azure).
    -h          (Optional, takes 0 arguments)
                    Help

After you have your spiffy new AppEngine/Azure Cicero app, read the generated
`README.md` file (AppEngine: to do,
[Azure](https://github.com/ariofrio/oration/blob/master/templates/azure/py/README.md))
for instructions on how to test it locally and deploy it to the cloud. You'll
need Windows to do this for Azure apps.

## Hacking

To get the latest version of Oration from GitHub, run:

    gem install bundler
    git clone https://ariofrio@github.com/ariofrio/oration.git
    cd oration
    bundle install
    bundle exec oration [PARAMS...]

