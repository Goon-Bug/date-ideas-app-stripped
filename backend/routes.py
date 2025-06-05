from datetime import datetime, timezone
from flask import jsonify, request, url_for
from flask_jwt_extended import create_access_token, create_refresh_token, decode_token, jwt_required, get_jwt_identity, get_jwt
from sqlalchemy.exc import IntegrityError
from backend.database.models.revoked_tokens import User, RevokedToken
from backend.extentions import db
from backend.routes_functions import validate_password, generate_verification_token, send_verification_email

#NOTE: rate limiting in production will be implemented using Google Cloud API Gateway

# flake8: noqa: C901
def register_routes(app):
    @app.route('/verify/<token>', methods=['GET'])
    def verify_email(token):
        try:
            app.logger.info("Received verification token: %s", token)  # dev
            decoded_token = decode_token(token)
            app.logger.info("Decoded token: %s", decoded_token)
            user_email = decoded_token['sub']
            app.logger.info("Decoded email from token: %s", user_email)  # dev

            user = User.query.filter_by(email=user_email).first()
            app.logger.info(f"User Object: {user}")
            if user:
                app.logger.info("expiration token from user object: %s", user.verification_jwt)  # dev

                if token != user.verification_jwt:
                    app.logger.warning(f"Token mismatch for email: {user_email}")
                    return jsonify({"error": "Expired or invalid verification link."}), 400

                if user.jwt_expiration.tzinfo is None:
                    app.logger.info("jwt_expiration is not timezone aware")
                    user.jwt_expiration = user.jwt_expiration.replace(tzinfo=timezone.utc)

                if user.jwt_expiration > datetime.now(timezone.utc):
                    user.update(db.session, email_verified=True)
                    user.update(db.session, verification_jwt=None)
                    user.update(db.session, jwt_expiration=None)
                    app.logger.info("Email verified successfully for user: %s", user_email)
                    return jsonify({"message": "Email verified successfully."}), 200
                else:
                    app.logger.warning("User not found or token expired for email: %s", user_email)  # pragma: no cover
                    return jsonify({'error': 'User email not found'}), 404  # pragma: no cover
            
        except Exception as e:
            app.logger.error("Error verifying token: %s", str(e))
            db.session.rollback()
            return jsonify({"error": "Invalid or expired token."}), 400

    @app.route("/register", methods=["POST"])
    def register():
        data = request.get_json()
        data['email'] = data['email'].lower()
        
        app.logger.debug("Received data: %s", data)
        
        if not data.get('username') or not data.get('email') or not data.get('password'):
            app.logger.warning("Missing required fields in request")  # pragma: no cover
            return jsonify({"error": "Missing required fields: username, email, and password."}), 400  # pragma: no cover
        
        try:
            existing_user = User.query.filter_by(email=data['email']).first()
            
            if existing_user:
                if not existing_user.email_verified: 
                    verification_token = generate_verification_token(existing_user.email)
                    verification_url = url_for('verify_email', token=verification_token, _external=True)

                    send_verification_email(existing_user.email, verification_url)
                    app.logger.info("New verification email sent to: %s", existing_user.email)

                    return jsonify({"message": "Email already exists but is not verified. A new verification email has been sent."}), 200
                
                app.logger.warning("Email already registered: %s", existing_user.email)
                return jsonify({"error": "Email already exists and is verified."}), 409

            user = User.from_json(data)
            app.logger.debug("User created: %s", user)

            user.set_password(data.get('password'))
            app.logger.debug("Password set successfully")

            db.session.add(user)
            db.session.commit()
            app.logger.info("User added to database: %s", user.username)

            verification_token = generate_verification_token(user.email)
            verification_url = url_for('verify_email', token=verification_token, _external=True)

            send_verification_email(user.email, verification_url)
            app.logger.info("Verification email sent to: %s", user.email)

            return jsonify({"message": "User registered. Please check your email for a verification link."}), 201

        except IntegrityError as e:  # pragma: no cover
            db.session.rollback()
            app.logger.error("IntegrityError: %s", str(e.orig))
            return jsonify({"error": "Database error."}), 500

        except Exception as e:  # pragma: no cover
            db.session.rollback()
            app.logger.exception("General Exception occurred")
            return jsonify({"error": str(e)}), 500


    @app.route('/login', methods=['POST'])
    def login():
        data = request.get_json()
        app.logger.debug("Received data: %s", data)

        email = data.get('email')
        password = data.get('password')
        
        if not email or not password:
            app.logger.warning("Missing email or password in request")  # pragma: no cover
            return jsonify({"error": "Missing email or password"}), 400  # pragma: no cover

        try:
            user = User.query.filter_by(email=email).first()
            app.logger.debug("Queried user: %s", user)

            if user and user.check_password(password):
                if not user.email_verified:
                    app.logger.warning("Email not verified for user: %s", user.username)  # pragma: no cover
                    return jsonify({'error': 'Email not verified. Please check your email for the verification link.'}), 403  # pragma: no cover
                
                access_token = create_access_token(identity=email)
                refresh_token = create_refresh_token(identity=email)
                app.logger.info("Generated tokens for user: %s", email)

                return jsonify({
                    'access_token': access_token,
                    'refresh_token': refresh_token,
                    'email': email,
                    'id': str(user.id),
                    'username': user.username,
                    'token_count': str(user.token_count)
                }), 200
            else:
                app.logger.warning("Invalid credentials for username: %s", email)
                return jsonify({'error': 'Invalid credentials'}), 401

        except Exception as e:  # pragma: no cover
            app.logger.exception("Exception occurred during login")
            return jsonify({'error': str(e)}), 500

    @app.route('/logout', methods=['POST'])
    @jwt_required(refresh=True)
    def logout():
        data = request.get_json()
        jwt_data = get_jwt()
        jti = jwt_data['jti']
        expires_at = jwt_data['exp']

        expires_at_datetime = datetime.fromtimestamp(expires_at, tz=timezone.utc)

        revoked_token = RevokedToken(jti=jti, user_id=data['id'], expires_at=expires_at_datetime)
        db.session.add(revoked_token)
        db.session.commit()

        app.logger.info(f"Revoked refresh token {jti} for user {get_jwt_identity()}.")
        return jsonify({"message": "Successfully logged out and refresh token revoked."}), 200

    @app.route('/', methods=['GET'])  # pragma: no cover
    def test():
        return jsonify({'message': 'API is working!'}), 200

    @app.route('/test-db', methods=['GET'])  # pragma: no cover
    def test_db():
        try:
            print(f"Connecting to DB with URI: {app.config['SQLALCHEMY_DATABASE_URI']}")
            data = User.query.all()
            return jsonify({"status": "success22", "result": data[0].username})
        except Exception as e:
            print(str(e))
            return jsonify({"status": "error", "message": str(e)}), 500

    @app.route('/updateusername', methods=['POST'])
    @jwt_required()
    def update_username():
        
        app.logger.info(request)
        data = request.get_json()
        app.logger.info(f"Got Json")
        user_id = int(data.get("id"))
        new_username = data.get("username")

        if not new_username:
            return jsonify({"error": "Username is required"}), 400

        try:
            user = db.session.get(User, user_id)
            if user:
                user.update(db.session, email=user.email, username=new_username)
                app.logger.info(f"User {user.id} updated username to {new_username}")
                return jsonify({"success": "Username successfully updated"}), 200
            else:
                app.logger.warning(f"User not found for user ID: {user_id}")
                return jsonify({"error": "User not found"}), 404
        except Exception as e:
            app.logger.error(f"Unexpected error updating username for user ID: {user_id} - {e}")
            return jsonify({"error": "An error occurred while updating the username"}), 500

    @app.route('/updatepassword', methods=['POST'])
    @jwt_required()
    def update_password():
        app.logger.info(f"Received request to update password.")
        data = request.get_json()
        app.logger.info(f"Request JSON payload received.")
        
        user_email = data.get("email")
        new_password = data.get("password")
        
        authenticated_user_email = get_jwt_identity()
        if not user_email or user_email != authenticated_user_email:
            app.logger.warning(f"Unauthorized password update attempt by user Email: Auth {authenticated_user_email}, Target {user_email}")
            return jsonify({"error": "Unauthorized"}), 403

        if not new_password:
            app.logger.warning(f"Password is required.")
            return jsonify({"error": "Password is required"}), 400

        is_valid, errors = validate_password(new_password)
        if not is_valid:
            app.logger.warning(f"Password validation failed: {errors}")
            return jsonify({"error": "Password does not meet complexity requirements", "details": errors}), 400

        try:
            user = db.session.query(User).filter_by(email=user_email).first()
            if user:
                user.set_password(new_password)  # Hash the password securely
                user.update(db.session, email=user.email, password=user.password)
                app.logger.info(f"Password successfully updated for user Email: {user_email}")
                return jsonify({"success": "Password successfully updated"}), 200
            else:
                app.logger.warning(f"User not found for user Email: {user_email}")
                return jsonify({"error": "User not found"}), 404
        except Exception as e:
            app.logger.error(f"Error updating password for user ID: {user_email} - {e}")
            return jsonify({"error": "An error occurred while updating the password"}), 500

    @app.route('/refresh', methods=['POST'])
    @jwt_required(refresh=True)
    def refresh():
        current_user = get_jwt_identity()
        jwt_data = get_jwt()
        jti = jwt_data['jti']

        if RevokedToken.query.filter_by(jti=jti).first():
            app.logger.warning(f"Refresh token {jti} has been revoked for user {current_user['email']}.")
            return jsonify({"error": "Refresh token has been revoked."}), 401
        
        access_token = create_access_token(identity=current_user)
        return jsonify(access_token=access_token), 200
    

    @app.route('/update-token', methods=['POST'])
    @jwt_required()
    def update_token():
        user_id = get_jwt_identity()
        data = request.get_json()
        token_count = data.get('tokenCount')

        user = User.query.filter_by(email=user_id).first()

        if user:
            user.update(db.session, token_count=token_count)
            app.logger.info(f"Token count updated for user {user.username} to {token_count}")
            db.session.commit()
            return jsonify({"message": "Token count updated"}), 200
        return jsonify({"error": "User not found"}), 404
