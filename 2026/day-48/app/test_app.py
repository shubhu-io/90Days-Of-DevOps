import unittest

from app import app


class HealthTest(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()

    def test_index(self):
        res = self.client.get("/")
        self.assertEqual(res.status_code, 200)

    def test_health(self):
        res = self.client.get("/health")
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res.get_json(), {"status": "ok"})


if __name__ == "__main__":
    unittest.main()
