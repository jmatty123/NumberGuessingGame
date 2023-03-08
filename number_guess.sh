#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUMBER=$((RANDOM % 1000 + 1))

echo -e "\nEnter your username:"
read USERNAME

GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME';")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME';")

if [[ -z $GAMES_PLAYED ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME';")
NUMBER_OF_GUESSES=0

GAME(){
echo $1
read GUESS
NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))

if [[ ! $GUESS =~ ^[0-9]+$ ]]
then
  GAME "That is not an integer, guess again:"

elif [[ $GUESS -gt $NUMBER ]]
then
  GAME "It's lower than that, guess again:"

elif [[ $GUESS -lt $NUMBER ]]
then
  GAME "It's higher than that, guess again:"

elif [[ $GUESS -eq $NUMBER ]]
then
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"

  if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]] || [[ -z $BEST_GAME ]]
  then
    UPDATEGUESSES=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME';")
  fi
fi
}

GAME "Guess the secret number between 1 and 1000:"
