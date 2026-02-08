import csv

bad_rows = []

with open("data/employees.csv", newline="", encoding="utf-8") as f:
    reader = csv.reader(f)
    for i, row in enumerate(reader, start=1):
        if len(row) != 11:
            bad_rows.append((i, len(row), row))

for r in bad_rows[:5]:
    print(r)
