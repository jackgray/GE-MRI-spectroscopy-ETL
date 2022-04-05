VERSION=$1

docker build -t jackgray/ppull:$VERSION -f ../Dockerfile ../

docker push jackgray/ppull:$VERSION