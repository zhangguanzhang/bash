$ openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | awk -F '( DNS:| IP Address:|,)' '$0~"Alternative"{flag=1;next;}flag{for(i=2;i<=NF;i+=2)print $i;exit}'
kubernetes
kubernetes.default
kubernetes.default.svc
kubernetes.default.svc.cluster.local
localhost
apiserver.k8s.local
apiserver001.k8s.local
apiserver002.k8s.local
apiserver003.k8s.local
10.96.0.1
127.0.0.1
172.16.2.3
172.16.2.4
172.16.2.5
172.16.2.10
172.16.2.11
172.16.2.240
