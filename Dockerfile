FROM amazoncorretto:19-alpine-jdk AS base
ENV JAVA_MAX_RAM 4G
ENV JAVA_MIN_RAM 2G
ARG MC_VERSION=latest

# metadata
LABEL maintainer="il-kimo <https://github.com/il-kimo>"

#set working directory
WORKDIR /app

FROM base AS build
# install curl
RUN apk add --no-cache curl

# install jq (<https://stedolan.github.io/jq/>)
RUN apk add --no-cache jq

# get latest fabric installer
RUN curl $(curl https://meta.fabricmc.net/v2/versions/installer | jq -r '.[0].url') --output fabric-installer.jar

# install fabric 
RUN java -jar fabric-installer.jar server -downloadMinecraft -mcversion $MC_VERSION

# create eula.txt
RUN echo eula=true >> eula.txt

FROM base AS deploy

# add previously created eula file
COPY --from=build /app/eula.txt .

# copy fabric files
COPY --from=build /app/ .

# copy configuration files
COPY server.properties .

# copy mods
COPY mods /app/mods

# main connection port
EXPOSE 25565

# run the application
CMD java -Xms${JAVA_MIN_RAM} -Xmx${JAVA_MAX_RAM} -jar fabric-server-launch.jar nogui
