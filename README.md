# Datacom's Docker Image for GitLab

This Dockerfile will create a new Docker container running GitLab on Ubuntu 12.04.

It is inspired by <a href="https://github.com/crashsystems/gitlab-docker">crashsystems/gitlab-docker</a> 
and <a href="https://github.com/sameersbn/docker-gitlab">sameersbn/docker-gitlab</a>, but improves on these 
by precompiling the static assets during the build process, reducing startup time to a couple of seconds.

It assumes an external MySQL database.

External configuration can be achieved either by mapping a volume to /etc/env containing a file 'config.yml', 
or by supplying environmental values through the Docker command line at container start time.

## Building the Image

Datacom-gitlab-docker expects you to provide GitLab for it to add into the image, rather than pulling it from GitHub. After cloning this repository, clone https://github.com/gitlabhq/gitlabhq into gitlab, for example:

    git clone https://github.com/Datacom/datacom-gitlab-docker
    cd datacom-gitlab-docker
    git clone https://github.com/gitlabhq/gitlabhq gitlab
    
Then you're ready to build the image, e.g. ```docker build -t gitlab .```.

## Running it

Note: The ```docker run``` commands shown in this section are *not complete*, but rather are fragments each illustrating a particular aspect of the required configuration. Don't run any of them until you get to the "First Startup" and "Normal Startup" sections.

### Configuration

To run GitLab, first decide how to provide configuration to the image. Two methods are supported. The first is to supply a config.yml file by mapping it into /etc/env. For example,

    docker run -v /var/lib/gitlab/config:/etc/env gitlab

See config/config.yml.example for an example of the file.

The second is to supply the configuration as environment properties through the docker run command, for example:

```docker run -e GITLAB_HOST=gitlab.local -e GITLAB_PORT=8080 -e GITLAB_HTTPS=false -e``` (et cetera)
    
See config/config.yml.example for the set of properties you will need to set in this way. The properties must be specified in uppercase, with underscores for nesting. For example, the database host would be called ```GITLAB_DB_HOST```.

### Database

You must ensure that you are pointing the container at a MySQL database server which has a database for GitLab created, and an appropriate user with appropriate permissions. For example, you could run the following:

    CREATE USER 'gitlab'@'%' IDENTIFIED BY 'yoursecurepassword';
    CREATE DATABASE IF NOT EXISTS gitlabhq_production DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
    GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON gitlabhq_production.* TO 'gitlab'@'%';
	
### Data Volume

You must map a volume to this container for data storage. It will contain the Git repositories, users' SSH keys, etc. You would do something like:

    docker run -v /var/lib/gitlab/data:/var/lib/gitlab gitlab

### Putting it all Together

Here's an example of an interactive startup, using a mapped config.yml file:

    docker run -i -t -v /var/lib/gitlab/config:/etc/env -v /var/lib/gitlab/data:/var/lib/gitlab my_init -- bash
    
```-i -t``` tells Docker that you want to run it in interactive mode and request a TTY. my\_init is the init process for this container, which is run by default. However, specifying it explicity with ```-- bash``` on the end tells my\_init to run bash interactively (as well as doing its normal jobs).

### First Startup

On the first startup of the container, you will run ```dbsetup```, which will set up this empty database.

You could run exactly the command above, and then run ```dbsetup``` at the bash prompt, or you could specify it as the user command instead of bash.

### Normal Startup

Running the container normally, daemonised, with mapped ports, would look something like this:

    docker run -d -v /var/lib/gitlab/config:/etc/env -v /var/lib/gitlab/data:/var/lib/gitlab -p 23:22 -p 80:80
    
This would expose SSH as port 23 on the host, and HTTP as port 80 on the host. Of course, there are many ways you may wish to set up your port mapping, reverse proxying, etc.
