for FILE in `find scripts`
do
	[ -f "$FILE" ] && source "$FILE"
done

echo "scripts autorun completed\n";

