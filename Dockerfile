FROM phusion/passenger-full:0.9.8

ENV RAILS_ENV production

RUN apt-get update

# We should not have to do this, as it's meant to be included in passenger-full!
RUN /build/redis.sh

# Install dependencies (some of these come with passenger-ruby)
RUN apt-get install -y build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev logrotate software-properties-common python-software-properties

# Install Git 1.8
RUN add-apt-repository -y ppa:git-core/ppa;\
  apt-get update;\
  apt-get -y remove git;\
  apt-get -y install git

# Create 'git' user and remove 'app' user
RUN userdel -r app; adduser --disabled-password --gecos 'GitLab' git

# Install GitLab Shell
RUN cd /home/git;\
  su git -c "git clone https://github.com/gitlabhq/gitlab-shell.git -b v1.8.0";\
  cd gitlab-shell;\
  su git -c "cp config.yml.example config.yml";\
  sed -i -e 's/localhost/127.0.0.1/g' config.yml;\
  su git -c "./bin/install"

# Install MySQL
RUN apt-get install -y mysql-server mysql-client libmysqlclient-dev

# Add GitLab
# ADD gitlab /home/git/gitlab
RUN cd /home/git;\
  su git -c "git clone https://github.com/Datacom/gitlabhq gitlab";\
  cd gitlab;\
  su git -c "git checkout datacom"
RUN cd /home/git/gitlab;\
  su git -c "bundle install --deployment --without development test postgres aws"

# Misc configuration stuff
RUN cd /home/git/gitlab;\
  chown -R git tmp/;\
  chown -R git log/;\
  chmod -R u+rwX log/;\
  chmod -R u+rwX tmp/;\
  su git -c "mkdir /home/git/gitlab-satellites";\
  su git -c "mkdir tmp/pids/";\
  su git -c "mkdir tmp/sockets/";\
  chmod -R u+rwX tmp/pids/;\
  chmod -R u+rwX tmp/sockets/;\
  su git -c "mkdir public/uploads";\
  chmod -R u+rwX public/uploads;\
  su git -c "cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb";\
  su git -c "git config --global user.name 'GitLab'";\
  su git -c "git config --global user.email 'gitlab@localhost'";\
  su git -c "git config --global core.autocrlf input"

# Add app config
ADD resources/config_files/database.yml /home/git/gitlab/config/database.yml
ADD resources/config_files/gitlab.yml /home/git/gitlab/config/gitlab.yml
ADD resources/config_files/unicorn.rb /home/git/gitlab/config/unicorn.rb
ADD resources/config_files/gitlab-shell.yml /home/git/gitlab-shell/config.yml

# Precompile assets
ADD resources/precompile.sh /tmp/
RUN /tmp/precompile.sh

# Enable Redis, nginx
ADD resources/config_files/nginx /etc/nginx/sites-enabled/gitlab
RUN rm -f /etc/service/redis/down;\
  rm -f /etc/service/nginx/down;\
  rm -f /etc/nginx/sites-enabled/default

# Add services, init scripts, etc
ADD resources/services/ /etc/service/
ADD resources/init/ /etc/my_init.d/
ADD resources/user_scripts/ /sbin/

# Remove redundant script from baseimage-docker
RUN rm /etc/my_init.d/00_regen_ssh_host_keys.sh

# Expose ports
EXPOSE 80
EXPOSE 22

# Use baseimage's init script
CMD ["/sbin/my_init"]

