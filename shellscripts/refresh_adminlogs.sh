export PGPASSWORD='wXfrQBjK4XYFY3KH6D2D'
export PGHOST='db-production.cglu874fh5rb.ap-east-1.rds.amazonaws.com'
export PGPORT='5432'
export PGUSER='postgres'

result=$(psql -d $1 -c "select count(1) from log.admin_logs where recorded_on >= CURRENT_TIMESTAMP - interval '$3 minutes'")
result2=${result//-/}
result3=${result2/count /}
result4=${result3/\(1 row\)/}
echo $result
echo $result4

if [ $result4 = "0" ]; then
        for p in $(kubectl -n $2 get pods | grep backoffice-api | awk '{print $1}'); do kubectl delete pod $p -n $2 --grace-period=0 --force;done
        echo "Staging Executed"
        curl "https://api.telegram.org/bot1780137038:AAHDIVxs2somlHZ5QbZKq1X403NnWAPXVn4/sendMessage?chat_id=-1001114115188&text=$2%20adminlogs%20updated"
fi

result=$(psql -d $1 -c "select count(1) from log.api_logs where recorded_on >= CURRENT_TIMESTAMP - interval '$3 minutes'")
result2=${result//-/}
result3=${result2/count /}
result4=${result3/\(1 row\)/}
echo $result
echo $result4

if [ $result4 = "0" ]; then
        for p in $(kubectl -n $2 get pods | grep log-api | awk '{print $1}'); do kubectl delete pod $p -n $2 --grace-period=0 --force;done
        echo "Staging Executed"
        curl "https://api.telegram.org/bot1780137038:AAHDIVxs2somlHZ5QbZKq1X403NnWAPXVn4/sendMessage?chat_id=-1001114115188&text=$2%20apilogs%20updated"
fi



etcdctl snapshot save --cacert="/etc/kubernetes/pki/etcd/ca.crt" --cert="/etc/kubernetes/pki/etcd/server.crt" --key="/etc/kubernetes/pki/etcd/server.key" /tmp/dev-backup



kubectl get nodes -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.taints[0].value}{"\n"}{end}'
 
 
 
 ETCDCTL_API=3 etcdctl --endpoints https://[127.0.0.1]:2379 \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  member list
  

	
	ETCDCTL_API=3 etcdctl --endpoints=https://[127.0.0.1]:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt \
     --name=master \
     --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
     --data-dir /var/lib/etcd-from-backup \
     --initial-cluster=master=https://127.0.0.1:2380 \
     --initial-cluster-token etcd-cluster-1 \
     --initial-advertise-peer-urls=https://127.0.0.1:2380 \
     snapshot restore /nfsshare/dev-backup
	 
  