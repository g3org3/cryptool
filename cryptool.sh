#!/bin/bash

usage() {
  echo -e "\n USAGE:";
  echo -e "  ./cryptool.sh --encrypt <filename> <public_key>"
  echo -e "  ./cryptool.sh --decrypt <filename> <private_key> <tar.gz>"
  echo -e "\n More info"
  echo -e "  public_key\t PKCS8 public key"
  echo -e "  filename\t Path of the file to encrypt"
  echo -e "  tar.gz\t Input for decrypting"
  echo -e "\n FAQ"
  echo -e "  common error: unable to load Public Key"
  echo -e "  fix -> ssh-keygen -e -f ~/.ssh/id_rsa.pub -m PKCS8 > ~/.ssh/id_rsa.pub.pkcs8"
  echo -e "  or you can run ./cryptool.sh --fix <public_key>"
  echo -e ""
}

encrypt() {
  echo "generating a random key..."
    openssl rand 192 -out key
    echo ""
    openssl aes-256-cbc -in $1 -out $1.enc -pass file:key
    openssl rsautl -encrypt -pubin -inkey $2 -in key -out key.enc
    tar -zcvf $1.tgz *.enc
    echo "Created $1.tgz"
    echo "Done."
}

decrypt() {
  tar -xzvf $3
  openssl rsautl -decrypt -ssl -inkey $2 -in key.enc -out key
  openssl aes-256-cbc -d -in $1.enc -out $1 -pass file:key
  rm key key.enc $1.enc
  echo "Done."
}

fix() {
  ssh-keygen -e -f $1 -m PKCS8 > ~/.ssh/$1.pkcs8
}

if [[ "$1" = "--encrypt" && -n "$2" && -n "$3" ]]; then
  encrypt $2 $3
elif [[ "$1" = "--decrypt" && -n "$2" && -n "$3" && -n "$4" ]]; then
  decrypt $2 $3 $4
elif [[ "$1" = "--fix" && -n "$2" ]]; then
  fix $2
else
  usage
fi
