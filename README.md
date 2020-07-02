# FileSafe Relay

## Setting up

### Requirements

#### Google Auth
You need to supply the `client_secret.json` file in the root directory of the project as is required by [Google Auth Library](https://github.com/googleapis/google-auth-library-ruby/tree/584ad57d7d72d9ffa395daa1dde4c48e04ab3c99#example-web).

As an alternative you can set the `GOOGLE_CLIENT_SECRETS` environment variable in the `.env` file. When running the container, this will create the `client_secrets.json` file with contents of the variable.

### Docker

In order to run the relay server locally type the following commands:

```
cp .env.sample .env
docker build -t filesafe-relay-local .
docker run -d -p 3000:3000 --env-file .env filesafe-relay-local
```
