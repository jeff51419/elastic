#cerebro install
# bitnami cerebro chart
https://hub.kubeapps.com/charts/stable/cerebro

because stable chart already Archive, but we still can check information
https://github.com/helm/charts/tree/master/stable/cerebro

####################################################### 
# install cerebro
```

#Add stakater repository
$ helm repo add stakater https://stakater.github.io/stakater-charts

#Install chart
helm install -n elasticsearch --values=cerebro-values.yaml cerebro stable/cerebro --version 0.5.1 --dry-run
helm install -n elasticsearch --values=cerebro-values.yaml cerebro stable/cerebro --version 0.5.1

helm upgrade -n elasticsearch --values=cerebro-values.yaml cerebro stable/cerebro --version 0.5.1 --dry-run

```

# login
cerebro website
http://cerebro.silkrode.in.
