import os
import sys
import zipfile
import importlib

lambda_module = importlib.import_module("lambda")
lambda_handler = lambda_module.lambda_handler

os.environ['DB_USERNAME'] = 'root'
os.environ['DB_PASSWORD'] = '12345678'
os.environ['DB_HOST'] = 'localhost'
os.environ['DB_NAME'] = 'proinsight'

def zip_lambda(file_name, zip_name):
    arquivo = "lambda.py"
    arquivo_zip = "lambda.zip"
    with zipfile.ZipFile(arquivo_zip, 'w', zipfile.ZIP_DEFLATED) as zipf:
        zipf.write(arquivo)

if __name__ == '__main__':
    event = {
        'authorizationToken': '529.982.247-25',
        'methodArn': 'arn:aws:execute-api:us-west-2:279044386247:232mlon7u7/GET/request'
    }
    
    zip_lambda("lambda.py", "lambda.zip")
    response = lambda_handler(event, {})
    print(response)

# Instalar o módulo do mysql antes de executar:
# pip install mysql-connector-python
