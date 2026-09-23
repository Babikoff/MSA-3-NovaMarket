from locust import HttpUser, between, task
from datetime import datetime, timezone

class WebsiteUser(HttpUser):
    wait_time = between(0.1, 0.5)

    @task(1)
    def get_fast(self):
        response = self.client.get("/logistics/?type=fast")
        print(f"{datetime.now(timezone.utc)} status_code: {response.status_code} body: {response.text}.")

    @task(2)
    def get_error(self):
        response = self.client.get("/logistics/?type=error")
        print(f"{datetime.now(timezone.utc)} status_code: {response.status_code} body: {response.text}.")

    @task(1)
    def get_default(self):
        response = self.client.get("/logistics/")
        print(f"{datetime.now(timezone.utc)} status_code: {response.status_code} body: {response.text}.")
