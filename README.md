# Docker-wordpress-git-backup


## How to decryping db backup

```bash
docker exec -it CONTAINER_ID /bin/bash
```

```bash
openssl enc -d -aes256 -salt -pbkdf2 -pass pass:BACKUP_ENCRYPTION_KEY -in /backups/BACKUP_NAME.sql.gz | gzip -d > /backups/BACKUP_NAME.sql
```
