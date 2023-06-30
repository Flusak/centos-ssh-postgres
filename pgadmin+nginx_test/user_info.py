import config
import string
import secrets
import os
import getpass
from pgadmin.utils.constants import ENTER_EMAIL_ADDRESS

from pgadmin.utils.validation_utils import validate_email


def user_info_desktop():
    print("NOTE: Configuring authentication for DESKTOP mode.")
    email = config.DESKTOP_USER
    p1 = ''.join([
        secrets.choice(string.ascii_letters + string.digits)
        for _ in range(32)
    ])
    return email, p1

def pprompt():
    return getpass.getpass(), getpass.getpass('Retype password:')
    
    
def user_info_server():
    print("NOTE: Configuring authentication for SERVER mode.\n")

    if all(value in os.environ for value in
           ['PGADMIN_SETUP_EMAIL', 'PGADMIN_SETUP_PASSWORD']):
        email = ''
        p1 = ''
        if os.environ['PGADMIN_SETUP_EMAIL'] \
                and os.environ['PGADMIN_SETUP_PASSWORD']:
            email = os.environ['PGADMIN_SETUP_EMAIL']
            p1 = os.environ['PGADMIN_SETUP_PASSWORD']
    else:
        return 'user_emailch', 'user_passwch'
	
	
def user_info():
    if config.SERVER_MODE is False:
        email, p1 = user_info_desktop()
    else:
        email, p1 = user_info_server()

    return email, p1