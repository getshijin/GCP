from faker import Faker
import random
import csv
import os
import logging
from google.cloud import storage

logging.basicConfig(level=logging.INFO)

fake = Faker()

BUCKET_NAME = "bkt-employee-data-shijin"
DESTINATION_BLOB = "data/employees.csv"

BASE_DIR = "/tmp"  # or /home/airflow/gcs/data
os.makedirs(BASE_DIR, exist_ok=True)

LOCAL_FILE = os.path.join(BASE_DIR, "employees.csv")

logging.info(f"Working directory: {os.getcwd()}")
logging.info(f"Writing file to: {LOCAL_FILE}")

def generate_employee(emp_id):
    return {
        "employee_id": emp_id,
        "first_name": fake.first_name(),
        "last_name": fake.last_name(),
        "email": fake.email(),
        "phone_number": fake.phone_number(),
        "job_title": fake.job().replace(",", " "),
        "password": fake.password(length=12),
        "address": fake.address().replace("\n", " ").replace(",", " "),
        "national_id": fake.ssn(),
        "department": random.choice(["IT", "HR", "Finance", "Operations"]),
        "salary": random.randint(40000, 120000)
    }

employees = [generate_employee(i) for i in range(1, 101)]

with open(LOCAL_FILE, "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=employees[0].keys())
    writer.writeheader()
    writer.writerows(employees)

client = storage.Client()
bucket = client.bucket(BUCKET_NAME)
blob = bucket.blob(DESTINATION_BLOB)
blob.upload_from_filename(LOCAL_FILE)

logging.info(f"Uploaded to gs://{BUCKET_NAME}/{DESTINATION_BLOB}")
