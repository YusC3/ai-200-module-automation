Set-PSDebug -Trace 1

#region COMPLETE THE AZURE RESOURCE DEPLOYMENNT AND CREATE THE SCHEMA

# 6. Generate the environment variables
. .\.env.ps1

# 7. Connect to psql server using psql cli
Read-Host "After connecting to the server, copy and paste from 'setup_db.psql'. Press ENTER to continue"

psql "host=$env:DB_HOST port=5432 dbname=$env:DB_NAME user=$env:DB_USER sslmode=require"

#endregion
#region SET UP AND RUN FLASK APPLICATION

# 1. Navigate to the client folder
cd client

# 2. Create environment using python
Read-Host "Use this command to create a python environment, then press enter 'python -m venv .venv'"

# 3. Activate python environment 
Read-Host "Use the generated file to activate the environment, then press enter '.\.venv\Scripts\Activate.ps1'"

# 4. Install the requirements for the project
pip install -r requirements.txt

# 5. Run the app.py file to launch the application
Read-Host "Launch this command in a new terminal, then press enter 'python app.py'"

#endregion

Set-PSDebug -Trace 0