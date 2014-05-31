DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Cleaning $DIR"

find $DIR -empty -type f
find $DIR -empty -type f -delete
find $DIR -empty -type d
find $DIR -empty -type d -delete
