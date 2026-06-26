Set-PSDebug -Trace 1

#region CREATE THE AGENT MEMORY SCHEMA WITH PSQL
# 1. Run the following command to connect to the server
Read-Host "Once connected to the database, copy and paste the 'setup_postgresql_table.psql' script. Press ENTER to continue"

psql "host=$env:DB_HOST port=5432 dbname=$env:DB_NAME user=$env:DB_USER sslmode=require"

#endregion
#region TEST THE AGENT MEMORY WORKFLOW

# 1. Navigate to the agent-backend
cd agent-backend

# 2. Create environment using python
Read-Host "Use this command to create a python environment, then press enter 'python -m venv .venv'"

# 3. Activate python environment 
Read-Host "Use the generated file to activate the environment, then press enter '.\.venv\Scripts\Activate.ps1'"

# 4. Install the requirements for the project
pip install -r requirements.txt

# 5. Run the app.py file to launch the application
Read-Host "Launch this command in a new terminal, then press enter 'python test_workflow.py'"

# 7. Optional test_workflow.py file
Read-host "Optional: Review file 'test_workflow.py' then press enter"

#endregion
#region QUERY CONVERSATION CONTEXT

# 1. Connect to the agent_memory database...
Read-Host "Once connected to the database, copy and past the 'query_data.psql' script. Press ENTER to continue"

psql "host=$env:DB_HOST port=5432 dbname=agent_memory user=$env:DB_USER sslmode=require"

#endregion
Set-PSDebug -Trace 0