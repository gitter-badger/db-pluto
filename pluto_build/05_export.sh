#!/bin/bash
if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi
if [ -f version.env ]
then
  export $(cat version.env | sed 's/#.*//g' | xargs)
fi

apt update 
apt install -y zip curl

source ./url_parse.sh $BUILD_ENGINE
mkdir -p output && (
  cd output 
  psql $BUILD_ENGINE  -c "\COPY (SELECT * FROM pluto_corrections) TO STDOUT DELIMITER ',' CSV HEADER;" > output/pluto_corrections.csv
  psql $BUILD_ENGINE  -c "\COPY (SELECT * FROM pluto_removed_records) TO STDOUT DELIMITER ',' CSV HEADER;" > output/pluto_removed_records.csv
)

# mappluto
mkdir -p output/mappluto &&
  (cd output/mappluto
    pgsql2shp -u $BUILD_USER -h $BUILD_HOST -p $BUILD_PORT -f mappluto $BUILD_DB \
      "SELECT ST_Transform(geom, 2263) FROM pluto WHERE geom IS NOT NULL"
      # rm -f mappluto.zip
      echo "$VERSION" > version.txt
      zip mappluto.zip *
      ls | grep -v mappluto.zip | xargs rm
    )

# Pluto
mkdir -p output/pluto &&
  (cd output/pluto
    rm -f pluto_$VERSION.zip
    psql $BUILD_ENGINE -c "\COPY (SELECT * FROM pluto) TO STDOUT DELIMITER ',' CSV HEADER;" > pluto.csv
    echo "$VERSION" > version.txt
    echo "number of records: $(wc -l pluto.csv)" >> version.txt
    zip pluto.zip *
    ls | grep -v pluto.zip | xargs rm
  )

curl -O https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc

DATE=$(date "+%Y-%m-%d")
./mc config host add spaces $AWS_S3_ENDPOINT $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY --api S3v4
./mc rm -r --force spaces/edm-publishing/db-pluto/latest
./mc rm -r --force spaces/edm-publishing/db-pluto/$DATE
./mc cp -r output spaces/edm-publishing/db-pluto/latest
./mc cp -r output spaces/edm-publishing/db-pluto/$DATE

exit 0
