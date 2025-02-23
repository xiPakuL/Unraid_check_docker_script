#!/bin/bash

remove_orphaned_images="no"  # select "yes" or "no" to remove any orphaned images 
remove_unconnected_volumes="no" # select "yes" or "no" to remove any unconnected volumes

# Do not make changes below this line #

echo -e "\e[1;33m##################################################################################\e[0m"
echo -e "\e[1;31mCleanup before starting\e[0m (if requested in script)"
echo -e "\e[1;33m##################################################################################\e[0m"
echo
 if [ "$remove_orphaned_images" == "yes"  ] ; then
    echo "Removing orphaned images..."
    echo
    docker image prune -af
  else
    echo "Not removing orphaned images (this can be set in script if you want to)"
  fi
echo
echo "---------------------------------------------------------------------------------"
echo
if [ "$remove_unconnected_volumes" == "yes"  ] ; then
    echo "Removing unconnected docker volumes"
    echo
    docker volume prune -f
  else
    echo "Not removing unconnected docker volumes (this can be set in script if you want to)"
  fi
echo
echo -e "\e[1;33m##################################################################################\e[0m"
echo "List of Image, Container and docker volume size."
echo -e "\e[1;33m##################################################################################\e[0m"
echo
#docker system df
docker system df --format 'There are \t {{.TotalCount}} \t {{.Type}} \t taking up ......{{.Size}}'
echo
echo -e "\e[1;33m##################################################################################\e[0m"
echo "List of containers showing size and virtual size"
echo -e "\e[1;33m##################################################################################\e[0m"
echo
echo "First size is the writable layers of the container (Virtual size is writable and read only layers)"
echo
docker container ls -a --format '{{.Size}} \t Is being taken up by ......... {{.Image}}'
echo
echo -e "\e[1;33m##################################################################################\e[0m"
echo "List of containers in size order"
echo -e "\e[1;33m##################################################################################\e[0m"
echo
docker image ls --format "{{.Repository}} {{.Size}}" | \
awk '{if ($2~/GB/) print substr($2, 1, length($2)-2) *1000 "MB - " $1 ; else print $2 " - " $1 }' | \
sed '/^0/d' | \
sort -nr
echo
echo -e "\e[1;33m##################################################################################\e[0m"
echo "List of docker volumes, the container which they are connected to their size"
echo -e "\e[1;33m##################################################################################\e[0m"
echo 
volumes=$(docker volume ls  --format '{{.Name}}')
for volume in $volumes
do
name=`(docker ps -a --filter volume="$volume" --format '{{.Names}}' | sed 's/^/  /')`
size=`(du -sh $(docker volume inspect --format '{{ .Mountpoint }}' $volume) | cut -f -1)`
echo -e "\e[1;31m ID \e[0m"  "\e[1;95m $volume \e[0m"
echo -e "This volume connected to \e[1;34m" $name "\e[0m has a size of \e[1;33m" $size "\e[0m"
echo ""
done
echo
echo -e "\e[1;34m##################################################################################\e[0m"
echo
echo -e "\e[1;32m Done. Scroll up to view results \e[0m"
exit
