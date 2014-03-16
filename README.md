datacom-gitlab-docker
=====================

This Dockerfile will create a new Docker container running GitLab on Ubuntu 12.04.

It is inspired by <a href="https://github.com/crashsystems/gitlab-docker">crashsystems/gitlab-docker</a> 
and <a href="https://github.com/sameersbn/docker-gitlab">sameersbn/docker-gitlab</a>, but improves on these 
by precompiling the static assets during the build process, reducing startup time to a couple of seconds.

It assumes an external MySQL database.

External configuration can be achieved either by mapping a volume to /etc/env containing a file 'config.yml', 
or by supplying environmental values through the Docker command line at container start time.

