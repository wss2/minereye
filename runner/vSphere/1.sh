export KUBECONFIG=/etc/rancher/k3s/k3s.yaml


        helmfile -f ../../helmfile/infra/helmfile.yaml destroy --environment prod --selector svc=rabbitmq-operator --quiet
        helmfile -f ../../helmfile/infra/helmfile.yaml destroy --environment prod --selector svc=nginx-ingress --quiet
        helmfile -f ../../helmfile/infra/helmfile.yaml destroy --environment prod --selector stack=elastic --quiet
        helmfile -f ../../helmfile/infra/helmfile.yaml destroy --environment prod --selector svc=cerebro --quiet
        helmfile -f ../../helmfile/infra/helmfile.yaml destroy --environment prod --selector stack=monitoring --quiet
        helmfile -f ../../helmfile/infra/helmfile.yaml destroy --environment prod --selector stack=redis --quiet
        helmfile -f ../../helmfile/infra/helmfile.yaml destroy --environment prod --selector svc=postgresql --quiet
        helmfile -f ../../helmfile/infra/helmfile.yaml destroy --environment prod --selector svc=rabbitmq --quiet
        helmfile -f ../../helmfile/services/helmfile.yaml destroy --environment prod --selector type=priority --quiet
        helmfile -f ../../helmfile/services/helmfile.yaml destroy --environment prod --selector type=accounts --quiet

        helmfile -f ../../helmfile/services/helmfile.yaml destroy --environment prod --selector type=config --quiet
        helmfile -f ../../helmfile/services/helmfile.yaml destroy --environment prod --selector type=secret --quiet
        helmfile -f ../../helmfile/services/helmfile.yaml destroy --environment prod --selector svc=dashboard-server --quiet
        helmfile -f ../../helmfile/services/helmfile.yaml destroy --environment prod --selector deploy=all --quiet

        kubectl delete pvc --all -n me
