#############################################################
# Init Cassandra
#############################################################

echo "Creating keyspace + user fizoaibackend, change password of user cassandra ..."
sleep 20
cqlsh cassandra 9042 -u cassandra -p cassandra -e "CREATE ROLE IF NOT EXISTS fizoaibackend WITH SUPERUSER = false AND LOGIN = true AND PASSWORD = '@@CASSANDRA_PASSWORD@@';"

cqlsh cassandra 9042 -u cassandra -p cassandra -e "CREATE KEYSPACE IF NOT EXISTS fizoaibackend WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};"
cqlsh cassandra 9042 -u cassandra -p cassandra -e "GRANT ALL PERMISSIONS ON KEYSPACE fizoaibackend to fizoaibackend;"

cqlsh cassandra 9042 -u cassandra -p cassandra -e "ALTER USER cassandra WITH PASSWORD '@@CASSANDRA_SUPERUSER_PASSWORD@@';"
