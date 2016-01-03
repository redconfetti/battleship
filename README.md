# Battleship

Rails based Battleship game

See Demo at [http://battleship.redconfetti.com/](http://battleship.redconfetti.com/)

## Specifications

Each of the following ships are assembled randomly onto a 10 x 10 battle grid for each player.

| Ship             | Size | Quantity |
| ---------------- | ---- | -------- |
| Aircraft Carrier | 5    | 1        |
| Battleship       | 4    | 1        |
| Cruiser          | 3    | 1        |
| Destroyer        | 2    | 2        |
| Submarine        | 1    | 2        |

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

# Activate Pusher Add-on for Heroku (Sandbox - No Charge)
$ heroku addons:create pusher:sandbox
```

### Pusher Development

This application relies on the Pusher service to notify each Players client that an update has occurred to the state of the game.

You should [obtain the keys for local development](https://devcenter.heroku.com/articles/pusher#configure-for-local-use) from Heroku, and configure them in your local environment. This can be done in your ~/.profile or ~/.bash_profile

```
# Pusher (Required for Battleship Rails App)
export PUSHER_APP_ID=123456
export PUSHER_KEY=a2b3c4d5e6f7g8h9i0
export PUSHER_SECRET=a2b3c4d5e6f7g8h9i0
```

Pusher will automatically be [configured by Heroku](https://devcenter.heroku.com/articles/pusher#production-credentials) in production.
