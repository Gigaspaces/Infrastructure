apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-of-apps
  namespace: argocd
spec:
  project: GigaSpaces-dev
  source:
    repoURL: git@github.com:Gigaspaces/xap-umbrella-chart.git
    path: argocd
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: false
      selfHeal: false
