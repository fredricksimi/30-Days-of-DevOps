import unittest
from main import app

class AppTestCase(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_home(self):
        response = self.app.get('/')
        self.assertEqual(response.data, b'Welcome to Jumanji!')

if __name__ == '__main__':
    unittest.main()
