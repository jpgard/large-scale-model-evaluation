# Pull base image.
FROM ubuntu:14.04

# install Python 
RUN \
  apt-get update && \
  apt-get install -y software-properties-common python-software-properties && \
  apt-get -y install python3-dev python3-pip python-virtualenv && \ 
  rm -rf /var/lib/apt/lists/* 

# install Python libraries
RUN pip3 install numpy pandas nltk vaderSentiment textstat

# install MySQL and add configurations
RUN apt-get update && \
  echo "mysql-server-5.6 mysql-server/root_password password root" | sudo debconf-set-selections && \
  echo "mysql-server-5.6 mysql-server/root_password_again password root" | sudo debconf-set-selections && \
  apt-get -y install mysql-server-5.6 && \
  echo "secure-file-priv = \"\"" >> /etc/mysql/conf.d/my5.6.cnf

# add scripts
add extraction extraction

# start mysql
RUN service mysql start

# define entrypoint
ENTRYPOINT ["python3", "extraction/extract_features.py"]





