#/bin/bash

sudo apk update

sudo apk add vim

sudo mkdir -p /tmp

sudo chmod 1777 /tmp

if rc-service postgresql status | grep -q "started"; then
  echo "PostgreSQL is already running."
else
  sudo apk add postgresql

  sudo /etc/init.d/postgresql setup

  sudo rc-service postgresql start

  sudo rc-update add postgresql
fi

sudo -u postgres initdb -D /var/lib/postgresql/data

sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/postgresql.conf
echo "host all all 0.0.0.0/0 md5" | sudo tee -a /var/lib/postgresql/data/pg_hba.conf
sudo rc-service postgresql restart

sudo -u postgres psql <<EOF
ALTER USER postgres WITH PASSWORD 'postgres';
-- Create new database
CREATE DATABASE tpcc;

-- Create new user
CREATE USER tpcc WITH PASSWORD 'tpcc';

-- Grant privileges to the new user for the new database
GRANT ALL PRIVILEGES ON DATABASE tpcc TO tpcc;
EOF

rc-service postgresql status
