import os
import re
import json
import logging
from mysql.connector import connect
from contextlib import contextmanager


def lambda_handler(event, context):

    logging.info('event: {}'.format(event))
    logging.info('context: {}'.format(context))


    cpf = event['authorizationToken']

    try:
        logging.info('Check if the CPF is valid')
        if validate_cpf(cpf):
            logging.info('Check if CPF is in the Database')
            user = get_user_by_cpf(cpf)
            logging.info('User: {}'.format(user))
            if user:
                response = generatePolicy(user, 'Allow', event['methodArn'])
                logging.info(response)
                return response

        raise Exception('Unauthorized')

    except BaseException as e:
        logging.error('unauthorized', e)
        return 'unauthorized'  # Return a 500 error


def validate_cpf(cpf):
    cpf = ''.join(re.findall(r'\d', str(cpf)))
    if (not cpf) or (len(cpf) < 11):
        logging.error('CPF inválido, menor que 11 dígitos')
        return False

    if cpf == cpf[0] * len(cpf):
        logging.error('CPF inválido, todos os dígitos são iguais')
        return False

    sum_of_products = sum((10 - i) * int(cpf[i]) for i in range(9))
    expected_digit = (sum_of_products * 10 % 11) % 10
    if expected_digit == 10:
        expected_digit = 0
    if int(cpf[9]) != expected_digit:
        logging.error('CPF inválido, 1º dígito inválido')
        return False

    sum_of_products = sum((11 - i) * int(cpf[i]) for i in range(10))
    expected_digit = (sum_of_products * 10 % 11) % 10
    if expected_digit == 10:
        expected_digit = 0
    if int(cpf[10]) != expected_digit:
        logging.error('CPF inválido, 2º dígito inválido')
        return False

    return True


@contextmanager
def new_connection():
    parameters = dict(
        host=os.getenv('DB_HOST'),
        port=3306,
        user=os.getenv('DB_USERNAME'),
        passwd=os.getenv('DB_PASSWORD'),
        database=os.getenv('DB_NAME')
    )

    connection = connect(**parameters)
    try:
        logging.info('Trying to connect to the database')
        yield connection
    except Exception as e:
        logging.error("An error occurred:", e)
    finally:
        logging.info('Closing connection')
        if connection and connection.is_connected():
            connection.close()


def get_user_by_cpf(cpf):
    sql = 'SELECT name, cpf, email FROM user WHERE cpf = %s'
    with new_connection() as connection:
        try:
            cursor = connection.cursor()
            cursor.execute(sql, (cpf,))
            result = cursor.fetchone()
        except Exception as e:
            logging.error("An error occurred:", e)
    return result


def generatePolicy(user, effect, resource):
    authResponse = {}
    authResponse['principalId'] = 'user'
    if (effect and resource):
        policyDocument = {}
        policyDocument['Version'] = '2012-10-17'
        policyDocument['Statement'] = []
        statementOne = {}
        statementOne['Action'] = 'execute-api:Invoke'
        statementOne['Effect'] = effect
        statementOne['Resource'] = resource
        policyDocument['Statement'] = [statementOne]
        authResponse['policyDocument'] = policyDocument
    authResponse['context'] = {
        "name": user[0],
        "cpf": user[1]
    }
    authResponse_JSON = json.dumps(authResponse)
    return authResponse_JSON
