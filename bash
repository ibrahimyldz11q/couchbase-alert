#!/bin/bash

# Couchbase Cluster Adresi
COUCHBASE_HOST="localhost"

# Couchbase REST API Kullanıcı Adı ve Şifresi
COUCHBASE_USER="your_username"
COUCHBASE_PASSWORD="your_password"

# REST API'den Bilgileri Al
NODE_INFO=$(curl -s -u "$COUCHBASE_USER:$COUCHBASE_PASSWORD" "http://$COUCHBASE_HOST:8091/pools/nodes")
BUCKET_INFO=$(curl -s -u "$COUCHBASE_USER:$COUCHBASE_PASSWORD" "http://$COUCHBASE_HOST:8091/pools/default/buckets")

# HTML Başlık
HTML_CONTENT="<html><head><title>Couchbase Cluster Status</title></head><body>"

# HTML İçerik (Tablo Başlıkları)
HTML_CONTENT+="<table border='1'><tr><th>Node</th><th>Uptime</th><th>Memory Usage</th><th>Swap Usage</th></tr>"

# Node Bilgileri
for node in $(echo $NODE_INFO | jq -r '.nodes[].otpNode')
do
    NODE_UPTIME=$(echo $NODE_INFO | jq -r ".nodes[] | select(.otpNode == \"$node\") | .uptime")
    NODE_MEMORY_USAGE=$(echo $NODE_INFO | jq -r ".nodes[] | select(.otpNode == \"$node\") | .interestingStats.mem_used")
    NODE_SWAP_USAGE=$(echo $NODE_INFO | jq -r ".nodes[] | select(.otpNode == \"$node\") | .interestingStats.swap_used")

    # HTML İçerik (Tablo Satırları)
    HTML_CONTENT+="<tr><td>$node</td><td>$NODE_UPTIME</td><td>$NODE_MEMORY_USAGE</td><td>$NODE_SWAP_USAGE</td></tr>"
done

# HTML İçerik (Tablo Kapatma)
HTML_CONTENT+="</table>"

# Bucket Bilgileri
HTML_CONTENT+="<h2>Buckets</h2>"
HTML_CONTENT+="<table border='1'><tr><th>Bucket Name</th><th>Item Count</th><th>Used Memory</th><th>Used Disk</th></tr>"

for bucket in $(echo $BUCKET_INFO | jq -r '.[].name')
do
    BUCKET_ITEM_COUNT=$(echo $BUCKET_INFO | jq -r ".[] | select(.name == \"$bucket\") | .basicStats.itemCount")
    BUCKET_USED_MEMORY=$(echo $BUCKET_INFO | jq -r ".[] | select(.name == \"$bucket\") | .basicStats.memUsed")
    BUCKET_USED_DISK=$(echo $BUCKET_INFO | jq -r ".[] | select(.name == \"$bucket\") | .basicStats.diskUsed")

    # HTML İçerik (Tablo Satırları)
    HTML_CONTENT+="<tr><td>$bucket</td><td>$BUCKET_ITEM_COUNT</td><td>$BUCKET_USED_MEMORY</td><td>$BUCKET_USED_DISK</td></tr>"
done

# HTML İçerik (Tablo Kapatma ve Body Kapatma)
HTML_CONTENT+="</table></body></html>"

# HTML Sayfasını Dosyaya Yazma
echo "$HTML_CONTENT" > couchbase_status.html

# Mail Gönderme
mailx -a "Content-type: text/html;" -s "Couchbase Cluster Status" your_email@example.com < couchbase_status.html
