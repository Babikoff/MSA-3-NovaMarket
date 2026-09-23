from locust import HttpUser, between, task
from datetime import datetime, timezone

class WebsiteUser(HttpUser):
    wait_time = between(1, 5)

    @task
    def get_web_api(self):
        response = self.client.get("/api/web/", headers={"Client-Type": "web"}, name=" WEB API ")
        print(f"{datetime.now(timezone.utc)} status_code: {response.status_code} body: {response.text}.")

    @task
    def get_mobile_api(self):
        response = self.client.get("/api/mobile/", headers={"Client-Type": "mobile"}, name=" MOBILE API ")
        print(f"{datetime.now(timezone.utc)} status_code: {response.status_code} body: {response.text}.")