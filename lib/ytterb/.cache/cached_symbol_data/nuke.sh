DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Nuking $DIR... (remove all files yaml stock cache files)"

find $DIR -print | grep yaml$ | xargs truncate -s 0
find $DIR -empty -type f -delete
find $DIR -empty -type d -delete
