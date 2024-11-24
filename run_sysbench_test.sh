sysbench \ 
  --threads=32 \ # Number of threads to use for the test. Adjust based on your desired concurrency level
  --time=6000 \ # Total test duration in seconds. Modify based on how long you want the test to run
  --rate=3000 \ # Target transaction rate. Change as needed to match your workload requirements
  --report-interval=10 \ 
  --db-driver=mysql \ 
  --mysql-host=tidb.hzgtyt1hqvvt.clusters.tidb-cloud.com \ # Replace with your TiDB cluster hostname or IP address
  --mysql-port=4000 \ # Default is 4000 for TiDB
  --mysql-user=root \ # Replace with your database username
  --mysql-password=rootadmin \ # Replace with your database password
  --mysql-db=transaction_demo \ # Replace with your target database name
  --mysql-ssl-ca=/home/m/Documents/code/costco/ca.cer \ # Replace with the path to your SSL CA certificate
  --db-ps-mode=auto \
  high_concurrency_test.lua run
