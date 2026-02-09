from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.providers.google.cloud.operators.datafusion import CloudDataFusionStartPipelineOperator

default_args = {
    "owner": "airflow",
    "start_date": datetime(2023, 12, 18),
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="EMPLOYEE_DATA_PIPELINE",
    default_args=default_args,
    schedule_interval="@daily",
    catchup=False,
) as dag:

    run_script_task = BashOperator(
        task_id="extract_data",
        bash_command="python /home/airflow/gcs/dags/scripts/extract.py",
    )

    start_pipeline = CloudDataFusionStartPipelineOperator(
        task_id="start_data_fusion_pipeline",
        location="us-central1",
        instance_name="datafusion-dev",
        pipeline_name="first_pipeline",
        pipeline_timeout=1000,
    )

    run_script_task >> start_pipeline
