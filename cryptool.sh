#!/bin/bash

usage() {
  echo -e "\nUSAGE:";
  echo "./cryptool.sh "
  echo -e "\n Options:"
  echo -e "  ./cryptool.sh --encrypt <filename> <public_key>"
  echo -e "  ./cryptool.sh --decrypt <filename> <private_key> <tar.gz>"
  echo -e ""
}

if [[ "$1" = "--encrypt" ]]; then
  if [[ -n "$2" && -n "$3" ]]; then
    echo "generating a random key..."
    openssl rand 192 -out key

    echo ""
    openssl aes-256-cbc -in $2 -out $2.enc -pass file:key
    openssl rsautl -encrypt -pubin -inkey $3 -in key -out key.enc
    tar -zcvf $2.tgz *.enc
    echo "Created $2.tgz"
    echo "Done."
  fi
elif [[ "$1" = "--decrypt" ]]; then
  tar -xzvf $4
  openssl rsautl -decrypt -ssl -inkey $3 -in key.enc -out key
  openssl aes-256-cbc -d -in $2.enc -out $2 -pass file:key
  rm key key.enc $2.enc
  echo "Done."
else
  usage
fi
