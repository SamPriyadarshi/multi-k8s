docker build -t sampriyadarshi/multi-client:latest -t sampriyadarshi/multi-client:$SHA -f ./client/Dockerfile ./client
docker build -t sampriyadarshi/multi-server:latest -t sampriyadarshi/multi-server:$SHA -f ./server/Dockerfile ./server
docker build -t sampriyadarshi/multi-worker:latest -t sampriyadarshi/multi-worker:$SHA -f ./worker/Dockerfile ./worker

docker push sampriyadarshi/multi-client:latest
docker push sampriyadarshi/multi-server:latest
docker push sampriyadarshi/multi-worker:latest

docker push sampriyadarshi/multi-client:$SHA
docker push sampriyadarshi/multi-server:$SHA
docker push sampriyadarshi/multi-worker:$SHA

kubectl apply -f k8s --namespace qa
kubectl set image deployments/server-deployment server=sampriyadarshi/multi-server:$SHA --namespace qa
kubectl set image deployments/client-deployment client=sampriyadarshi/multi-client:$SHA --namespace qa
kubectl set image deployments/worker-deployment worker=sampriyadarshi/multi-worker:$SHA --namespace qa

