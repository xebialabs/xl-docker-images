#!/bin/bash


display_help() {
    echo "   Example: ./copy_docker_images.sh -d <destination_registry> -p <xlr|xld> -s <source_registry> -v <version>"
    echo "   -d, --destination       destination registry"
    echo "   -h, --help              Script Usage"  
    echo "   -p, --product           xlr or xld"
    echo "   -s, --source            source registry"
    echo "   -v, --version           xlr or xld version"
    exit 1
}

pull_push(){

  version=$1

	docker pull $source/$product:$version

	docker tag $(docker images $source/$product:$version -q) $destination/$product:$version

	docker push $destination/$product:$version

	docker rmi $(docker images $source/$product:$version -q) -f
}


[ $# -eq 0 ] && display_help
[ $# -lt 4 ] && display_help
while getopts ":hd:v:p:s:" arg; do
  case $arg in
    d)
      destination=${OPTARG}
      ;;
    v)
      version=${OPTARG}
      ;;
    p) 
      product=${OPTARG}
      ;;
    s) 
      source=${OPTARG}
      ;;
    h | *) 
      display_help
      exit 0
      ;;
  esac
done

for tag in $version $version-'centos' $version-'amazonlinux' $version-'ubuntu' $version-'debian-slim'
do
	pull_push $tag
done


