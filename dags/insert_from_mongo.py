from datetime import timedelta, datetime

from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.operators.python import PythonOperator
# from airflow.providers.mongo.hooks.mongo import MongoHook

from pymongo.mongo_client import MongoClient
from clickhouse_driver import Client


MONGO_CONN_DETAILS = {
    "host": "82.115.26.117",
    "port": 27017,
    # "username": "your_mongo_user",
    # "password": "your_mongo_password",
    "database": "videos",
    "collection": "videos",
}

CLICKHOUSE_CONN_DETAILS = {
    "host": "localhost",
    "port": 9000,
    "user": "G4_user",
    "password": "G4_pass",
    "database": "raw",
}

def extract_from_mongo():

    try:
        client = MongoClient(
            host=MONGO_CONN_DETAILS["host"],
            port=MONGO_CONN_DETAILS["port"],
            # username=MONGO_CONN_DETAILS["username"],
            # password=MONGO_CONN_DETAILS["password"],
        )
        db = client[MONGO_CONN_DETAILS["database"]]
        collection = db[MONGO_CONN_DETAILS["collection"]]

        documents = list(collection.find_one())
        if documents:
            # Transform MongoDB documents to a list of tuples (for ClickHouse)
            data = [
                tuple(doc.get(key) for key in doc.keys() if key != "_id")
                for doc in documents
            ]
            # Extract the column names from the first document (excluding _id)
            columns = [key for key in documents[0].keys() if key != "_id"]
            return {"data": data, "columns": columns}
        else:
            raise RuntimeError("No documents found in the MongoDB collection.")

    except Exception as e:
        raise RuntimeError(f"Failed to extract data from MongoDB: {e}")


def load_to_clickhouse(extracted_data):
    """
    Insert data into ClickHouse table.
    """
    client = Client(**CLICKHOUSE_CONN_DETAILS)
    table_name = "your_clickhouse_table"  # Replace with your ClickHouse table name
    data = extracted_data["data"]
    columns = extracted_data["columns"]

    # Prepare the insert query
    column_list = ",".join(columns)
    query = f"INSERT INTO {table_name} ({column_list}) VALUES"

    try:
        client.execute(query, data)
        print(f"Successfully inserted {len(data)} rows into ClickHouse.")
    except Exception as e:
        raise RuntimeError(f"Failed to insert data into ClickHouse: {e}")

default_args = {
    "owner": "airflow",
    "retries": 1,
    "retry_delay": timedelta(minutes=5)
}

with DAG(
    dag_id="mongo_to_clickhouse_dag",
    default_args=default_args,
    description="A DAG to transfer data from MongoDB to ClickHouse",
    schedule_interval="@daily",
    start_date=datetime(2023, 1, 1),
    catchup=False,
) as dag:

    # Task to extract data from MongoDB
    extract_task = PythonOperator(
        task_id="extract_from_mongo",
        python_callable=extract_from_mongo,
    )

    # Task to load data into ClickHouse
    load_task = PythonOperator(
        task_id="load_data",
        python_callable=load_to_clickhouse,
        op_kwargs={
            "extracted_data": "{{ ti.xcom_pull(task_ids='extract_from_mongo') }}"
        },
    )

    # Task dependencies
    extract_task >> load_task




