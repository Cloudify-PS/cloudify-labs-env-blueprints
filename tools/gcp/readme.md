Create OIB image

## Install steps

1. Add firewall rules:

```
gcloud compute firewall-rules create allow-openvpn \
  --target-tags openvpn
  --allow udp:1194
```


2. Create disk for OIB

```
gcloud compute disks create oib-disk \
  --zone europe-west2-a \
  --size 200 \
  --image-project centos-cloud \
  --image-family centos-7
```

3. Create an image based on disk from step 1 with nested license 

```
gcloud compute images create oib-image \
  --source-disk oib-disk --source-disk-zone europe-west2-a \
  --licenses "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"
```

> After this step oib-disk can be deleted.

4. Create a VM instance

```
gcloud compute instances create oib-instance \
  --zone europe-west2-a \
  --min-cpu-platform "Intel Haswell" \
  --image oib-image \
  --boot-disk-size=200GB \
  --machine-type=n1-standard-8 \
  --tags=openvpn \
  --hostname=oib.cloudify.labs
```

5. Add SSH to the instance:

```
cat << EOF > ssh_keys.pub
centos:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAgJTYbfKC+adktZu3etKSSjw6pxRqOVrSuU7jJ6+ssFLLftbxi5YJL8ITllmfChZnqJecGiBFotbzr5WekGX8ROqSHT1p984bX0hJRjrsxPLirnX/bqYGoQudse3F/D6bUlkusA/t4ZFFibkOFiDp0kwpOa/Ch4sQAqiYacqO2/KBKRf5r6xTgdQyUt9GnQ7iZCOz5oaky889z37Jjy1J3EiAej8sRxKo+4b5rNke+YozCpoF/c7IORpgguVW5sBI5af7jfRJwWpTq4UoGiiIHc47qJVbl7PPJUfVtx4mswiS3LifgYf/N+/ohWpf/ERKsp0SRIDuS8tAIvTFkoYb centos google-ssh {"userName":"centos"}
EOF

gcloud compute instances add-metadata oib-instance \
--zone europe-west2-a \
--metadata-from-file ssh-keys=ssh_keys.pub
```

5. Create OIB image

```
gcloud compute images create oib-image-$(date -Idate) \
  --source-disk oib-instance --source-disk-zone europe-west2-a \
  --licenses "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"
```