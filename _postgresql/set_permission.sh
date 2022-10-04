#!/bin/bash
export PGPASSWORD='wXfrQBjK4XYFY3KH6D2D'
export PGHOST='db-production.cglu874fh5rb.ap-east-1.rds.amazonaws.com'
export PGPORT='5432'
export PGUSER='postgres'

psql -d $1 -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA dbo TO tgs_app;"
psql -d $1 -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA dbo TO tgs_app;"
psql -d $1 -c "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA dbo TO tgs_app;"

psql -d $1 -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA dbo TO tgs_migration;"
psql -d $1 -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA dbo TO tgs_migration;"
psql -d $1 -c "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA dbo TO tgs_migration;"

psql -d $1 -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA dbo TO tgs_reader;"
psql -d $1 -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA dbo TO tgs_reader;"
psql -d $1 -c "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA dbo TO tgs_reader;"