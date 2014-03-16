datacom-gitlab-docker
=====================

This Dockerfile will create a new Docker container running GitLab on Ubuntu 12.04.

It is inspired by <a href="https://github.com/crashsystems/gitlab-docker">crashsystems/gitlab-docker</a> 
and <a href="https://github.com/sameersbn/docker-gitlab">sameersbn/docker-gitlab</a>, but improves on these 
by precompiling the static assets during the build process, reducing startup time to a couple of seconds.

It assumes an external MySQL database.

External configuration can be achieved either by mapping a volume to /etc/env containing a file 'config.yml', 
or by supplying environmental values through the Docker command line at container start time.

## Building the image

Datacom-gitlab-docker expects you to provide GitLab for it to add into the image, rather than pulling it from GitHub. After cloning this repository, clone https://github.com/gitlabhq/gitlabhq into gitlab, for example:

    git clone https://github.com/Datacom/datacom-gitlab-docker
    cd datacom-gitlab-docker
    git clone https://github.com/gitlabhq/gitlabhq gitlab
    
Then you're ready to build the image, e.g. ```docker build -t gitlab .```.

## Running it

To run GitLab, first decide how to provide configuration to the image. Two methods are supported. The first is to supply a config.yml file by mapping it into /etc/env. For example (don't run this yet),

    docker run -v /home/bob/apps/datacom-gitlab-docker/config:/etc/env gitlab

See config/config.yml.example for an example of the file.

The second is to supply the configuration as environment properties through the docker run command, for example:

    docker run -e GITLAB_HOST=gitlab.local -e GITLAB_PORT=8080 -e GITLAB_HTTPS=false
    
See config/config.yml.example for the set of properties you will need to set in this way. The properties must be specified in uppercase, with underscores for nesting. For example, the database host would be called ```GITLAB_DB_HOST```.

