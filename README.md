# Filesafe Relay

This is the server component that is part of the larger Filesafe system. It deals with relaying files to the proper 3rd party storage provider, such as Dropbox, Google Drive, etc.

## Setting up

### Docker

In order to run the relay server locally, type the following commands:

```
docker build -t filesafe-relay-local .
docker run -d -p 3000:3000 filesafe-relay-local
```
