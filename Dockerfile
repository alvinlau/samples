# https://gist.github.com/varyonic/dea40abcf3dd891d204ef235c6e8dd79
# https://hub.docker.com/r/robcherry/docker-chromedriver/~/dockerfile/

FROM ruby:2.5

WORKDIR /xerobean
ADD . /xerobean

RUN gem install json neatjson xeroizer watir

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

RUN apt-get update -y
RUN apt-get install -y curl wget unzip google-chrome-stable

ENV CD_DIR /chromedriver
RUN mkdir $CD_DIR

# CD_VER=`curl https://chromedriver.storage.googleapis.com/LATEST_RELEASE | cat`
# the latest version 2.40 of chromedriver doesn't work in docker...reverting back to 2.38
RUN CD_VER=2.38 && \
    wget -P $CD_DIR https://chromedriver.storage.googleapis.com/$CD_VER/chromedriver_linux64.zip

RUN unzip $CD_DIR/chromedriver_linux64.zip -d $CD_DIR
RUN mv $CD_DIR/chromedriver /bin
# ENV PATH $CD_DIR:PATH


CMD ["ruby", "xerobean.rb"]
