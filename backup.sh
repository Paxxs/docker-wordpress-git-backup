#!/bin/bash

# backup folder: /backups
# wp uploads: /wp/uploads
# SQL_BACKUP="/backups"
BACKUP_FOLDER="/backups"
WP_UPLOADS="${BACKUP_FOLDER}/uploads"

# git init function
## $1 git 根目录
## $2 git lfs track ""
## $3 ssh key path
function initGitFunc() {
    if [ -e "${1}/.git/HEAD" ]; then
        cd ${1}
        echo " change work dir to $(pwd)"
    else
        echo " init git"
        rm -rf "${1}/.git"
        git init ${1}
        cd ${1}
        echo " change work dir to $(pwd)"
        echo " config git user ${GIT_USER}:${GIT_EMAIL}"
        git config --local user.name ${GIT_USER}
        git config --local user.email ${GIT_EMAIL}
        echo " config git lfs"
        git lfs install
        git lfs track ${2}
        git add .gitattributes
        git commit -m "setup lfs"
    fi
    echo " add all files to git"
    git add .
    git add -A
    echo " commit all files"
    git commit -m "update: $(date '+%Y%m%d-%H:%M:%S')"
    chmod 600 ${SSH_KEY_PATH}
    if git config remote.origin.url >/dev/null; then
        # GIT_SSH_COMMAND="ssh -i $ssh_key_path -o IdentitiesOnly=yes" git push -uf origin master
        # Avoid host authenticity check
        ssh-agent bash -c "ssh-add ${3}; GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no' git push -uf origin master"
    else
        git remote add origin ${GIT_REMOTE}
        # GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $ssh_key_path -o IdentitiesOnly=yes" git push -u origin master
        ssh-agent bash -c "ssh-add ${3}; GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no' git push -u origin master"
    fi
    echo 'done.'
}

# rm any backups older than 30 days
echo ":: clean old backups"
find /backups -name *.sql.gz -mtime +30 -exec rm {} \;

# define sql backup name
BACKUP_FILE="db.$(date "+%F-%H%M%S").sql"

# docker exec sqldump and encrypt
echo ":: backup database"
echo -e "${DB_ROOT_PASSWORD}\n" | docker exec -i ${MYSQL_CONTAINTER_NAME} mysqldump -uroot -p ${DB_NAME} | gzip | openssl enc -e -aes256 -salt -pbkdf2 -pass pass:${BACKUP_ENCRYPTION_KEY} -out /backups/${BACKUP_FILE}.gz
echo "Done ($?)"

# upload to github (wp)
echo ":: upload to github"
initGitFunc $BACKUP_FOLDER '"*.jpg" "*.png" "*.gif" "*.jpeg" "*.bpm" "*.rar" "*.zip" "*.gz"' ${SSH_KEY_PATH}
