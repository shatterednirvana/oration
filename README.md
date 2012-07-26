# Oration [![Travis CI status](https://secure.travis-ci.org/ariofrio/oration.png)](http://travis-ci.org/ariofrio/oration)

(The tests haven't been updated to the latest refactoring in HEAD, stay tuned. :)

## Installation

### Linux

    apt-get install rubygems || yum install rubygems
    [sudo] gem install oration

### Windows

 1. [Install Ruby](http://rubyinstaller.org/)

 2. Open a Terminal (press <kbd>Win</kbd>-<kbd>R</kbd>, type `cmd`, and press <kbd>Enter</kbd>) and install Oration:

        gem install oration

## Usage

 1. Get some Python, Java or Go code and run:

        oration -file <path/to/file.py|.go|.java> -function <function> \
          -output ../azure-app -appid <app id> -cloud <appengine|azure>

        Options:

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

    Go is not supported on Azure, and Java is not supported on AppEngine.

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

## Roadmap

See [ROADMAP.md][].

  [roadmap.md]: https://github.com/ariofrio/oration/blob/master/ROADMAP.md

