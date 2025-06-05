import pytest
from datetime import timedelta
from flask_jwt_extended import create_access_token
from backend.database.models.user_models import User
from backend.database.models.revoked_tokens import RevokedToken


class TestUsersFlaskApp:
    @pytest.fixture(autouse=True)
    def setup_and_teardown(self, app, client, sample_user):
        """Sets up the fixtures needed for testing."""
        self.app = app
        self.client = client
        self.sample_user = sample_user

    def test_register_user(self):
        user_json = {'username': 'newuser',
                     'password': 'TestPassword1!',
                     'email': 'newuser@example.com'}
        response = self.client.post('/register', json=user_json)
        assert response.status_code == 201
        assert response.get_json() == {"message": "User registered: Please check your email for a verification link"}

    def test_login_user_verified(self):
        """Test login user that is verified"""
        user_json = {'username': self.sample_user['username'],
                     'password': self.sample_user['password'],
                     'email': self.sample_user['email']}
        response = self.client.post('/login', json=user_json)

        assert response.status_code == 200

        response_json = response.get_json()

        assert 'access_token' in response_json
        assert 'refresh_token' in response_json
        assert 'id' in response_json
        assert response_json['username'] == self.sample_user['username']

    def test_login_invalid_credentials(self):
        """Test login with invalid credentials."""
        data = {
            'email': 'wrongemail@wrongemail.com',
            'password': 'wrongpassword'
        }
        response = self.client.post('/login', json=data)
        assert response.status_code == 401
        assert response.get_json() == {'error': 'Invalid credentials'}

    def test_fetch_user_data(self):
        login_data = {
            'email': self.sample_user['email'],
            'password': self.sample_user['password']
        }
        login_response = self.client.post('/login', json=login_data)
        access_token = login_response.get_json()['access_token']

        response = self.client.get('/user/1', headers={'Authorization': f'Bearer {access_token}'})

        assert response.status_code == 200
        user_data = response.get_json()
        print(user_data)
        assert user_data['username'] == self.sample_user['username']

    def test_verify_email_success(self, client):
        user_json = {'username': 'newuser', 'password': 'TestPassword1!', 'email': 'newuser@example.com'}
        response = self.client.post('/register', json=user_json)
        assert response.status_code == 201

        user = User.query.filter_by(email='newuser@example.com').first()
        if user:
            token = user.verification_jwt

        response = client.get(f'/verify/{token}')

        assert response.status_code == 200
        assert response.get_json() == {"message": "Email verified successfully."}

        user = User.query.filter_by(email='newuser@example.com').first()
        if user:
            assert user.email_verified is True
            assert user.verification_jwt is None
            assert user.jwt_expiration is None

    def test_verify_email_expired_token(self, client, sample_user):
        expired_token = create_access_token(identity={'email': sample_user['email']},
                                            expires_delta=timedelta(minutes=-10))

        response = client.get(f'/verify/{expired_token}')

        assert response.status_code == 400
        assert response.get_json() == {"error": "Invalid or expired token."}

    def test_logout(self):
        """Test logging out a user."""
        login_data = {
            'email': self.sample_user['email'],
            'password': self.sample_user['password']
        }
        login_response = self.client.post('/login', json=login_data)
        refresh_token = login_response.get_json()['refresh_token']

        response = self.client.post('/logout',
                                    headers={'Authorization': f'Bearer {refresh_token}'},
                                    json={'id': self.sample_user['id']})

        assert response.status_code == 200
        assert response.get_json() == {"message": "Successfully logged out and refresh token revoked."}

        revoked_token = RevokedToken.query.filter_by(user_id=self.sample_user['id']).first()
        assert revoked_token is not None

    def test_refresh(self):
        """Test refreshing the access token."""
        login_data = {
            'email': self.sample_user['email'],
            'password': self.sample_user['password']
        }
        login_response = self.client.post('/login', json=login_data)
        refresh_token = login_response.get_json()['refresh_token']

        response = self.client.post('/refresh', headers={'Authorization': f'Bearer {refresh_token}'})

        assert response.status_code == 200
        assert 'access_token' in response.get_json()

    def test_refresh_with_revoked_token(self):
        """Test refreshing the access token with a revoked refresh token."""
        login_data = {
            'email': self.sample_user['email'],
            'password': self.sample_user['password']
        }
        login_response = self.client.post('/login', json=login_data)
        refresh_token = login_response.get_json()['refresh_token']

        self.client.post('/logout', headers={'Authorization': f'Bearer {refresh_token}'},
                         json={'id': self.sample_user['id']})

        response = self.client.post('/refresh', headers={'Authorization': f'Bearer {refresh_token}'})

        assert response.status_code == 401
        assert response.get_json() == {"error": "Refresh token has been revoked."}
