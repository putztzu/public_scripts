# This script enables cors which is disabled by default in Elasticsearch 1.4

cat >> /etc/elasticsearch/elasticsearch.yml << EOF
################################# Custom ##################################
http.cors.allow-origin: "/.*/"
http.cors.enabled: true
EOF
