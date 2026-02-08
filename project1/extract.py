from faker import Faker
import random
import csv
from google.cloud import storage

fake = Faker()

BUCKET_NAME = "bkt-employee-data-shijin"
DESTINATION_BLOB = "data/employees.csv"
LOCAL_FILE = "data/employees.csv"

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
        "national_id": fake.ssn(),        # PII
        "department": random.choice(["IT", "HR", "Finance", "Operations"]),
        "salary": random.randint(40000, 120000)
    }

employees = [generate_employee(i) for i in range(1, 101)]

# Write CSV locally
with open(LOCAL_FILE, "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=employees[0].keys())
    writer.writeheader()
    writer.writerows(employees)

# Upload to GCS
client = storage.Client()
bucket = client.bucket(BUCKET_NAME)
blob = bucket.blob(DESTINATION_BLOB)
blob.upload_from_filename(LOCAL_FILE)

print(f"File uploaded to gs://{BUCKET_NAME}/{DESTINATION_BLOB}")
