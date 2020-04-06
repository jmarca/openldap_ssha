#!/bin/bash

# bash wrappers for docker run commands
# should work on linux, perhaps on OSX


#
# Environment vars
#


# # useful for connecting GUI to container
# SOCK=/tmp/.X11-unix
# XAUTH=/tmp/.docker.xauth
# xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
# chmod 755 $XAUTH

#
# Helper Functions
#
dcleanup(){
	local containers
	mapfile -t containers < <(docker ps -aq 2>/dev/null)
	docker rm "${containers[@]}" 2>/dev/null
	local volumes
	mapfile -t volumes < <(docker ps --filter status=exited -q 2>/dev/null)
	docker rm -v "${volumes[@]}" 2>/dev/null
	local images
	mapfile -t images < <(docker images --filter dangling=true -q 2>/dev/null)
	docker rmi "${images[@]}" 2>/dev/null
}
del_stopped(){
	local name=$1
	local state
	state=$(docker inspect --format "{{.State.Running}}" "$name" 2>/dev/null)

	if [[ "$state" == "false" ]]; then
		docker rm "$name"
	fi
}
relies_on(){
	for container in "$@"; do
		local state
		state=$(docker inspect --format "{{.State.Running}}" "$container" 2>/dev/null)

		if [[ "$state" == "false" ]] || [[ "$state" == "" ]]; then
			echo "$container is not running, starting it for you."
			$container
		fi
	done
}

relies_on_network(){
    for network in "$@"; do
        local state
        state=$(docker network inspect --format "{{.Created}}" "$network" 2>/dev/null)

        if [[ "$state" == "false" ]] || [[ "$state" == "" ]]; then
            echo "$network is not up, starting it for you."
            $network
        fi
    done
}

relies_on_volume(){
    for volume in "$@"; do
        local state
        state=$(docker volume inspect --format "{{.CreatedAt}}" "$volume" 2>/dev/null)

        if [[ "$state" == "false" ]] || [[ "$state" == "" ]]; then
            echo "$volume is not up, starting it for you."
            docker volume create $volume
        fi
    done
}

openldap_nw(){
    docker network create --driver bridge openldap_nw
}


openldap(){
    relies_on_network openldap_nw
    relies_on_volume ldap_etc_ldap ldap_ssl ldap_var_backups ldap_var_lib_ldap ldap_var_restore

    docker run --rm -d \
           --network openldap_nw \
           --name openldap \
           --mount source=ldap_etc_ldap,target="/etc/ldap" \
           --mount source=ldap_ssl,target="/ssl" \
           --mount source=ldap_var_backups,target="/var/backups" \
           --mount source=ldap_var_lib_ldap,target="/var/lib/ldap" \
           --mount source=ldap_var_restore,target="/var/restore" \
           -e DOMAIN="activimetrics.com" \
           -e ORGANIZATION="Activimetrics LLC" \
           -e PASSWORD="grobblefruit" \
           mwaeckerlin/openldap
}

openldapam(){
    relies_on openldap
    relies_on_network openldap_nw
    relies_on_volume ldap_etc_ldap ldap_ssl ldap_var_backups ldap_var_lib_ldap ldap_var_restore
    docker run --rm -d \
           --name lam \
           --network openldap_nw \
           --mount source=ldap_etc_ldap,target="/etc/ldap" \
           --mount source=ldap_ssl,target="/ssl" \
           --mount source=ldap_var_backups,target="/var/backups" \
           --mount source=ldap_var_lib_ldap,target="/var/lib/ldap" \
           --mount source=ldap_var_restore,target="/var/restore" \
           mwaeckerlin/lam
}

openldap_ssha_sh(){
    del_stopped "openldap_ssha"
    docker run --rm -it -v ${PWD}:/usr/src/dev  --name openldap_ssha jmarca/openldap_ssha sh
}
