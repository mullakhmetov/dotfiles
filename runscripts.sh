for FILE in `find installation_scripts -type f -name "*.sh"`
do
	source "$FILE"
done

echo "scripts autorun completed"


