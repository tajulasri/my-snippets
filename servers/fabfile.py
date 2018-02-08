from fabric.api import *

env.hosts = [
    'YOUR_IP'
]

env.user = 'YOUR_USER_NAME'
# you can use key instead


def uname():
    run('uname -a')


def upgrade():
    run('sudo apt-get -y upgrade')


def update():
    run('sudo apt-get update -y')


def apt_common():
    run('sudo apt-get install -y python-software-properties')
    run('sudo apt-get install -y software-properties-common')


def setup_ngix():
    run('sudo apt-get install -y nginx')
    run('curl -I localhost')


def setup_php():
    apt_common()
    run('sudo add-apt-repository -y ppa:ondrej/php')
    update()
    run('apt-cache pkgnames | grep php7.1')
    run('sudo apt-get install -y php7.1 php7.1-cli php7.1-common php7.1-mbstring php7.1-gd php7.1-intl php7.1-xml php7.1-mysql php7.1-mcrypt php7.1-zip php7.1-pdo-pgsql php7.1-dom php7.1-bcmath')


def setup_php_fpm():
    run('sudo apt-get install php7.1-fpm')


def setup_composer():
    run('sudo wget https://getcomposer.org/installer && php installer && chmod +x composer.phar')
    run('sudo mv composer.phar /usr/bin/composer')
    run('composer')


def setup_lets_encrypt():
    run('sudo add-apt-repository -y ppa:certbot/certbot')
    update()
    run('sudo apt-get install -y python-certbot-nginx')


def setup_redis():
    run('sudo apt-get install redis-server -y')
    run('redis-cli --version && redis-cli PING')


def setup_supervisor():
    run('sudo apt-get install supervisor -y')

def download_nginx_vhost(vhost):
    run('sudo wget https://gist.githubusercontent.com/tajulasri/b02a97432bd1793777f0e16c5e652d3a/raw/8f7703249c7bdf1eb24260142cbbfee5c30a0bfd/nginx%2520vhost%2520ssl /etc/nginx/sites-available/{0}').format(vhost)
    

def deploy(site="example.com"):
    upgrade()
    update()
    setup_ngix()
    setup_php()
    setup_lets_encrypt()
    setup_redis()
    setup_supervisor()
    setup_composer()