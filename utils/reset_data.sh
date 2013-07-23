set -e

if [ -d env ]; then
  . ./env/bin/activate
  echo "Activated virtualenv"
fi

git checkout master
git pull origin master

if [ -d  ../data/daily_csv ]; then
    echo "Removing data/daily_csv/"
    rm -r ../data/daily_csv/
fi

if [ -d ../data/lifetime_csv ]; then
    echo "Removing data/lifetime_csv/"
    rm -r ../data/lifetime_csv/
fi

cd ../parser
./download_and_parse_fms_fixies.py
(
  cd ../schema-builder
  node schema-builder.js
  s3cmd put table_schema.json s3://treasury.io/table_schema.json
  s3cmd setacl s3://treasury.io/ --acl-public --recursive
)


