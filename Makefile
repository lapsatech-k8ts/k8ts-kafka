NS=kafka
RELEASE=kafka
CHARTPATH=./helm/kafka/
IMAGE=localhost:5000/lapsatech/kubernetes-kafka_3.6:latest

default: build

build:
	docker build ./docker \
	   --pull \
	   --progress=plain \
	   --tag ${IMAGE}
#    --no-cache \

push: build
	docker push ${IMAGE}

install-light: push
	helm upgrade ${RELEASE} ${CHARTPATH} \
	     --namespace ${NS} \
	     --create-namespace \
	     --install \
	     --debug \
	     --reset-values \
	     --force \
	     --set deployment.pvc.enabled=false

render:
	helm template ${RELEASE} ${CHARTPATH}

install: push
	helm upgrade ${RELEASE} ${CHARTPATH} \
	     --namespace ${NS} \
	     --create-namespace \
	     --install \
	     --debug \
	     --reset-values \
	     --force

delete-chart:
	helm delete ${RELEASE} \
	     --namespace ${NS}

drop-namespace:
	kubectl delete namespace ${NS}

drop-pods:
	kubectl get pod --namespace ${NS} -o name | xargs -I{} kubectl delete --grace-period=0 --namespace ${NS} {}

create-pvcs:
	kubectl create --namespace ${NS} -f pvc.yaml

drop-pvcs:
	kubectl get pvc --namespace ${NS} -o name | xargs -I{} kubectl delete --grace-period=0 --namespace ${NS} {}

uninstall: delete-chart

clean: drop-pods drop-namespace
