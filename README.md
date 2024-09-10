# anytype
My anytype configuration using tailscale for connectivity.

## Creating config files
Use [any-sync-network](https://github.com/anyproto/any-sync-tools/tree/main)
```
go install github.com/anyproto/any-sync-tools/any-sync-network@latest
any-sync-network create
```

## Running
```
# first time start
# you need to create the S3 bucket that anytype will use
MINIO_USER=<user> MINIO_PASSWORD=<password> docker compose up -d minio
docker exec -it anytype-minio-1 /bin/bash
mc alias set minio http://minio:9000 <user> <password>
mc mb minio/minio-bucket
exit

make start
# follow the prompts
# you will need an oauth client ID and secret from tailscale
```

## Updating
```
make update
# follow the prompts
# you will need an oauth client ID and secret from tailscale
```

## Stopping
```sh
# bring down containers
make down
# (optional) clean up all resources
# WARNING: this will prune docker volumes that aren't being used
make clean
```
