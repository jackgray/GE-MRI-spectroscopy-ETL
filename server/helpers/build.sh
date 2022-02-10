VERSION=$1

docker build -t jackgray/ppull:$VERSION -f ../Dockerfile.$1 ../

docker push jackgray/ppull:$VERSION