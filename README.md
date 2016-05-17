rhubarb
-------

[![CircleCI](https://circleci.com/gh/bzf/rhubarb.svg?style=svg)](https://circleci.com/gh/bzf/rhubarb)
An Electron app for managing your GitHub notifications.

## Configuration
The application is configured by a JSON file located at
`~/.config/rhubarb/rhubarb.json` which has the following format:

```elm
{
  "accessTokens": {
    "github": String
  },
  "projects": [
    {
      "name": String
      "githubRepository": String -- (e.g. "bzf/rhubarb")
    },
    {
      ...
    }
  ]
}
```


## Building
To build the application you need to have [elm](http://elm-lang.org/) installed.

You can start the `webpack` server by running:
```sh
npm run start
```

When you have that running you can start the electron application:
```sh
electron .
```

## Credits
Big thanks to [@joelhelin](https://twitter.com/@joelhelin) for the design.
