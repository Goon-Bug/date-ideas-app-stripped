from flask_bcrypt import Bcrypt

password = 'TestPassword1!!'
bcrypt = Bcrypt()
hashed_password = bcrypt.generate_password_hash(password)

hashed_password = hashed_password.decode('utf-8')
print(hashed_password)
