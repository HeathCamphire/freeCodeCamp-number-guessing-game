#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(( RANDOM % 1000 + 1))

echo $NUMBER

READ_GUESS() {
  read GUESS
  # guess again until guess is a number
  until [[ $GUESS =~ ^[0-9]+$ ]]
  do
    echo That is not an integer, guess again:
    read GUESS
  done
}

# initial message
echo Enter your username:
read USERNAME
# get user ID (if it exists)
NAME_CHECK=$($PSQL "SELECT name FROM users WHERE name='$USERNAME'")

# check if user in user database
if [[ -z $NAME_CHECK ]]
then
  # new user

  # insert new user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')") 

  GAMES_PLAYED=0
  # message to user
  echo Welcome, $USERNAME! It looks like this is your first time here.
else
  # return user

  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name='$USERNAME'")
  # message to user
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo Guess the secret number between 1 and 1000:
READ_GUESS
GUESS_COUNT=1

# until [[ $GUESS_COUNT == 3 ]]
until [[ $GUESS == $NUMBER ]]
do
  if (( GUESS < NUMBER ))
  then
    # guess is too low
    echo "It's higher than that, guess again:"
    READ_GUESS
  elif (( GUESS > NUMBER ))
  then
    # guess is too high
    echo "It's lower than that, guess again:"
    READ_GUESS
  fi
  (( GUESS_COUNT++ ))
done

echo You guessed it in $GUESS_COUNT tries. The secret number was $NUMBER. Nice job!

# update best_game if necessary
if [[ $GAMES_PLAYED == 0 ]]
then
  # first game
  INSERT_USER_RESULT=$($PSQL "UPDATE users SET best_game=$GUESS_COUNT WHERE name='$USERNAME'") 
elif (( GUESS_COUNT < BEST_GAME ))
then
  # new best score
  INSERT_USER_RESULT=$($PSQL "UPDATE users SET best_game=$GUESS_COUNT WHERE name='$USERNAME'") 
fi

(( GAMES_PLAYED++ ))
INSERT_USER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE name='$USERNAME'") 