#!/bin/bash
echo
echo "_  _ _ _  _ ____ ____ ____ _   _ ____"
echo "|\/| | |\ | |___ |__/ |___  \_/  |___"
echo "|  | | | \| |___ |  \ |___   |   |___"
echo
echo
set -e

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml


show_menus() {

        echo "~~~~~~~~~~~~~~~~~~~~~"
        echo " "
        echo "Welcome to Minereye DT linux installation kit on vSphere "

}

read_options(){
        local choice
        set_values 1 10;
}

set_values(){

# The data are inserted for the build of the virtual
        umanual="n"
        node_count=$1
        cpu_count=$(( 8 * node_count ))
        disk_size=$2

        echo "Start install application with $cpu_count CPU"


        echo "Deploying Infrastructure components:"
        helmfile -f ../../helmfile/infra/helmfile.yaml apply --environment prod --selector svc=rabbitmq-operator --quiet
        sleep 15
        helmfile -f ../../helmfile/infra/helmfile.yaml apply --environment prod --selector svc=nginx-ingress --quiet
        helmfile -f ../../helmfile/infra/helmfile.yaml apply --environment prod --selector stack=elastic --quiet
        helmfile -f ../../helmfile/infra/helmfile.yaml apply --environment prod --selector svc=cerebro --quiet
        helmfile -f ../../helmfile/infra/helmfile.yaml apply --environment prod --selector stack=monitoring --quiet
        helmfile -f ../../helmfile/infra/helmfile.yaml apply --environment prod --selector stack=redis --quiet
        helmfile -f ../../helmfile/infra/helmfile.yaml apply --environment prod --selector svc=postgresql --quiet
        helmfile -f ../../helmfile/infra/helmfile.yaml apply --environment prod --selector svc=rabbitmq --quiet

        echo "Deploying Minereye services:"
        helmfile -f ../../helmfile/services/helmfile.yaml apply --environment prod --selector type=priority --quiet
        helmfile -f ../../helmfile/services/helmfile.yaml apply --environment prod --selector type=accounts --quiet

        helmfile -f ../../helmfile/services/helmfile.yaml apply --environment prod --selector type=config --quiet
        helmfile -f ../../helmfile/services/helmfile.yaml apply --environment prod --selector type=secret --quiet
        helmfile -f ../../helmfile/services/helmfile.yaml apply --environment prod --selector svc=dashboard-server --quiet
        sleep 30
        helmfile -f ../../helmfile/services/helmfile.yaml apply --environment prod --selector deploy=all --quiet

        echo "Applying Ingress"
        kubectl apply -f ../../ingress/
        IP_ADDRESS=$(kubectl -n me get svc nginx-ingress-ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

        vgpass=$(kubectl -n me get secret dashboard -o jsonpath="{.data.password}" | base64 --decode )

        echo ""
        echo "-------------------------------------------------------------------"

        echo "The application is ready"
        echo "Go to https://$IP_ADDRESS"
        echo "user: vgadmin"
        echo "pass: $vgpass"

        echo ""
        echo "-------------------------------------------------------------------"
}

clear
echo "'run prerequisites check"
bash prerequisites.sh
retVal=$?
if [ $retVal -eq 1 ]; then
    echo "Error at prerequisites script"
else
    show_menus
    read_options
fi
