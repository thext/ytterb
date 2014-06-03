DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Cleaning $DIR... ((remove all empty yaml stock cache files))"

find $DIR -empty -type f -delete
find $DIR -empty -type d -delete
