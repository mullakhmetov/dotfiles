for FILE in `find installation_scripts`
do
	[ -f "$FILE" ] && source "$FILE"
done

echo "scripts autorun completed\n";


