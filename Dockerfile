FROM amazoncorretto:19-alpine-jdk AS base
ENV JAVA_MAX_RAM 7G
ENV JAVA_MIN_RAM 2G
ENV SERVER_HOME /home/server/

# metadata
LABEL maintainer="ilkimo <https://github.com/ilkimo>"

#set working directory
WORKDIR ${SERVER_HOME}

FROM base AS build
# install curl
RUN apk add --no-cache curl

# install jq (<https://stedolan.github.io/jq/>)
RUN apk add --no-cache jq

# get latest fabric installer
RUN curl $(curl https://meta.fabricmc.net/v2/versions/installer | jq -r '.[0].url') --output fabric-installer.jar

# install fabric
RUN java -jar fabric-installer.jar server -downloadMinecraft

# create eula.txt
RUN echo eula=true >> eula.txt

FROM base AS deploy

# add previously created eula file
COPY --from=build ${SERVER_HOME}/eula.txt .

# copy fabric files
COPY --from=build ${SERVER_HOME}/ .

# copy configuration files
COPY server.properties .
COPY roles.json ./config/

# main connection port
EXPOSE 25565

# run the application
CMD java -Xms${JAVA_MIN_RAM} -Xmx${JAVA_MAX_RAM} -jar fabric-server-launch.jar nogui
