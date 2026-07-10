from airflow import DAG
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.operators.python import PythonOperator
from clickhouse_driver import Client
from datetime import datetime

def transfer_postgres_to_clickhouse():
    pg_hook = PostgresHook(postgres_conn_id='your_postgres_conn')
    client = Client(
        host="clickhouse_server",
        port="9000",
        user="G4_user",
        password="G4_pass",
        database="raw"
    )

    # Query PostgresSQL
    connection = pg_hook.get_conn()
    cursor = connection.cursor()
    cursor.execute('SELECT * FROM your_table')
    data = cursor.fetchall()

    # Insert data into ClickHouse
    client.execute('INSERT INTO clickhouse_table VALUES', data)

with DAG('postgres_to_clickhouse', start_date=datetime(2025, 1, 1), schedule_interval='@daily') as dag:
    transfer_task = PythonOperator(
        task_id='transfer_postgres_to_clickhouse',
        python_callable=transfer_postgres_to_clickhouse
    )