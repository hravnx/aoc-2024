#! /bin/zsh


DAY=$(printf %02d $1)

echo "Get the input data from $DAY"

# get the session from `.env`
SESSION=`cat .env`


curl https://adventofcode.com/2024/day/$1/input --output input/day-$DAY.txt --cookie "session=$SESSION"
