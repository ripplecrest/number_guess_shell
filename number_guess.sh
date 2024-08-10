#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"


echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")


if [[ -z $USER_ID ]]
then
  
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."

  
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_guesses) FROM games WHERE user_id=$USER_ID")
  
  
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi


RANDOM_NUM=$((1 + $RANDOM % 1000))

echo "Guess the secret number between 1 and 1000:"
GUESS_COUNT=0

while read GUESS
do
  
  GUESS_COUNT=$((GUESS_COUNT + 1))

  
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -eq $RANDOM_NUM ]]
  then
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUM. Nice job!"
    break
  elif [[ $GUESS -gt $RANDOM_NUM ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done


INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_guesses) VALUES($USER_ID, $GUESS_COUNT)")
