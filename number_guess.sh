#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUM=$(($RANDOM % 1001))
GAMES=0
HIGHSCORE=0
COUNTER=0

echo "Enter your username:"
read USERNAME_INPUT

QUERY="$($PSQL "SELECT * FROM users WHERE name = '$USERNAME_INPUT'")"

IFS="|"
read -r USERNAME GAMES HIGHSCORE <<< "$QUERY"
if [[ -z $USERNAME ]]
then
  echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
else
  echo "Welcome back, $USERNAME! You have played $GAMES games, and your best game took $HIGHSCORE guesses."
fi

GAME(){
  REGEX="^[0-9]+$"
  read GUESS
  COUNTER=$(($COUNTER+1))
  if ! [[ $GUESS =~ $REGEX ]]
  then
    echo "That is not an integer, guess again:"
    GAME
  else
    if [[ $RANDOM_NUM -eq $GUESS ]]
    then
      GAMES=$(($GAMES+1))
    elif [ $RANDOM_NUM -gt $GUESS ]
    then
      echo "It's higher than that, guess again:"
      GAME
    else
      echo "It's lower than that, guess again:"
      GAME
    fi
  fi

}

echo "Guess the secret number between 1 and 1000:"
GAME

# $PSQL doesn't work here, idk why
if [[ $COUNTER -lt $HIGHSCORE ]]
then
  psql --username=freecodecamp --dbname=number_guess -t --no-align -c "UPDATE users SET games_played=$GAMES, highscore=$COUNTER WHERE name='$USERNAME'" | > /dev/null
else
  if [[ -z $USERNAME ]]
  then
    psql --username=freecodecamp --dbname=number_guess -t --no-align -c "INSERT INTO users(name, games_played, highscore) values('$USERNAME_INPUT', 1, $COUNTER)" | > /dev/null
  else
    psql --username=freecodecamp --dbname=number_guess -t --no-align -c "UPDATE users SET games_played=$GAMES WHERE name='$USERNAME'" | > /dev/null

  fi
fi

echo "You guessed it in $COUNTER tries. The secret number was $RANDOM_NUM. Nice job!"
