# additionalApplications:
#   - name: argo-cd-tikal
#     namespace: argocd
#     project: default
#     source:
#       path: argo-cd
#       repoURL: git@gitlab.com:tikalk.com/users/hagzag/argo-expriments.git
#       targetRevision: master
#       helm:
#         valueFiles:
#           - values-override.yaml
#     destination:
#         server: https://kubernetes.default.svc
#         namespace: argocd
#     syncPolicy:
#       automated:
#         prune: false
#         selfHeal: false

server:
  # true val & salt saved in master vault
  # 
  # kubectl -n argocd patch secret argocd-secret \
  # -p '{"stringData": {
  #   "admin.password": "$2y$12$fP1uNtoZ3rWopET6KPn91udNyWQ0xO.GbC6xnrLrKpwYl6IdtcHwa",
  #   "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  # }}'
  argocdServerAdminPassword: "$2y$12$fP1uNtoZ3rWopET6KPn91udNyWQ0xO.GbC6xnrLrKpwYl6IdtcHwa"
  # image:
  #   tag: v2.0.0-rc1
  # logFormat: json
  resources: {}
  #  limits:
  #    cpu: 1000m
  #    memory: 1024Mi
  #  requests:
  #    cpu: 500m
  #    memory: 512Mi
  autoscaling:
    enabled: true
    minReplicas: 1
    maxReplicas: 5
    targetCPUUtilizationPercentage: 50
    targetMemoryUtilizationPercentage: 50
  service:
    type: LoadBalancer
    annotations:
      external-dns.alpha.kubernetes.io/hostname: ${externaldns_http}         
    spec:
      ports:
      - name: http
        port: 80
        protocol: TCP
        targetPort: 8080
      - name: https
        port: 443
        protocol: TCP
        targetPort: 8080
  # metrics:
  #   enabled: true
  #   service:
  #     annotations:
  #       release: prometheus-stack
  #     labels:
  #       release: prometheus-stack
  #     servicePort: 8083
  #   serviceMonitor:
  #     enabled: true
  #     selector:
  #       release: prometheus-stack
  #   #   namespace: monitoring
  #     additionalLabels:
  #       release: prometheus-stack
  config:
    url: ${argocd_url} 
    admin.enabled: "true"
    repositories: |-

      - name: ${app_of_apps_repo_name} 
        type: git
        url: ${app_of_apps_repo_url}
        sshPrivateKeySecret:
          key: sshPrivateKey
          name: ${argo_ssh_key}
      - name: ${repo_name_1} 
        type: git
        url: ${repo_url_1}
        sshPrivateKeySecret:
          key: sshPrivateKey
          name: umbrella-github-secret 
  extraArgs:
      - --insecure
# repoServer:
  # image:
  #   tag: v2.0.0-rc1
  # logFormat: json
  # resources: {}
    # limits:
    #   cpu: 100m
    #   memory: 256Mi
    # requests:
    #   cpu: 50m
    #   memory: 128Mi
  # metrics:
  #   enabled: true
  #   service:
  #     annotations:
  #       release: prometheus-stack
  #     labels:
  #       release: prometheus-stack
  #     servicePort: 8084
  #   serviceMonitor:
  #     enabled: true
  #     selector:
  #       release: prometheus-stack
  #     additionalLabels:
  #       release: prometheus-stack

# redis:
#   resources:
#    limits:
#      cpu: 200m
#      memory: 128Mi
#    requests:
#      cpu: 100m
#      memory: 64Mi
