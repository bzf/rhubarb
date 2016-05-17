rhubarb
-------

[![CircleCI](https://circleci.com/gh/bzf/rhubarb.svg?style=svg)](https://circleci.com/gh/bzf/rhubarb)

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
