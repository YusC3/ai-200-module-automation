Set-PSDebug -Trace 1

#region TEST THE VECTOR INDEX PERFORMANCE WITH THE FLASK APP

# 1. Navigate to the client directory from root
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
