# Filesafe Relay

This is the server component that is part of the larger Filesafe system. It deals with relaying files to the proper 3rd party storage provider, such as Dropbox, Google Drive, etc.

This is the server component that is part of the larger FileSafe system. It deals with relaying files to the proper 3rd party storage provider, such as Dropbox, Google Drive, WebDAV, or AWS S3.

## Setting up

### Requirements

#### Google Auth

This is required for an integration with Google Drive.

You need to supply the `client_secrets.json` file in the root directory of the project as is required by [Google Auth Library](https://github.com/googleapis/google-auth-library-ruby/tree/584ad57d7d72d9ffa395daa1dde4c48e04ab3c99#example-web). This can be set up [here](https://console.developers.google.com/apis/dashboard).

As an alternative you can set the `GOOGLE_CLIENT_SECRETS` environment variable in the `.env` file. When running the container, this will create the `client_secrets.json` file with contents of the variable.

### Docker

In order to run the relay server locally, type the following commands:

```
cp .env.sample .env
docker build -t filesafe-relay-local .
docker run -d -p 3000:3000 --env-file .env filesafe-relay-local
```

## Contributing

Feel free to create a pull request, we welcome your enthusiasm!

## Support

Please open a new issue and the Standard Notes team will take a look as soon as we can.

We are also reachable on our forum, Slack, Reddit, Twitter, and through email:

- Standard Notes Help and Support: [Get Help](https://standardnotes.org/help)
