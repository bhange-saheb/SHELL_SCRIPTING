#!/bin/bash
if [ $# -gt 0 ]; then
# $@ is added for multi-user addition
 for USER in $@; do
 echo "$USER"
 #Forcing username should contain one or more alphabets only
  if [[ "${USER}" =~ ^[a-zA-Z]+$ ]]; then
    #printing 1st field of user
    EXISTING_USER=$(grep -iw "$USER:" /etc/passwd | cut -d: -f1)
    #checking user is exist or not
    if [ "${USER}" = "${EXISTING_USER}" ]; then
   echo "$USER is already Present"
    else
     echo "Adding New User : $USER"
     sudo useradd -m $USER --shell /bin/bash
     SPEC=$(echo ' !@#$%^&*()_' | fold -w1 | shuf | head -1)
     PASSWORD="Bhange@${RANDOM}${SPEC}"
     echo "$USER:$PASSWORD" | sudo chpasswd
     echo "The temporary password the $USER is ${PASSWORD}"
     passwd -e $USER
    fi
  else
    echo "ERROR !!! Username should be in aplhabets "
  fi
 done 
else
echo "Invalid Agrument !!!! Please provide at leat one user to add"
fi
