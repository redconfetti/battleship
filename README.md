# Battleship

Rails based Battleship game

See Demo at [http://battleship.redconfetti.com/](http://battleship.redconfetti.com/)

## Specifications

Each of the following ships are assembled randomly onto a 10 x 10 battle grid for each player.

| Ship             | Size |
| ---------------- | ---- |
| Aircraft Carrier | 5    |
| Battleship       | 4    |
| Cruiser          | 3    |
| Destroyer        | 2    |
| Submarine        | 1    |

See [Battleship game](https://en.wikipedia.org/wiki/Battleship_%28game%29) for further history.

# Development Notes

## Setup

1. Install [RVM](https://rvm.io/rvm/install)
2. Install [Homebrew](http://brew.sh/)
3. Clone this application to a local repository
4. Use `bundle install` to install RubyGem dependencies
5. Use `brew install node` to install NodeJS / Node Package Manager (NPM)
6. Use `npm install -g bower` to globally install Bower
7. Install [Heroku Toolbelt](https://toolbelt.heroku.com/)

## Bower

This application uses Bower to manage the front-end packages / assets.

```
# View Bower related tasks
$ rake -T bower

# Install Bower packages
$ rake bower:install
````

## Heroku

This application is setup to be hosted from Heroku.

```
# Login and Create App
$ heroku login
$ heroku create

# Deploy Changes
$ git push heroku master
```

## Log

* Analyzed specifications and developed design (models and relationships)
* Resolved local conflicts with Homebrew
  * Updated Homebrew
  * Resolved `brew doctor` issues
  * Updated [XQuartz](http://www.xquartz.org/)
* Used [Bootstrapping AngularJS with Rails](http://angular-rails.com/bootstrap.html)

