Set-PSDebug -Trace 1
#region CREATE THE DATABASE SCHEMA AND TEST DATA

# 0. Set up env by running .env.ps1 script

.env.ps1

# 1. Connect to server using cli
Read-Host "After connecting to the server, copy and paste from 'setup_db.psql'. Press ENTER to continue"

Start-Process powershell -ArgumentList "-NoExit", "-Command",  "psql 'host=$env:DB_HOST port=5432 dbname=$env:DB_NAME user=$env:DB_USER sslmode=require'"

# -. Copy and paste PSQL script once connected

#endregion
#region ANALYZE BASELINE PERFORMANCE

# 0. Connect to server
Read-Host "To analyze baseline performance, copy and paste from 'analyze_vector_performance.psql'. Press ENTER to continue"

#endregion
#region CREATE AND COMPARE IVFFLAT AND HNSW INDEXES

# 0. Connect to server
Read-Host "To create and compare ivfflat and hnsw indexes, copy and paste from 'create_indexes.psql'. Press ENTER to continue"

#endregion
#region IMPLEMENT METADATA FILTERING WITH INDEXES

# 0. Connect to server
Read-Host "To implement metadata filtering with indexes, copy and paste from 'metadata_filtering.psql'. Press ENTER to continue"

#endregion
Set-PSDebug -Trace 0